import 'package:flutter/material.dart';

class SquareButton extends StatelessWidget{
  const SquareButton(this.function, {super.key, required this.buttonText});

  final Function() function;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
          onPressed: function,
          style: ElevatedButton.styleFrom(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Ustawia ostre krawędzie
            ),
            fixedSize: const Size(200, 16),
            padding: EdgeInsets.zero,
          ),
          child: Text(buttonText, style: TextStyle(fontSize: 16)),
        );
  }
}