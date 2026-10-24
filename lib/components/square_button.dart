import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget {
  const SquareButton({
    super.key,
    required this.onPressed,
    required this.buttonText,
  });

  final VoidCallback? onPressed;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        fixedSize: const Size(200, 48),
        padding: EdgeInsets.zero,
      ),
      child: Text(buttonText, style: TextStyle(fontSize: 16)),
    );
  }
}
