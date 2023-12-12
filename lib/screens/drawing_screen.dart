import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  List<TextFieldData> textFields = [];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Drawing'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.undo,
                color: Get.theme.primaryColorDark,
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.redo,
                color: Get.theme.primaryColorDark,
              ),
            ),
          ],
        ),
        body: GestureDetector(
          onTapDown: (TapDownDetails details) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final Offset localPosition =
                renderBox.globalToLocal(details.globalPosition);

            setState(() {
              textFields.add(
                TextFieldData(
                  position: localPosition,
                  controller: TextEditingController(),
                ),
              );
            });
          },
          child: Stack(
            children: [
              CustomPaint(
                painter: DrawingPainter(),
                child: Container(),
              ),
              ...textFields.map(
                (textFieldData) => Positioned(
                  left: textFieldData.position.dx,
                  top: textFieldData.position.dy,
                  child: SizedBox(
                    width: 300,
                    child: TextField(
                      controller: textFieldData.controller,
                      decoration: const InputDecoration(
                        labelText: 'Type your text',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TextFieldData {
  final Offset position;
  final TextEditingController controller;

  TextFieldData({required this.position, required this.controller});
}

class DrawingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Custom painting logic if needed
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
