import 'package:flutter/material.dart'; // Thư viện giao diện chính của Flutter
import 'dart:math'; // Sử dụng giá trị pi cho hiệu ứng lật
import '../controllers/flashcardController.dart';// Controller quản lý phiên học từ vựng
import '../models/vocabulary.dart'; // Model đại diện cho 1 từ vựng

// Màn hình Flashcard
class FlashcardScreen extends StatefulWidget {
  final String userId;     // ID người dùng để cá nhân hóa dữ liệu
  final String setName;    // Tên bộ từ vựng cần học

  const FlashcardScreen({super.key, required this.userId, required this.setName});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with SingleTickerProviderStateMixin {
  final FlashcardController _controller = FlashcardController(); // Controller điều khiển logic học từ
  late AnimationController _animationController; // Điều khiển thời gian animation
  late Animation<double> _animation; // Animation dùng để xoay góc lật thẻ
  bool isFront = true; // Theo dõi mặt hiện tại của thẻ (true = mặt từ, false = mặt nghĩa)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSession(); // Bắt đầu khởi tạo dữ liệu học từ controller

    // Tạo animation controller với thời gian lật 500ms
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Tạo animation tween từ 0 đến pi (0° đến 180°) để mô phỏng xoay thẻ
    _animation = Tween<double>(begin: 0, end: pi).animate(_animationController);
  }

  // Gọi controller để lấy danh sách từ vựng ban đầu
  Future<void> _initSession() async {
    await _controller.initSession(widget.userId, widget.setName);
    setState(() {
      _isLoading = false;
    });
  }


  @override
  void dispose() {
    _animationController
        .dispose(); // Giải phóng controller animation khi không dùng nữa
    super.dispose();
  }

  // Xử lý lật thẻ
  void _flipCard() {
    if (isFront) {
      _animationController.forward(); // Lật sang mặt nghĩa
    } else {
      _animationController.reverse(); // Lật trở lại mặt từ
    }
    setState(() {
      isFront = !isFront; // Đảo trạng thái mặt
    });
  }

  // Xử lý khi người dùng nhấn "Đã nhớ" hoặc "Cần ôn lại"
  void _handleAnswer(String status) async {
    await _controller.handleAnswer(status);

    // Kiểm tra nếu đã học xong
    final word = _controller.currentWord;

    if (word == null) {
      // Gọi setState để rebuild và kích hoạt đoạn kiểm tra word == null trong build()
      if (mounted) {
        setState(() {});
      }
    } else {
      setState(() {
        isFront = true;
        _animationController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final word = _controller.currentWord; // Lấy từ hiện tại
    if (word == null) {
      // Hiển thị AlertDialog một lần duy nhất
      Future.delayed(Duration.zero, () async {
        final shouldRestart = await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Không cho thoát bằng cách bấm ra ngoài
          builder: (context) => AlertDialog(
            title: const Text('🎉 Hoàn thành!'),
            content: const Text('Bạn đã hoàn thành bộ từ vựng.\nBạn có muốn học lại không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Không học lại
                child: const Text('Không'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true), // Học lại
                child: const Text('Học lại'),
              ),
            ],
          ),
        );

        if (shouldRestart == true) {
          await _controller.initSession(widget.userId, widget.setName); // Làm lại
          setState(() {
            isFront = true;
            _animationController.reset();
          });
        } else {
          if (mounted) Navigator.pop(context); // Quay lại trang trước
        }
      });

      return const Scaffold(
        body: Center(child: CircularProgressIndicator()), // Tạm hiển thị loading
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Bộ từ: ${widget.setName}')), // Tiêu đề
      body: Center(
        child: GestureDetector(
          onTap: _flipCard, // Khi nhấn vào thẻ thì thực hiện lật
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value;
              final isUnder = angle >
                  pi / 2; // Nếu góc > 90° thì đang là mặt sau

              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Tạo hiệu ứng 3D mượt
                  ..rotateY(angle), // Xoay theo trục Y
                alignment: Alignment.center,
                child: isUnder
                    ? Transform(
                  transform: Matrix4.rotationY(pi), // Lật lại chữ để đọc được
                  alignment: Alignment.center,
                  child: _buildMeaningSide(word), // Mặt sau (nghĩa)
                )
                    : _buildWordSide(word), // Mặt trước (từ)
              );
            },
          ),
        ),
      ),
    );
  }

  // Widget hiển thị mặt trước (từ vựng)
  Widget _buildWordSide(Vocabulary word) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.teal,
      child: Container(
        width: 300,
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị ảnh nếu có
            if (word.imageUrl != null && word.imageUrl!.isNotEmpty) Container(
              height: 150,
              margin: const EdgeInsets.only(bottom: 16),
              child: ClipRRect(borderRadius: BorderRadius.circular(12),
                child: Image.network(word.imageUrl!, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300], child: const Center(child: Icon(
                        Icons.broken_image, size: 48, color: Colors.grey),),);
                  },),),),
            // Hiển thị từ
            Text(
              word.word,
              style: const TextStyle(fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeaningSide(Vocabulary word) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.teal.shade600, // đậm hơn cho rõ nét hơn
      child: Container(
        width: 300,
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiển thị ảnh nếu có
            if (word.imageUrl != null && word.imageUrl!.isNotEmpty)
              Container(
                height: 150,
                margin: const EdgeInsets.only(bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    word.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Hiển thị nghĩa của từ
            Text(
              word.meaning,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _handleAnswer('remembered'),
                  child: const Text('Đã nhớ'),
                ),
                ElevatedButton(
                  onPressed: () => _handleAnswer('review'),
                  child: const Text('Cần ôn lại'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}