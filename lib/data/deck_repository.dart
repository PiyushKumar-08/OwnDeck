import 'database.dart';
import 'package:drift/drift.dart';

class DeckRepository {
  final AppDatabase _db;

  DeckRepository(this._db);

  /// 🔹 All items (real-time)
  Stream<List<Item>> watchAllItems() {
    return _db.select(_db.items).watch();
  }

  /// 🔹 Filter by category
  Stream<List<Item>> watchItemsByCategory(String? category) {
    if (category == null || category == 'All Items') {
      return watchAllItems();
    }

    return (_db.select(_db.items)
          ..where((tbl) => tbl.category.equals(category)))
        .watch();
  }

  /// 🔹 Items expiring within next X days
  Stream<int> watchExpiringCount(int days) {
    final now = DateTime.now();
    final limit = now.add(Duration(days: days));

    return (_db.select(_db.items)
          ..where((tbl) => tbl.warrantyEnd.isSmallerOrEqualValue(limit)))
        .watch()
        .map((items) => items.length);
  }

  /// 🔹 Total items count
  Stream<int> watchTotalCount() {
    return _db.customSelect(
      'SELECT COUNT(*) as c FROM items',
    ).watchSingle().map((row) => row.read<int>('c'));
  }
}
