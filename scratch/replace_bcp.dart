import 'dart:io';

final List<String> dirsToProcess = [
  r"C:\Users\HADE\Downloads\CAJA-TACNA---HADE-main\bancobcp",
  r"C:\Users\HADE\Downloads\CAJA-TACNA---HADE-main\bancobcp-para asesores",
];

final List<Map<String, dynamic>> replacements = [
  {'pattern': RegExp(r'Banco BCP', caseSensitive: false), 'repl': 'Caja Tacna'},
  {'pattern': RegExp(r'banco bcp', caseSensitive: false), 'repl': 'caja tacna'},
  {'pattern': RegExp(r'bancobcp', caseSensitive: false), 'repl': 'cajatacna'},
  {'pattern': RegExp(r'BancoBcp'), 'repl': 'CajaTacna'},
  {'pattern': RegExp(r'\bBCP\b'), 'repl': 'CAJATACNA'},
  {'pattern': RegExp(r'\bbcp\b'), 'repl': 'cajatacna'},
];

final Set<String> excludeDirs = {'.git', 'build', '.dart_tool', 'Pods'};
final Set<String> excludeExtensions = {'.png', '.jpg', '.jpeg', '.zip', '.exe', '.dll', '.so', '.dylib', '.ico'};

void main() async {
  int modifiedCount = 0;

  for (final dirPath in dirsToProcess) {
    final dir = Directory(dirPath);
    if (!await dir.exists()) continue;

    final entities = dir.listSync(recursive: true, followLinks: false);

    for (final entity in entities) {
      if (entity is! File) continue;

      bool skip = false;
      for (final exclude in excludeDirs) {
        if (entity.path.contains(Platform.pathSeparator + exclude + Platform.pathSeparator) ||
            entity.path.endsWith(Platform.pathSeparator + exclude)) {
          skip = true;
          break;
        }
      }
      if (skip) continue;

      final ext = entity.path.substring(entity.path.lastIndexOf('.')).toLowerCase();
      if (excludeExtensions.contains(ext)) continue;

      try {
        final originalContent = await entity.readAsString();
        String content = originalContent;

        for (final r in replacements) {
          content = content.replaceAllMapped((r['pattern'] as RegExp), (match) => r['repl'] as String);
        }

        if (content != originalContent) {
          await entity.writeAsString(content);
          print('Modified: ${entity.path}');
          modifiedCount++;
        }
      } catch (e) {
        // Skip files that can't be read as text
      }
    }
  }

  print('Total files modified: $modifiedCount');
}
