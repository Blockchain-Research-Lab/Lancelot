import 'package:flutter/material.dart';

Route createRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(seconds: 2),  // Adjust duration to slow down the animation
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      // Define the beginning and end of the rotation
      const beginRotation = 0.0;
      const endRotation = 1.0;

      // Define the beginning and end of the scaling
      const beginScale = 0.0;
      const endScale = 1.0;

      // Define the curve for the animation
      const curve = Curves.easeInOut;

      // Create tween for rotation
      var rotationTween = Tween(begin: beginRotation, end: endRotation)
          .chain(CurveTween(curve: curve));
      var rotationAnimation = animation.drive(rotationTween);

      // Create tween for scaling
      var scaleTween = Tween(begin: beginScale, end: endScale)
          .chain(CurveTween(curve: curve));
      var scaleAnimation = animation.drive(scaleTween);

      return AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ(rotationAnimation.value * 3.14 * 2) // Full rotation
              ..scale(scaleAnimation.value), // Scale
            child: child,
          );
        },
        child: child,
      );
    },
  );
}
