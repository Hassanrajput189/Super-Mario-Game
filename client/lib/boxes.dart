import 'package:hive/hive.dart';
import 'package:client/models/progress.dart';

Box<Progress>? _progressBox;

Box<Progress> get progressBox {
  if (_progressBox != null) return _progressBox!;

  if (Hive.isBoxOpen('ProgressBox')) return Hive.box<Progress>('ProgressBox');

  throw StateError('Progress box has not been initialized');
}

set progressBox(Box<Progress> box) => _progressBox = box;
