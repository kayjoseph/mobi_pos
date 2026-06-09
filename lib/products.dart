import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';

class Products extends StatefulWidget {
  final String username;

  const Products({super.key, required this.username});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // With this — initialize in initState but add a null check safety:
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard},
    {'title': 'Products', 'icon': Icons.inventory_2},
    {'title': 'Sales', 'icon': Icons.point_of_sale},
    {'title': 'Purchases', 'icon': Icons.shopping_cart},
    {'title': 'Expenses', 'icon': Icons.receipt_long},
    {'title': 'Customers', 'icon': Icons.people},
  ];

  void _navigateTo(String title) {
    Navigator.pop(context);
    if (title == 'Dashboard') {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 18,
            child: Text(
              widget.username[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 5),
        ],
        // Tabs just below appbar
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.add_box_outlined), text: 'New Item'),
            Tab(icon: Icon(Icons.list_alt), text: 'Items List'),
            Tab(icon: Icon(Icons.category), text: 'Categories'),
            Tab(icon: Icon(Icons.warehouse), text: 'Stock Manager'),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MobiPos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    radius: 30,
                    child: Text(
                      widget.username[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _menuItems.map((item) {
                  final bool isSelected = item['title'] == 'Products';
                  return ListTile(
                    leading: Icon(
                      item['icon'],
                      color: isSelected ? Colors.green : Colors.grey[700],
                    ),
                    title: Text(
                      item['title'],
                      style: TextStyle(
                        color: isSelected ? Colors.green : Colors.black,
                        fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    tileColor: isSelected ? Colors.green[50] : null,
                    onTap: () => _navigateTo(item['title']),
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: _logout,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),

      // Tab content
      body: TabBarView(
        controller: _tabController,
        children: const [
          _NewItemTab(),
          _ItemsListTab(),
          _CategoriesTab(),
          _StockManagerTab(),
        ],
      ),
    );
  }
}

// ---- TAB WIDGETS ----

class _NewItemTab extends StatelessWidget {
  const _NewItemTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('New Item Form — coming soon',
          style: TextStyle(fontSize: 18, color: Colors.grey)),
    );
  }
}

class _ItemsListTab extends StatelessWidget {
  const _ItemsListTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Items List — coming soon',
          style: TextStyle(fontSize: 18, color: Colors.grey)),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Categories — coming soon',
          style: TextStyle(fontSize: 18, color: Colors.grey)),
    );
  }
}

class _StockManagerTab extends StatelessWidget {
  const _StockManagerTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Stock Manager — coming soon',
          style: TextStyle(fontSize: 18, color: Colors.grey)),
    );
  }
}