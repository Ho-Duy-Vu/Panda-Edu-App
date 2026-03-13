import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/flashcard_provider.dart';
import '../providers/collection_provider.dart';
import '../widgets/audio_player_widget.dart';
import '../../domain/entities/flashcard.dart';
import '../../domain/entities/collection.dart';
import '../../core/constants.dart';

class ConfirmTranscriptPage extends StatefulWidget {
  final String? audioPath;
  final String initialTranscript;
  final int duration;

  const ConfirmTranscriptPage({
    super.key,
    this.audioPath,
    required this.initialTranscript,
    required this.duration,
  });

  @override
  State<ConfirmTranscriptPage> createState() => _ConfirmTranscriptPageState();
}

class _ConfirmTranscriptPageState extends State<ConfirmTranscriptPage> {
  late TextEditingController _titleController;
  late TextEditingController _transcriptController;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _selectedCollectionId;

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController(text: widget.initialTranscript);
    _titleController = TextEditingController(text: '');
    
    // Load collections và nhận collectionId từ arguments nếu có
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // CRITICAL: Load collections trước khi hiển thị dropdown
      context.read<CollectionProvider>().loadCollections();
      
      // Nếu user tap vào folder rồi tạo flashcard → auto-select folder đó
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('collectionId')) {
        setState(() {
          _selectedCollectionId = args['collectionId'];
        });
      }
    });
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

    if (_selectedCollectionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn thư mục để lưu flashcard'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final flashcard = Flashcard(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        transcript: _transcriptController.text.trim(),
        audioPath: widget.audioPath,
        createdAt: DateTime.now(),
        duration: widget.duration,
        collectionId: _selectedCollectionId,
      );

      final provider = context.read<FlashcardProvider>();
      await provider.createFlashcard(flashcard);

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu flashcard!')),
      );
      
      Navigator.popUntil(context, (route) => route.isFirst);
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
        title: const Text('Xác nhận nội dung'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSizes.paddingLarge),
            children: [
              Center(
                child: Image.asset(
                  'assets/images/panda_happy.webp',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),

              if (widget.audioPath != null && 
                  widget.audioPath!.isNotEmpty &&
                  widget.audioPath != 'null') ...[
                const Text(
                  'Nghe lại:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingSmall),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingMedium),
                    child: AudioPlayerWidget(audioPath: widget.audioPath!),
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLarge),
              ]
              else ...[
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.matchaLight.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.matchaMedium),
                      SizedBox(width: AppSizes.paddingSmall),
                      Expanded(
                        child: Text(
                          'Flashcard không có audio (chỉ văn bản)',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLarge),
              ],

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề (*)',
                  hintText: 'Nhập tiêu đề tóm tắt',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => FlashcardValidator.validateTitle(value ?? ''),
                maxLength: FlashcardValidator.maxTitleLength,
                autofocus: true,
              ),
              const SizedBox(height: AppSizes.paddingMedium),

              TextFormField(
                controller: _transcriptController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung (từ ghi âm)',
                  hintText: 'Nội dung đã được chuyển từ giọng nói',
                  prefixIcon: Icon(Icons.text_fields),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) => FlashcardValidator.validateTranscript(value ?? ''),
                maxLength: FlashcardValidator.maxTranscriptLength,
              ),
              const SizedBox(height: AppSizes.paddingLarge),

              const Text(
                'Thư mục (*)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingSmall),
              Consumer<CollectionProvider>(
                builder: (context, provider, _) {
                  final collections = provider.collections;
                  
                  if (collections.isEmpty) {
                    return Card(
                      color: Colors.orange.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.paddingMedium),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: AppSizes.paddingSmall),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chưa có thư mục',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Vui lòng tạo thư mục trước',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Chọn thư mục',
                      prefixIcon: const Icon(Icons.folder),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                      ),
                      filled: true,
                      fillColor: AppColors.milkWhite,
                    ),
                    value: _selectedCollectionId,
                    items: collections
                        .map((collection) => DropdownMenuItem(
                              value: collection.id,
                              child: Row(
                                children: [
                                  const Icon(Icons.folder, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(collection.name),
                                        Text(
                                          '${collection.flashcardCount} flashcards',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCollectionId = value;
                      });
                    },
                    validator: (value) => value == null
                        ? 'Vui lòng chọn thư mục'
                        : null,
                  );
                },
              ),
              const SizedBox(height: AppSizes.paddingLarge),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
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
                          : const Text('Lưu Flashcard'),
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
