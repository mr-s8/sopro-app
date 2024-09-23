import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:taskscout/app_colors.dart';
import 'package:taskscout/classes/job.dart';
import 'package:taskscout/classes/route_step.dart';
import 'package:taskscout/data_model.dart';
import 'package:taskscout/pages/BarCodeScannerSimple.dart';
import 'package:taskscout/pages/full_screen_image.dart';

class RoutePage extends StatefulWidget {
  final Job job;

  const RoutePage({
    super.key,
    required this.job,
  });

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  late Job job;
  late int currentIndex;
  late List<RouteStep> routeList;
  @override
  void initState() {
    super.initState();
    print("initstate");
    job = widget.job;
    routeList = job.route;
    if (job.progress >= routeList.length) {
      // the last object was a qr code and it was scanned correctly
      currentIndex = routeList.length - 1;
    } else {
      currentIndex = job.progress;
    }
  }

  @override
  Widget build(BuildContext context) {
    final RouteStep currentRoute = routeList[currentIndex];
    print("index: ${currentIndex}");

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
          const SizedBox(
            height: 70,
          ),
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
                  print("snapshot: ");
                  print(snapshot);
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
          const SizedBox(height: 16),
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
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentRoute.type == "object")
                    ElevatedButton(
                      onPressed: (() {
                        // Überprüfen, ob der Button aktiviert werden kann
                        if ((routeList[currentIndex].type == "object" &&
                                job.progress > currentIndex) ||
                            routeList[currentIndex].type == "path") {
                          return null; // Button ist deaktiviert
                        }

                        // QR-Code scannen
                        return () async {
                          print("scan qr");

                          final scannedData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BarcodeScannerSimple(),
                            ),
                          );
                          print("done");
                          print(scannedData);

                          // Hier prüfst du das Ergebnis
                          if (scannedData != null) {
                            setState(() {
                              // QR-Code verifizieren
                              if (scannedData == currentRoute.id) {
                                job.progress++;
                                print("Richtiger QR-Code gescannt");
                              } else {
                                print("Falscher QR-Code");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Falscher QR-Code! Bitte versuche es erneut.'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(
                                        seconds: 2), // Dauer der Anzeige
                                  ),
                                );
                              }
                            });
                          }
                        };
                      })(),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors
                                  .green; // Farbe für deaktivierten Zustand
                            }
                            return AppColors.primaryColor; // Standardfarbe
                          },
                        ),
                        minimumSize: MaterialStateProperty.all<Size>(
                          const Size(150, 50),
                        ),
                      ),
                      child: const Icon(Icons.qr_code, color: Colors.white),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Zurück-Button (deaktiviert bei erstem Bild)
                      ElevatedButton(
                        onPressed: currentIndex > 0
                            ? () => navigateToPreviousImage()
                            : null,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Colors
                                    .grey; // Farbe für deaktivierten Zustand
                              }
                              return AppColors.primaryColor; // Standardfarbe
                            },
                          ),
                          minimumSize: MaterialStateProperty.all<Size>(
                            const Size(150, 50),
                          ),
                        ),
                        child:
                            const Icon(Icons.arrow_back, color: Colors.white),
                      ),

                      // Weiter- oder Beenden-Button
                      ElevatedButton(
                        // Wenn letzter Step, Button in "Beenden" umbenennen und erst aktivieren, wenn QR-Code korrekt ist
                        onPressed: ((currentRoute.type == "object" &&
                                    job.progress > currentIndex) ||
                                currentRoute.type == "path")
                            ? () => navigateToNextImageOrFinish()
                            : null,

                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.disabled)) {
                                return Colors
                                    .grey; // Farbe für deaktivierten Zustand
                              }
                              return AppColors.primaryColor; // Standardfarbe
                            },
                          ),
                          minimumSize: MaterialStateProperty.all<Size>(
                            const Size(150, 50),
                          ),
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

  Future<String> getPathForRouteImage(
      String routeImage, String buildingId) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$buildingId/$routeImage';
    return filePath;
  }

  navigateToPreviousImage() {
    setState(() {
      currentIndex--;
    });
  }

  navigateToNextImageOrFinish() async {
    if (currentIndex == routeList.length - 1) {
      print("last");
      widget.job.userStatus = "to_submit";
      print(widget.job.userStatus);
      await DataModel().saveCurrentJobs();
      Navigator.pop(context);
      return;
    }
    setState(() {
      if (routeList[currentIndex].type == "path") {
        if (currentIndex < job.progress) {
          currentIndex++;
        } else {
          currentIndex++;
          job.progress++;
        }
      } else {
        if (job.progress >= currentIndex) {
          currentIndex++;
        }
      }
    });
    print(routeList[currentIndex].type);
    print("progress");
    print(job.progress.toString());
    print("index");
    print(currentIndex.toString());
  }
}
