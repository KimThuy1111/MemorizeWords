
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuizController extends StatelessWidget {
  final String text;
  final bool isCorrect;
  final bool isSelected;
  final bool showAnswer;
  final VoidCallback? onPressed;

  const QuizController({
    super.key,
    required this.text,
    required this.isCorrect,
    required this.isSelected,
    required this.showAnswer,
    required this.onPressed,
  });
  //3.13 Thiết lập màu sắc cho các đáp án
  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.white;
    Color textColor = Colors.black;
    double elevation = 2;
    Border? border;

    if (showAnswer) {
      //Kết quả đúng hiển thị màu xanh
      if (isCorrect) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
        elevation = 8;
        border = Border.all(color: Colors.green.shade700, width: 2);
      } else if (isSelected) {
        //Nếu chọn sai sẽ hiển thị kết quả màu đỏ
        backgroundColor = Colors.red;
        textColor = Colors.white;
        elevation = 8;
        border = Border.all(color: Colors.red.shade700, width: 2);
      }
    } else if (isSelected) {
      backgroundColor = Colors.blue;
      textColor = Colors.white;
      elevation = 8;
      border = Border.all(color: Colors.blue.shade700, width: 2);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
      child: Material(
        elevation: elevation,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: border,
            ),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class CustomProgressIndicator extends StatelessWidget {
  final int current;
  final int total;

  const CustomProgressIndicator({
    super.key,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    double progress = current / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Câu $current / $total',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ],
    );
  }
}