import 'package:flutter/material.dart';

/// A custom widget that draws a Pixel-Art Spider-Man Heart Mask.
/// Based on the user's hand-drawn reference.
class PixelSpideyIcon extends StatelessWidget {
  final double size;
  final bool isSymbiote; // true for Black mask, false for Red mask

  const PixelSpideyIcon({
    super.key,
    this.size = 24,
    this.isSymbiote = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color mainColor = isSymbiote ? Colors.black : const Color(0xFFC0392B);
    final Color detailColor = isSymbiote ? Colors.grey.shade800 : Colors.black;

    // A 13x11 grid representing the heart mask from the drawing
    // 0 = Transparent, 1 = Detail/Border, 2 = Main Color (Red/Black), 3 = Eye (White)
    const List<List<int>> grid = [
      [0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0],
      [0, 1, 2, 2, 1, 0, 0, 0, 1, 2, 2, 1, 0],
      [1, 2, 2, 2, 2, 1, 0, 1, 2, 2, 2, 2, 1],
      [1, 2, 3, 3, 2, 2, 1, 2, 2, 3, 3, 2, 1],
      [1, 2, 3, 3, 3, 2, 1, 2, 3, 3, 3, 2, 1],
      [1, 2, 2, 3, 3, 2, 1, 2, 3, 3, 2, 2, 1],
      [0, 1, 2, 2, 2, 2, 1, 2, 2, 2, 2, 1, 0],
      [0, 0, 1, 2, 2, 2, 2, 2, 2, 2, 1, 0, 0],
      [0, 0, 0, 1, 2, 2, 2, 2, 2, 1, 0, 0, 0],
      [0, 0, 0, 0, 1, 2, 2, 2, 1, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 1, 2, 1, 0, 0, 0, 0, 0],
      [0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
    ];

    return SizedBox(
      width: size,
      height: size,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pixelSize = constraints.maxWidth / 13;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: grid.map((row) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: row.map((pixel) {
                  Color color;
                  switch (pixel) {
                    case 1: color = detailColor; break;
                    case 2: color = mainColor; break;
                    case 3: color = Colors.white; break;
                    default: color = Colors.transparent;
                  }
                  return Container(
                    width: pixelSize,
                    height: pixelSize,
                    color: color,
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
