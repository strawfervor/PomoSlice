import 'package:flutter/material.dart';


class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({super.key, required this.child});
  
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      alignment: Alignment.topCenter,
      child: SizedBox(width: 220, child: child),
    );
  }
}