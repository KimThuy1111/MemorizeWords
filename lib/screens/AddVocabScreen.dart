import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vocabulary.dart';
import '../services/vocabularyService.dart';
import 'package:uuid/uuid.dart';

// 6.1 Hiện thực chức năng "Thêm từ vừng"
class AddVocabScreen extends StatefulWidget {
  static const routeName = '/add-vocab';

  @override
  _AddVocabScreenState createState() => _AddVocabScreenState();
}

class _AddVocabScreenState extends State<AddVocabScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _meaningController = TextEditingController();
  final _imageUrlController = TextEditingController();
  String _selectedStatus = 'review';

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final newVocab = Vocabulary(
      id: const Uuid().v4(),
      word: _wordController.text.trim(),
      meaning: _meaningController.text.trim(),
      status: _selectedStatus,
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
    );

    Provider.of<VocabularyService>(context, listen: false)
        .addVocabulary(newVocab);

    Navigator.of(context).pop();
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
                  onPressed: _saveForm,
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
