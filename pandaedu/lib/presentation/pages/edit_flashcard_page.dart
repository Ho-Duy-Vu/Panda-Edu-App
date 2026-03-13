import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../widgets/audio_player_widget.dart';
import '../../domain/entities/flashcard.dart';
import '../../core/constants.dart';

class EditFlashcardPage extends StatefulWidget {
  final Flashcard flashcard;

  const EditFlashcardPage({super.key, required this.flashcard});

  @override
  State<EditFlashcardPage> createState() => _EditFlashcardPageState();
}

class _EditFlashcardPageState extends State<EditFlashcardPage> {
  late TextEditingController _titleController;
  late TextEditingController _transcriptController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.flashcard.title);
    _transcriptController = TextEditingController(text: widget.flashcard.transcript);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _transcriptController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedFlashcard = widget.flashcard.copyWith(
        title: _titleController.text.trim(),
        transcript: _transcriptController.text.trim(),
      );

      final provider = context.read<FlashcardProvider>();
      await provider.updateFlashcard(updatedFlashcard);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật flashcard!')),
      );

      Navigator.pop(context, true); // Return true để DetailPage reload
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa Flashcard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSaving ? null : _save,
            tooltip: 'Lưu',
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            children: [
              // Panda image
              Center(
                child: Image.asset(
                  'assets/images/panda_happy.webp',
                  width: 80,
                  height: 80,
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),

              // Audio player (nếu có)
              if (widget.flashcard.audioPath != null &&
                  widget.flashcard.audioPath!.isNotEmpty) ...[
                const Text(
                  'Audio gốc:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: AudioPlayerWidget(audioPath: widget.flashcard.audioPath!),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLarge),
              ],

              // Title field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  hintText: 'Nhập tiêu đề flashcard',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => FlashcardValidator.validateTitle(value ?? ''),
                maxLength: FlashcardValidator.maxTitleLength,
              ),
              const SizedBox(height: AppSizes.paddingMedium),

              // Transcript field
              TextFormField(
                controller: _transcriptController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  hintText: 'Nhập nội dung flashcard',
                  prefixIcon: Icon(Icons.text_fields),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) => FlashcardValidator.validateTranscript(value ?? ''),
                maxLength: FlashcardValidator.maxTranscriptLength,
              ),
              const SizedBox(height: AppSizes.paddingLarge),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMedium),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text('Lưu thay đổi'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

