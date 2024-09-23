import 'package:flutter/material.dart';

class ButtonProblem extends StatefulWidget {
  const ButtonProblem({
    super.key,
  });

  @override
  State<ButtonProblem> createState() => _ButtonProblemState();
}

class _ButtonProblemState extends State<ButtonProblem> {
  late int currentIndex;
  late List<int> list;

  @override
  void initState() {
    super.initState();
    // Liste zum durchgehen
    list = [0, 1, 2, 3, 4, 5, 6];
    currentIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Button Problem'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        const SizedBox(
          height: 20,
        ),
        Text("currentIndex: ${currentIndex.toString()}"),
        Text("current list item: ${list[currentIndex].toString()}"),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: currentIndex > 0 ? () => navigateToPrevious() : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey; // Farbe für deaktivierten Zustand
                    }
                    return Colors.blue; // Standardfarbe
                  },
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  const Size(150, 50),
                ),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            ElevatedButton(
              onPressed: (currentIndex < list.length - 1)
                  ? () => navigateToNext()
                  : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.disabled)) {
                      return Colors.grey; // Farbe für deaktivierten Zustand
                    }
                    return Colors.blue; // Standardfarbe
                  },
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  const Size(150, 50),
                ),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ]),
    );
  }

  navigateToPrevious() {
    setState(() {
      currentIndex--;
    });
  }

  navigateToNext() {
    setState(() {
      currentIndex++;
    });
  }
}
