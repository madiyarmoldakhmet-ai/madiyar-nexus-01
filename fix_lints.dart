import 'dart:io';

void main() {
  final filesWithOpacity = [
    'lib/core/theme.dart',
    'lib/screens/user_search_screen.dart',
    'lib/views/call_screen.dart',
    'lib/views/login_view.dart',
    'lib/views/profile_editor_view.dart',
  ];

  for (final path in filesWithOpacity) {
    final file = File('/Users/gulnaz_7580mail.ru/.gemini/antigravity/scratch/madibook/$path');
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();
    content = content.replaceAllMapped(RegExp(r'\.withOpacity\((.*?)\)'), (match) {
      return '.withValues(alpha: ${match.group(1)})';
    });
    file.writeAsStringSync(content);
  }

  final filesWithPrint = [
    'lib/features/social/data/repositories/firebase_chat_repository.dart',
    'lib/screens/private_chat_screen.dart',
    'lib/screens/user_search_screen.dart',
    'lib/views/profile_editor_view.dart',
  ];

  for (final path in filesWithPrint) {
    final file = File('/Users/gulnaz_7580mail.ru/.gemini/antigravity/scratch/madibook/$path');
    if (!file.existsSync()) continue;
    var content = file.readAsStringSync();
    content = content.replaceAll(RegExp(r'\bprint\('), 'debugPrint(');
    
    if (content.contains('debugPrint(') && !content.contains("import 'package:flutter/material.dart';") && !content.contains("import 'package:flutter/foundation.dart';")) {
      content = "import 'package:flutter/foundation.dart';\n" + content;
    }
    file.writeAsStringSync(content);
  }

  // Unused imports
  final profileEditor = File('/Users/gulnaz_7580mail.ru/.gemini/antigravity/scratch/madibook/lib/views/profile_editor_view.dart');
  if (profileEditor.existsSync()) {
    var content = profileEditor.readAsStringSync();
    content = content.replaceAll("import '../view_models/app_state.dart';\n", "");
    profileEditor.writeAsStringSync(content);
  }

  print('Done!');
}
