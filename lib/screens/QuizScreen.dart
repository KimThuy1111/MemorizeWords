import 'package:flutter/material.dart';
import '../controllers/QuizController.dart';
import '../services/quizService.dart';
import '../services/vocabularyService.dart';
import '../models/vocabulary.dart';


class QuizScreen extends StatefulWidget {
  final String userId;

  const QuizScreen({super.key, required this.userId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Vocabulary> questions = [];
  int score = 0;
  String? selectedAnswer;
  bool isAnswered = false;
  bool showAnswer = false;
  late List<String> currentOptions;
  final QuizService _quizService = QuizService();

  //3.3 Trong initState(), màn hình gọi hàm loadQuestions() để tải danh sách câu hỏi.
  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    //3.4 Hàm _loadQuestions() gọi getAllRememberedWords(userId) từ vocabularyService để lấy danh sách từ vựng
    final rememberedWords = await _quizService.getAllRememberedWords(widget.userId);
    setState(() {
      //3.6 Kết quả trả về được trộn ngẫu nhiên bằng shuffle()
      questions = rememberedWords..shuffle();
      if (questions.length > 5) {
        //3.7 Lấy 5 từ đầu tiên sau khi trộn
        questions = questions.sublist(0, 5);
        //3.8 Với mỗi câu hỏi, hàm setOptionsForCurrentQuestion() được gọi để tạo các lựa chọn cho câu hỏi.
        setOptionsForCurrentQuestion();
      }

    });
  }
  int currentQuestionIndex = 0;
  void setOptionsForCurrentQuestion() {
    final question = questions[currentQuestionIndex];
    final options = [question.meaning];
    final otherMeanings = questions
        .where((q) => q.meaning != question.meaning)
        .map((q) => q.meaning)
        .toList();
    options.addAll(otherMeanings.take(2));
    //3.9 Các đáp án được xáo trộn thứ tự bằng shuffle().
    options.shuffle();
    currentOptions = options;
  }

  //3.10 Hiển thị giao diện bài kiểm tra
  @override
  Widget build(BuildContext context) {

    if (questions.length < 5) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kiểm tra từ vựng')),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade100,
                Colors.white,
              ],
            ),
          ),

          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, size: 50, color: Colors.orange),
                const SizedBox(height: 20),
                // 3.7 Hiển thị thông báo yêu cầu người dùng học thêm từ.
                const Text(
                  'Không có từ vựng nào để kiểm tra',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Hãy học và ghi nhớ một số từ trước!',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Quay lại', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final currentQuestion = questions[currentQuestionIndex];
    final options = currentOptions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra từ vựng'),
        backgroundColor: Colors.blue.shade400,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade100,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomProgressIndicator(current: currentQuestionIndex + 1,),
              const SizedBox(height: 24),
              Card(elevation: 8,shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24),),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      if (currentQuestion.imageUrl != null &&
                          currentQuestion.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(currentQuestion.imageUrl!,height: 180,width: double.infinity,fit: BoxFit.cover,errorBuilder: (context, error, stackTrace) {
                              return Container(height: 180,color: Colors.grey[300],
                                child: const Center(child: Icon(Icons.broken_image, size: 48)),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(currentQuestion.word,
                        style: const TextStyle(fontSize: 32,fontWeight: FontWeight.bold,color: Colors.black87,),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    //3.12 Kiểm tra kết quả thông qua hàm checkAnswer(String answer) và truyền vào QuizController
                    return QuizController(text: option,isCorrect: option == currentQuestion.meaning,isSelected: option == selectedAnswer,showAnswer: showAnswer,onPressed: () => checkAnswer(option),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void checkAnswer(String answer) async {
    if (isAnswered) return;
    final isCorrect = answer == questions[currentQuestionIndex].meaning;
    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
      showAnswer = true;
      //3.14 Tăng biến score
      if (isCorrect) {
          score++;
      }
    });
    //3.15 Chuyển câu hỏi tiếp theo sau 2 giây
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (currentQuestionIndex < questions.length - 1) {
          setState(() {
            currentQuestionIndex++;
            selectedAnswer = null;
            isAnswered = false;
            showAnswer = false;
            setOptionsForCurrentQuestion();
          });
        } else {
          //3.15 Gọi hàm saveQuizResult() ở class vocabularyService để lưu kết quả
          _quizService.saveQuizResult(
              widget.userId,
              score,
              questions.length
          );
          //3.17 Hiển thị kết quả bài kiểm tra showResultDialog()
          _showResultDialog();
        }
      }
    });
  }
  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: const Text('Kết quả kiểm tra'),
            content: Text('Bạn đã trả lời đúng $score/${questions.length} câu'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng dialog
                  Navigator.pop(context); // Quay lại màn hình trước
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}