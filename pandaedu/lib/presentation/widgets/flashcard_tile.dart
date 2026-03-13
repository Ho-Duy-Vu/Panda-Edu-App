import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/flashcard.dart';
import '../../core/constants.dart';

class FlashcardTile extends StatelessWidget {
  final Flashcard flashcard;
  final VoidCallback onTap;
  final VoidCallback? onPlayPressed;

  const FlashcardTile({
    super.key,
    required this.flashcard,
    required this.onTap,
    this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMedium,
        vertical: AppSizes.paddingSmall,
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.matchaLight,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            child: Image.asset(
              'assets/images/panda_placeholder.webp',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          flashcard.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              flashcard.transcript,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(flashcard.createdAt),
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_outline),
          color: AppColors.matchaMedium,
          onPressed: onPlayPressed,
        ),
      ),
    );
  }
}
