import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String text;
  final bool isCorrect;
  final bool isSelected;
  final bool showAnswer;
  final VoidCallback? onPressed;

  const OptionButton({
    super.key,
    required this.text,
    required this.isCorrect,
    required this.isSelected,
    required this.showAnswer,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color textColor = Colors.black;

    if (showAnswer) {
      if (isCorrect) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
      } else if (isSelected) {
        backgroundColor = Colors.red;
        textColor = Colors.white;
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
