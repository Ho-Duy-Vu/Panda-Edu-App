import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/collection_provider.dart';
import '../providers/flashcard_provider.dart';
import '../pages/folder_detail_page.dart';
import '../../domain/entities/collection.dart';
import '../../core/constants.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionProvider>().loadCollections();
    });
  }

  Future<void> _showCreateDialog() async {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo thư mục mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên thư mục',
                hintText: 'VD: Từ vựng IELTS',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tùy chọn)',
                hintText: 'VD: Vocabulary for IELTS test',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tạo'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final collection = Collection(
        id: const Uuid().v4(),
        name: nameController.text.trim(),
        description: descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
        createdAt: DateTime.now(),
      );

      if (!mounted) return;
      
      try {
        final provider = context.read<CollectionProvider>();
        await provider.createCollection(collection);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã tạo thư mục "${collection.name}"')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }

    nameController.dispose();
    descController.dispose();
  }

  Future<void> _showEditDialog(Collection collection) async {
    final nameController = TextEditingController(text: collection.name);
    final descController = TextEditingController(text: collection.description ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa thư mục'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên thư mục',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tùy chọn)',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty) {
      final updated = collection.copyWith(
        name: nameController.text.trim(),
        description: descController.text.trim().isEmpty
            ? null
            : descController.text.trim(),
      );

      if (!mounted) return;

      try {
        final provider = context.read<CollectionProvider>();
        await provider.updateCollection(updated);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật thư mục')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }

    nameController.dispose();
    descController.dispose();
  }

  Future<void> _showDeleteDialog(Collection collection) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thư mục'),
        content: Text(
          'Xóa thư mục "${collection.name}"?\n\n'
          'Flashcards trong thư mục này sẽ được chuyển về "Chưa phân loại".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final collectionProvider = context.read<CollectionProvider>();
        final flashcardProvider = context.read<FlashcardProvider>();
        
        // Move flashcards to null collection (uncategorized)
        final flashcards = flashcardProvider.flashcards
            .where((f) => f.collectionId == collection.id)
            .toList();
        
        for (var flashcard in flashcards) {
          await flashcardProvider.updateFlashcard(
            flashcard.copyWith(collectionId: null),
          );
        }

        // Delete collection
        await collectionProvider.deleteCollection(collection.id);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xóa thư mục "${collection.name}" (${flashcards.length} flashcards đã chuyển)'),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  void _navigateToCollection(Collection collection) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FolderDetailPage(collection: collection),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bộ sưu tập'),
            Text(
              'by VUHO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w300,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              context.read<CollectionProvider>().sortCollections(value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'name', child: Text('Tên A-Z')),
              PopupMenuItem(value: 'count', child: Text('Số lượng flashcard')),
              PopupMenuItem(value: 'newest', child: Text('Mới nhất')),
              PopupMenuItem(value: 'oldest', child: Text('Cũ nhất')),
            ],
          ),
        ],
      ),
      body: Consumer<CollectionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/panda_sad.webp',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadCollections(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (provider.collections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/panda_placeholder.webp',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chưa có thư mục nào',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pandaBlack,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tạo thư mục để tổ chức flashcards',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showCreateDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.matchaMedium,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    icon: const Icon(Icons.create_new_folder),
                    label: const Text('Tạo thư mục đầu tiên'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header với Panda và stats
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.matchaLight,
                      AppColors.matchaLight.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/panda_happy.webp',
                      width: 80,
                      height: 80,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    Text(
                      '${provider.collections.length} thư mục',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pandaBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tổ chức flashcards của bạn',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSizes.paddingMedium),
              
              // Collections grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSizes.paddingMedium,
                    mainAxisSpacing: AppSizes.paddingMedium,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: provider.collections.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildUncategorizedCard();
                    }
                    final collection = provider.collections[index - 1];
                    return _buildCollectionCard(collection);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        tooltip: 'Tạo thư mục mới',
        backgroundColor: AppColors.matchaMedium,
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildUncategorizedCard() {
    return Consumer<FlashcardProvider>(
      builder: (context, flashcardProvider, child) {
        final uncategorizedCount = flashcardProvider.flashcards
            .where((f) => f.collectionId == null)
            .length;

        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/home',
              arguments: {'collectionId': null},
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[200]!,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              border: Border.all(
                color: Colors.grey[400]!,
                width: 2,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Icon nền
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    Icons.folder_open,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header với icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[500],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.folder_open,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const Spacer(),
                          // Badge số lượng flashcard
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.style,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$uncategorizedCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSizes.paddingMedium),
                      
                      // Tên thư mục
                      const Text(
                        'Chưa phân loại',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pandaBlack,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Mô tả
                      Text(
                        'Flashcards chưa được phân loại',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCollectionCard(Collection collection) {
    return InkWell(
      onTap: () => _navigateToCollection(collection),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.matchaLight,
              AppColors.matchaMedium.withOpacity(0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icon nền
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.folder,
                size: 80,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header với icon và menu
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.matchaMedium,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.folder,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      // Badge số lượng flashcard
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.matchaDark,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.style,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${collection.flashcardCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSizes.paddingMedium),
                  
                  // Tên thư mục
                  Text(
                    collection.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pandaBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Mô tả
                  if (collection.description != null &&
                      collection.description!.isNotEmpty)
                    Text(
                      collection.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    )
                  else
                    Text(
                      'Nhấn để xem flashcards',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  
                  const SizedBox(height: 8),
                  
                  // Menu button ở cuối
                  Align(
                    alignment: Alignment.centerRight,
                    child: PopupMenuButton(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey[700],
                        size: 20,
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Chỉnh sửa'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: AppColors.error, size: 20),
                              SizedBox(width: 8),
                              Text('Xóa', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(collection);
                        } else if (value == 'delete') {
                          _showDeleteDialog(collection);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCollectionColor(String name) {
    // Generate color based on collection name
    final colors = [
      AppColors.matchaDark,
      AppColors.matchaMedium,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    
    final hash = name.codeUnits.fold(0, (prev, curr) => prev + curr);
    return colors[hash % colors.length];
  }
}

