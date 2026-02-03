import 'package:flutter/material.dart';
import '../data/database.dart';
import 'package:drift/drift.dart' show Value;


class AddItemPage extends StatefulWidget {
  final AppDatabase database;

  const AddItemPage({super.key, required this.database});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _name = TextEditingController();
  final _category = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Item")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: _category,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text("Save Item"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    await widget.database.into(widget.database.items).insert(
      ItemsCompanion.insert(
        name: _name.text,
        purchaseDate: DateTime.now(),
        warrantyEnd: DateTime.now().add(const Duration(days: 365)),
        category: Value(_category.text),
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
