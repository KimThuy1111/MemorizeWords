import 'package:flutter/material.dart';
import '../services/vocabularyService.dart';
import '../models/vocabulary.dart';
import '../widgets/OptionButton.dart';
import '../widgets/ProgressIndicator.dart';

class QuizScreen extends StatefulWidget {
  final String userId;

  const QuizScreen({super.key, required this.userId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Vocabulary> questions = [];
  int currentQuestionIndex = 0;
  int score = 0;
  String? selectedAnswer;
  bool isAnswered = false;
  bool showAnswer = false;
  bool _isLoading = true;
  late List<String> currentOptions;
  final VocabularyService _vocabularyService = VocabularyService();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final rememberedWords = await _vocabularyService.getAllRememberedWords(widget.userId);
    setState(() {
      questions = rememberedWords..shuffle();
      _isLoading = false;
      if (questions.isNotEmpty) {
        setOptionsForCurrentQuestion();
      }
    });
  }

  void setOptionsForCurrentQuestion() {
    final question = questions[currentQuestionIndex];
    final options = [question.meaning];

    // Lấy các đáp án sai từ các từ khác trong danh sách
    final otherMeanings = questions
        .where((q) => q.meaning != question.meaning)
        .map((q) => q.meaning)
        .toList();

    // Thêm 3 đáp án sai (hoặc ít hơn nếu không đủ)
    options.addAll(otherMeanings.take(3));
    options.shuffle();
    currentOptions = options;
  }

  void checkAnswer(String answer) async {
    if (isAnswered) return;

    final isCorrect = answer == questions[currentQuestionIndex].meaning;

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
      showAnswer = true;
      if (isCorrect) {
        score++;
      }else{

      }
    });

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
          // Lưu kết quả khi hoàn thành bài kiểm tra
          _vocabularyService.saveQuizResult(
              widget.userId,
              score,
              questions.length
          );
          _showResultDialog();
        }
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Kiểm tra từ vựng')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning, size: 50, color: Colors.orange),
              const SizedBox(height: 20),
              const Text(
                'Không có từ vựng nào để kiểm tra',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              const Text(
                'Hãy học và ghi nhớ một số từ trước!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    final currentQuestion = questions[currentQuestionIndex];
    final options = currentOptions;

    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra từ vựng')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomProgressIndicator(
              current: currentQuestionIndex + 1,
              total: questions.length,
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (currentQuestion.imageUrl != null && currentQuestion.imageUrl!.isNotEmpty)
                      Image.network(
                        currentQuestion.imageUrl!,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[300],
                            child: const Center(child: Icon(Icons.broken_image)),
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    Text(
                      currentQuestion.word,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return OptionButton(
                    text: option,
                    isCorrect: option == currentQuestion.meaning,
                    isSelected: option == selectedAnswer,
                    showAnswer: showAnswer,
                    onPressed: () => checkAnswer(option),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}