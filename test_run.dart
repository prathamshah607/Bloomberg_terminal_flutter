import 'dart:io';

void main() async {
  final workingDir = "${Directory.current.path}/lib/backend";
  print('Working dir: $workingDir');
  try {
    final p = await Process.start("venv/bin/python", ["-m", "uvicorn", "main:app", "--port", "8000"], workingDirectory: workingDir);
    p.stdout.listen((d) => stdout.add(d));
    p.stderr.listen((d) => stderr.add(d));
    print('Started process ${p.pid}');
    await Future.delayed(Duration(seconds: 3));
    p.kill();
  } catch (e) {
    print('Error: $e');
  }
}
