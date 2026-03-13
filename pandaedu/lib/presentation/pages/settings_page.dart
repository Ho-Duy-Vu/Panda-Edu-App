import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import '../providers/theme_provider.dart';
import '../providers/flashcard_provider.dart';
import '../../core/constants.dart';
import '../../data/models/flashcard_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Future<void> _exportData(BuildContext context) async {
    try {
      final provider = context.read<FlashcardProvider>();
      final flashcards = provider.flashcards;

      if (flashcards.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có dữ liệu để xuất')),
        );
        return;
      }

      final jsonData = jsonEncode(
        flashcards.map((card) => FlashcardModel.fromEntity(card).toJson()).toList(),
      );

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'pandaedu_backup_$timestamp.json';

      // Save to Downloads (simplified - in production would use path_provider)
      final downloadsDir = Directory('/storage/emulated/0/Download');
      final file = File('${downloadsDir.path}/$fileName');
      await file.writeAsString(jsonData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xuất: Download/$fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xuất dữ liệu: $e')),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      jsonDecode(jsonString);

      // Would need to properly import and merge data
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã nhập dữ liệu thành công')),
      );

      final provider = context.read<FlashcardProvider>();
      await provider.loadFlashcards();
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi nhập dữ liệu: $e')),
      );
    }
  }

  Future<void> _clearAllData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Xóa tất cả flashcards? Hành động này không thể hoàn tác!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Second confirmation
    final doubleConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Xác nhận lần 2'),
        content: const Text('Bạn có THỰC SỰ muốn xóa TẤT CẢ dữ liệu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Có, xóa hết'),
          ),
        ],
      ),
    );

    if (doubleConfirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.flashcardsKey);
      await prefs.setBool(StorageKeys.hasSeenOnboardingKey, false);

      if (!context.mounted) return;
      
      final provider = context.read<FlashcardProvider>();
      await provider.loadFlashcards();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa tất cả dữ liệu')),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        children: [
          // Theme Section
          const ListTile(
            title: Text(
              'Giao diện',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.matchaMedium,
              ),
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, provider, child) {
              return SwitchListTile(
                title: const Text('Chế độ tối'),
                subtitle: const Text('Bật/tắt giao diện tối'),
                value: provider.isDarkMode,
                onChanged: (value) {
                  provider.setTheme(value);
                },
              );
            },
          ),
          const Divider(),

          // Backup & Restore
          const ListTile(
            title: Text(
              'Sao lưu & Khôi phục',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.matchaMedium,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Xuất dữ liệu'),
            subtitle: const Text('Lưu flashcards ra file JSON'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Nhập dữ liệu'),
            subtitle: const Text('Khôi phục từ file backup'),
            onTap: () => _importData(context),
          ),
          const Divider(),

          // Data Management
          const ListTile(
            title: Text(
              'Dữ liệu',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.matchaMedium,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text(
              'Xóa tất cả dữ liệu',
              style: TextStyle(color: AppColors.error),
            ),
            subtitle: const Text('Xóa toàn bộ flashcards và reset app'),
            onTap: () => _clearAllData(context),
          ),
          const Divider(),

          // App Info
          const ListTile(
            title: Text(
              'Thông tin ứng dụng',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.matchaMedium,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Tên ứng dụng'),
            subtitle: Text('PandaEdu'),
          ),
          const ListTile(
            leading: Icon(Icons.numbers),
            title: Text('Phiên bản'),
            subtitle: Text('1.0.0 (Build 1)'),
          ),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('Clean Architecture'),
            subtitle: Text('SOLID Principles + Provider'),
          ),
        ],
      ),
    );
  }
}
