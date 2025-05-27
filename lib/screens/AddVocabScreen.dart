import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/User.dart';
import '../models/vocabulary.dart';
import '../services/vocabularyService.dart';
import 'package:uuid/uuid.dart';

// 7.1.2 Vẽ màn hình thêm từ vựng.
class AddVocabScreen extends StatefulWidget {
  static const routeName = '/add-vocab';
  static VocabularyService vocabularyService = VocabularyService();

  @override
  AddVocabScreenState createState() => AddVocabScreenState();
}

class AddVocabScreenState extends State<AddVocabScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedStatus = 'review';
  final db = FirebaseFirestore.instance;
  static User userEx = User.getExample();
  static VocabularyService vocabularyService = VocabularyService();

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    _imageUrlController.dispose();
  }

//7.1.4 Admin/Content provider nhập biểu mẫu điền thông tin từ vựng và ấn lưu.
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    final newVocab = Vocabulary.autoSetId(
      word: _wordController.text.trim(),
      meaning: _meaningController.text.trim(),
      status: _selectedStatus,
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
    );
    //
    // Provider.of<VocabularyService>(context, listen: false)
    //     .addVocabulary(newVocab);

    //7.1.5 Kiểm tra trùng
    //Lấy kết quả kiểm tra
    bool isDuplicate = await vocabularyService.isVocabularyDuplicate(
        userEx.username, newVocab);
    //7.1.6 Nếu trùng trên Firebase thì hàm isVocabularyDuplicate() trả về false
    if (isDuplicate) {
      //7.1.10 Hiển thị cảnh báo trùng.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          //7.1.11 Hiển thị thông báo "Từ đã tồn tại, vui lòng nhập thông tin từ mới", hiển thị biểu mẫu điền từ vựng
          content: Text('❗ Từ vựng đã tồn tại. Vui lòng nhập từ khác.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Không thực hiện lưu
    }

    // 7.1.7 Hệ thống lưu từ vựng trên firebase
    await vocabularyService.addVocabulary(
        newVocab, userEx, userEx.topicSets.first);

    // 7.1.9 Hệ thống hiện thông báo thành công.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Đã thêm từ vựng thành công.')),
    );

    // Quay về sau khi thêm
    Navigator.of(context).pop();
  }

  void addVocabDetail(Vocabulary vocab) {
    db.collection('vocabularies').add({
      'word': vocab.word,
      'meaning': vocab.meaning,
      'status': vocab.status,
      'imageUrl': vocab.imageUrl,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text('Thêm Từ Vựng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            //7.1.4 Admin/Content provider nhập biểu mẫu điền thông tin từ vựng và ấn lưu.
            onPressed: _saveForm,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          //7.1.3 Màn hình hiển thị form điền thông tin từ vựng
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Từ tiếng Anh'),
                  controller: _wordController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập từ';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration:
                      const InputDecoration(labelText: 'Nghĩa tiếng Việt'),
                  controller: _meaningController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập nghĩa';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Trạng thái'),
                  value: _selectedStatus,
                  items: ['review', 'remembered']
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'URL hình ảnh (tuỳ chọn)'),
                  controller: _imageUrlController,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  // onPressed: _saveForm,
                  //7.1.12 Hiển thị thông báo "Từ đã tồn tại, vui lòng nhập thông tin từ mới", hiển thị biểu mẫu điền từ vựng
                  onPressed: () {
                    CollectionReference collRef =
                        FirebaseFirestore.instance.collection('user');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Thêm'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
