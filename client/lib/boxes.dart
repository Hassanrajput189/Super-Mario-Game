import 'package:hive/hive.dart';
import 'package:client/models/progress.dart';

Box<Progress>? _progressBox;

Box<Progress> get progressBox {
  if (_progressBox != null) return _progressBox!;

  if (Hive.isBoxOpen('ProgressBox')) {
    _progressBox = Hive.box<Progress>('ProgressBox');
    return _progressBox!;
  }

  // Return a throw error - but try to handle gracefully in calling code
  throw StateError('Progress box has not been initialized. Ensure Hive.initFlutter() and Hive.openBox() are called first.');
}

set progressBox(Box<Progress> box) => _progressBox = box;
