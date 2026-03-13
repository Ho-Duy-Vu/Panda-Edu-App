import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../providers/collection_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/flashcard_tile.dart';
import '../widgets/panda_empty_state.dart';
import '../../core/constants.dart';
import '../../domain/entities/collection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCollectionId;

  @override
  void initState() {
    super.initState();
    // Nhận collectionId từ arguments nếu user tap vào folder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('collectionId')) {
        _selectedCollectionId = args['collectionId'];
        context.read<FlashcardProvider>().setCollectionFilter(_selectedCollectionId);
      } else {
        // Nếu không có args → clear filter để về tất cả flashcards
        _selectedCollectionId = null;
        context.read<FlashcardProvider>().clearCollectionFilter();
        context.read<FlashcardProvider>().setSearchQuery(''); // Clear search
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check lại arguments mỗi khi dependencies change (khi quay lại trang này)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args == null || !args.containsKey('collectionId')) {
        // Không có filter args → clear filter
        if (_selectedCollectionId != null) {
          setState(() => _selectedCollectionId = null);
          context.read<FlashcardProvider>().clearCollectionFilter();
          context.read<FlashcardProvider>().setSearchQuery('');
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Clear filter khi rời khỏi trang
    context.read<FlashcardProvider>().clearCollectionFilter();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<FlashcardProvider>(
          builder: (context, provider, _) {
            if (provider.filterByCollectionId != null) {
              // Nếu đang filter theo collection, show collection name
              return Consumer<CollectionProvider>(
                builder: (context, collProvider, _) {
                  final collection = collProvider.collections
                      .firstWhere(
                        (c) => c.id == provider.filterByCollectionId,
                        orElse: () => Collection(
                          id: '',
                          name: 'Chưa phân loại',
                          createdAt: DateTime.now(),
                        ),
                      );
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(collection.name),
                      Text(
                        'by VUHO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  );
                },
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PandaEdu'),
                Text(
                  'by VUHO',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          // Nút clear filter nếu đang filter
          Consumer<FlashcardProvider>(
            builder: (context, provider, _) {
              if (provider.filterByCollectionId != null) {
                return IconButton(
                  icon: const Icon(Icons.clear),
                  tooltip: 'Xem tất cả',
                  onPressed: () {
                    provider.clearCollectionFilter();
                    setState(() => _selectedCollectionId = null);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            tooltip: 'Bộ sưu tập',
            onPressed: () {
              Navigator.pushNamed(context, '/collections');
            },
          ),
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () {
              Navigator.pushNamed(context, '/study');
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Row(
                      children: [
                        const Icon(Icons.brightness_6),
                        const SizedBox(width: 8),
                        Text(themeProvider.isDarkMode
                            ? 'Chế độ sáng'
                            : 'Chế độ tối'),
                      ],
                    ),
                    onTap: () {
                      themeProvider.toggleTheme();
                    },
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings),
                        SizedBox(width: 8),
                        Text('Cài đặt'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'settings') {
                    Navigator.pushNamed(context, '/settings');
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Tìm kiếm flashcard...',
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(
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
                PopupMenuButton<String>(
                  icon: const Icon(Icons.sort),
                  onSelected: (value) {
                    context.read<FlashcardProvider>().setSortBy(value);
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'newest', child: Text('Mới nhất')),
                    PopupMenuItem(value: 'name', child: Text('Tên A-Z')),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<FlashcardProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.flashcards.isEmpty) {
                  return const PandaEmptyState(
                    message: 'Chưa có flashcard nào!\nNhấn nút bên dưới để tạo mới',
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
            heroTag: 'text_flashcard',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/confirm-transcript',
                arguments: {
                  'audioPath': null,
                  'transcript': '',
                  'duration': 0,
                  'collectionId': _selectedCollectionId, // Pass collection nếu user đang xem folder cụ thể
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
              heroTag: 'record_flashcard',
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/record',
                  arguments: {
                    'collectionId': _selectedCollectionId, // Pass collection nếu user đang xem folder cụ thể
                  },
                );
              },
              child: const Icon(Icons.mic, size: 40),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
