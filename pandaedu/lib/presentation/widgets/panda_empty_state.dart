import 'package:flutter/material.dart';
import '../../core/constants.dart';

class PandaEmptyState extends StatelessWidget {
  final String message;
  final String? imagePath;
  final VoidCallback? onActionPressed;
  final String? actionText;

  const PandaEmptyState({
    super.key,
    required this.message,
    this.imagePath,
    this.onActionPressed,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              Image.asset(
                imagePath!,
                width: 200,
                height: 200,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.sentiment_neutral,
                    size: 100,
                    color: AppColors.matchaLight,
                  );
                },
              )
            else
              Image.asset(
                'assets/images/panda_placeholder.webp',
                width: 120,
                height: 120,
              ),
            const SizedBox(height: AppSizes.paddingLarge),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.pandaBlack,
              ),
              textAlign: TextAlign.center,
            ),
            if (onActionPressed != null && actionText != null) ...[
              const SizedBox(height: AppSizes.paddingLarge),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
