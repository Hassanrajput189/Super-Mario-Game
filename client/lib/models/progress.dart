import 'package:hive/hive.dart';
part "progress.g.dart";

@HiveType(typeId: 0)
class Progress extends HiveObject {
  Progress({required this.highScore,required this.date});  
  
  @HiveField(0)
  late int highScore;

  @HiveField(1)
  late DateTime date;
}
