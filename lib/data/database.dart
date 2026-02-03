import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Required for code generation
part 'database.g.dart'; 

// --- 1. Define the Table ---
class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // Product Name (e.g., "Samsung TV")
  TextColumn get category => text().nullable()(); // e.g., "Electronics"
  DateTimeColumn get purchaseDate => dateTime()();
  DateTimeColumn get warrantyEnd => dateTime()();
  TextColumn get imagePath => text().nullable()(); // Path to local image
  TextColumn get supportPhone => text().nullable()();
}

// --- 2. The Database Class ---
@DriftDatabase(tables: [Items])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

// --- 3. Connection Logic ---
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'owndeck_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}