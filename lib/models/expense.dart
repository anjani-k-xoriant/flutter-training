import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime date;

  @HiveField(4)
  bool isSynced; // false = pending sync

  @HiveField(5)
  String localId; // UUID for deduplication

  @HiveField(6)
  bool isDeleted;

  @HiveField(7)
  DateTime? deletedAt;

  Expense({
    required this.title,
  required this.amount,
  required this.category,
  required this.date,
  required this.localId,
  this.isSynced = false,
  this.isDeleted = false,
  this.deletedAt,
  });
}
