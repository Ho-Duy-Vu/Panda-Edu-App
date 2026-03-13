import 'package:flutter/material.dart';
import '../../core/constants.dart';

class LiveTranscriptView extends StatelessWidget {
  final String transcript;
  final bool isListening;

  const LiveTranscriptView({
    super.key,
    required this.transcript,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        border: Border.all(
          color: isListening ? AppColors.matchaMedium : AppColors.matchaLight,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.mic,
                color: isListening ? AppColors.accentOrange : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Text(
                isListening ? 'Đang nghe...' : 'Không nghe',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isListening ? AppColors.matchaMedium : Colors.grey,
                ),
              ),
              if (isListening) ...[
                const SizedBox(width: AppSizes.paddingSmall),
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.accentOrange),
                  ),
                ),
              ],
            ],
          ),
          const Divider(),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: 100,
              maxHeight: 300,
            ),
            child: SingleChildScrollView(
              child: Text(
                transcript.isEmpty
                    ? 'Nói gì đó để bắt đầu...'
                    : transcript,
                style: TextStyle(
                  fontSize: 16,
                  color: transcript.isEmpty ? Colors.grey : Colors.black,
                  fontStyle:
                      transcript.isEmpty ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
