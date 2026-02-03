import 'package:flutter/material.dart';
import '../data/database.dart';
import '../data/deck_repository.dart';
import 'deck_item_card.dart';
import '../add_item/add_item_page.dart';
import '../analytics/analytics_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  final AppDatabase database;

  const HomePage({super.key, required this.database});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _navIndex = 0;
  String _selectedCategory = 'All';

  late final DeckRepository repo;

  final categories = ['All', 'Electronics', 'Appliances', 'Furniture'];

  @override
  void initState() {
    super.initState();
    repo = DeckRepository(widget.database);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: IndexedStack(
        index: _navIndex,
        children: [
          _homeDashboard(),
          AnalyticsPage(database: widget.database),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.analytics), label:'Analytics'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _navIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFF2563EB),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddItemPage(database: widget.database),
                  ),
                );
              },
              icon: const Icon(Icons.document_scanner_outlined),
              label: const Text("Scan Bill"),
            )
          : null,
    );
  }

  // ───────────── HOME DASHBOARD ─────────────

  Widget _homeDashboard() {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          _header(),
          _searchBar(),
          _metricsRow(),
          _warrantyCard(),
          _expiringHeader(),
          _itemsList(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ───────────── SECTIONS ─────────────

  SliverToBoxAdapter _header() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:[
            Image.asset(
              'assets/side_logo.png', 
              height: 90,
              fit: BoxFit.contain,
            ),
            CircleAvatar(
              backgroundImage: NetworkImage("https://i.pravatar.cc/100"),
            )
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _searchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          decoration: InputDecoration(
            hintText: "Search invoices, items or help...",
            prefixIcon: const Icon(Icons.search),
            suffixIcon: const Icon(Icons.mic),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _metricsRow() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _Metric("Active", "15"),
            _Metric("Issues", "7"),
            _Metric("Expiring", "2"),
            _Metric("Total", "₹1.2L"),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _warrantyCard() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Warranty Monitor",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                "2 warranties expiring in 28 days",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text("Total value at risk ₹83,999",
                  style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _expiringHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: Wrap(
          spacing: 8,
          children: categories.map((c) {
            return ChoiceChip(
              label: Text(c),
              selected: _selectedCategory == c,
              onSelected: (_) =>
                  setState(() => _selectedCategory = c),
            );
          }).toList(),
        ),
      ),
    );
  }

  SliverToBoxAdapter _itemsList() {
    return SliverToBoxAdapter(
      child: StreamBuilder<List<Item>>(
        stream: repo.watchItemsByCategory(_selectedCategory),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final items = snapshot.data!;

          if (items.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text("No expiring items")),
            );
          }

          return Column(
            children:
                items.map((item) => DeckItemCard(item: item)).toList(),
          );
        },
      ),
    );
  }
}

// ───────────── METRIC WIDGET ─────────────

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
