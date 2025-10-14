import 'package:flutter/cupertino.dart';

class BgColors extends StatelessWidget {
  final Widget child;
  final double opacity;
  const BgColors({super.key, required this.child, this.opacity = 0.2});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFffffff), //  White
            Color(0xFFE9F2DD), // Stronger light green
            Color(0xFFD6EFB5), // Stronger light green
            Color(0xFFB8E0A0), // Deeper pastel green
          ],
        ),
        // image: DecorationImage(
        //   image: AssetImage('assets/pattern.png'),
        //   fit: BoxFit.cover,
        //   opacity: opacity,
        // ),
      ),
      child: child,
    );
  }
}