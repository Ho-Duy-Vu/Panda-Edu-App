import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../providers/collection_provider.dart';
import '../widgets/flashcard_tile.dart';
import '../widgets/panda_empty_state.dart';
import '../../domain/entities/collection.dart';
import '../../core/constants.dart';

class FolderDetailPage extends StatefulWidget {
  final Collection collection;

  const FolderDetailPage({
    super.key,
    required this.collection,
  });

  @override
  State<FolderDetailPage> createState() => _FolderDetailPageState();
}

class _FolderDetailPageState extends State<FolderDetailPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    
    // Set collection filter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashcardProvider>().setCollectionFilter(widget.collection.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // CRITICAL: Clear filter và search trước khi dispose
    final provider = context.read<FlashcardProvider>();
    provider.clearCollectionFilter();
    provider.setSearchQuery(''); // Clear search query
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Clear filter khi user nhấn back
        context.read<FlashcardProvider>().clearCollectionFilter();
        context.read<FlashcardProvider>().setSearchQuery('');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.collection.name),
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
        ),
        body: Column(
          children: [
            // Collection header với Panda
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
                boxShadow: [
                  BoxShadow(
                    color: AppColors.matchaMedium.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Column(
                children: [
                  // Panda icon
                  Image.asset(
                    'assets/images/panda_happy.webp',
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  
                  // Folder name
                  Text(
                    widget.collection.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pandaBlack,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  // Description
                  if ((widget.collection.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      widget.collection.description ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  
                  const SizedBox(height: AppSizes.paddingMedium),
                  
                  // Flashcard count badge
                  Consumer<FlashcardProvider>(
                    builder: (context, provider, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.matchaMedium,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.style,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${provider.flashcards.length} flashcards',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Search and sort bar
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm flashcard...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: AppColors.milkWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                          vertical: AppSizes.paddingSmall,
                        ),
                      ),
                      onChanged: (value) {
                        context.read<FlashcardProvider>().setSearchQuery(value);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingSmall),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.milkWhite,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                    ),
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.sort),
                      onSelected: (value) {
                        context.read<FlashcardProvider>().setSortBy(value);
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'newest', child: Text('Mới nhất')),
                        PopupMenuItem(value: 'name', child: Text('Tên A-Z')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Flashcards list
          Expanded(
            child: Consumer<FlashcardProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.flashcards.isEmpty) {
                  return PandaEmptyState(
                    message: 'Folder này chưa có flashcard nào!\nNhấn nút bên dưới để tạo mới',
                  );
                }

                return RefreshIndicator(
                  onRefresh: provider.loadFlashcards,
                  child: ListView.builder(
                    itemCount: provider.flashcards.length,
                    itemBuilder: (context, index) {
                      final flashcard = provider.flashcards[index];
                      return FlashcardTile(
                        flashcard: flashcard,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/detail',
                            arguments: flashcard,
                          );
                        },
                        onPlayPressed: () {
                          // Play audio inline
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút tạo flashcard text-only
          FloatingActionButton(
            heroTag: 'folder_text_flashcard',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/confirm-transcript',
                arguments: {
                  'audioPath': null,
                  'transcript': '',
                  'duration': 0,
                  'collectionId': widget.collection.id, // Auto-select folder hiện tại
                },
              );
            },
            backgroundColor: AppColors.matchaMedium,
            child: const Icon(Icons.edit, size: 28),
          ),
          const SizedBox(height: 12),
          // Nút ghi âm
          SizedBox(
            width: 80,
            height: 80,
            child: FloatingActionButton(
              heroTag: 'folder_record_flashcard',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/record',
                  arguments: {
                    'collectionId': widget.collection.id, // Auto-select folder hiện tại
                  },
                );
              },
              child: const Icon(Icons.mic, size: 40),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
