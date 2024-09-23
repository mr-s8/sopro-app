import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:taskscout/app_colors.dart';
import 'package:taskscout/classes/job.dart';
import 'package:taskscout/classes/route_step.dart';
import 'package:taskscout/pages/full_screen_image.dart';

class JobDetailPage extends StatefulWidget {
  final Job job;

  const JobDetailPage({
    super.key,
    required this.job,
  });

  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  int currentIndex = 0;
  bool qrCodeScannedCorrectly =
      false; // Zustand, ob der QR-Code korrekt gescannt wurde
  @override
  Widget build(BuildContext context) {
    final List<RouteStep> routeList = widget.job.route;
    final RouteStep currentRoute = routeList[currentIndex];
    var progress = widget.job.progress;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              icon: const Icon(
                Icons.map_outlined,
                size: 32,
              ),
              onPressed: () {
                print("Settings icon pressed");
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 70), // Abstand oben

          GestureDetector(
            onTap: () {
              // Bild in Vollbild anzeigen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageFullScreen(
                    imagePath: currentRoute.routeImage,
                    buildingId: widget.job.buildingId,
                  ),
                ),
              );
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: FutureBuilder<String>(
                future: getPathForRouteImage(
                    currentRoute.routeImage, widget.job.buildingId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return const SizedBox(
                      height: 300,
                      child: Center(
                        child: Text('Fehler beim Laden des Bildes'),
                      ),
                    );
                  }

                  final filePath = snapshot.data!;

                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Container(
                      height: 400, // Fixierte Höhe für das Bild
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: File(filePath).existsSync()
                              ? FileImage(File(filePath))
                              : const AssetImage(
                                      'lib/assets/background_image.jpg')
                                  as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16), // Abstand zwischen Bild und Beschreibung

          // Beschreibung des aktuellen Routesteps
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              currentRoute.description,
              style: const TextStyle(fontSize: 20),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(
              height: 20), // Abstand zwischen Beschreibung und Buttons

          // Navigations- und QR-Code-Buttons am unteren Bildschirmrand
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // QR-Code Button, falls type == "object"
                  if (currentRoute.type == "object")
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Align(
                        alignment: Alignment
                            .bottomRight, // Button nach unten rechts ausrichten
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 16.0,
                              bottom: 16.0), // Abstand nach rechts und unten
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors
                                  .primaryColor, // Blaue Hintergrundfarbe
                              shape: BoxShape.circle, // Runde Form
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.2), // Schatteneffekt
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: const Offset(
                                      0, 3), // Position des Schattens
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.qr_code,
                                color: Colors.white, // Weißes Icon
                              ),
                              onPressed: () async {
                                print("scan qr");
                                /*
                                final scannedData = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ---,
                                  ),
                                );
                                print("done");
                                print(scannedData);

                                // Hier prüfst du das Ergebnis
                                if (scannedData != null) {
                                  setState(
                                    () {
                                      // QR-Code verifizieren
                                      if (scannedData == currentRoute.id) {
                                        qrCodeScannedCorrectly = true;
                                        print("Richtiger QR-Code gescannt");
                                      } else {
                                        qrCodeScannedCorrectly = false;
                                        print("Falscher QR-Code");
                                      }
                                    },
                                  );
                                }
                                */
                              },
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Navigations-Buttons in einer Reihe
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Zurück-Button (deaktiviert bei erstem Bild)
                      ElevatedButton(
                        onPressed: currentIndex > 0
                            ? () => navigateToPreviousImage()
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          minimumSize: const Size(150, 50),
                        ),
                        child:
                            const Icon(Icons.arrow_back, color: Colors.white),
                      ),

                      // Weiter- oder Beenden-Button
                      ElevatedButton(
                        // Wenn letzter Step, Button in "Beenden" umbenennen und erst aktivieren, wenn QR-Code korrekt ist
                        onPressed: (currentIndex >= routeList.length - 1 ||
                                (currentRoute.type == "object" &&
                                    !qrCodeScannedCorrectly))
                            ? null
                            : () => navigateToNextImageOrFinish(),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          minimumSize: const Size(150, 50),
                        ),
                        child: currentIndex == routeList.length - 1
                            ? const Text('Beenden',
                                style: TextStyle(color: Colors.white))
                            : const Icon(Icons.arrow_forward,
                                color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void navigateToPreviousImage() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      }
    });
  }

  void navigateToNextImageOrFinish() {
    print("next");
    print(qrCodeScannedCorrectly);

    final isLastStep = currentIndex == widget.job.route.length - 1;
    final isObjectAndQRCodeRequired =
        widget.job.route[currentIndex].type == "object";

    if (isLastStep && (!isObjectAndQRCodeRequired || qrCodeScannedCorrectly)) {
      // Nur beim letzten Schritt und wenn QR-Code korrekt gescannt wurde, Auftrag beenden
      Navigator.pop(context);
    } else if (!isLastStep) {
      // Falls es nicht der letzte Schritt ist, zum nächsten Bild navigieren
      setState(() {
        currentIndex++;
        qrCodeScannedCorrectly = false; // QR-Code Status zurücksetzen
      });
    }
  }

  Future<String> getPathForRouteImage(
      String routeImage, String buildingId) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$buildingId/$routeImage';
    return filePath;
  }
}


// index ändert sich nach scan nicht mehr