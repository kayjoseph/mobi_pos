import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/products.dart';
import 'package:mobi_pos/sales.dart';
import 'package:mobi_pos/purchase.dart';

class Expense extends StatefulWidget {
  final String username;
  const Expense({super.key, required this.username});

  @override
  State<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _salesExpanded = false;

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  final List<Map<String, dynamic>> _menuItems = [
    {'title': 'Dashboard', 'icon': Icons.dashboard},
    {'title': 'Products', 'icon': Icons.inventory_2},
    {
      'title': 'Sales',
      'icon': Icons.point_of_sale,
      'children': [
        {'title': 'Sales', 'icon': Icons.receipt},
        {'title': 'Sales Return', 'icon': Icons.assignment_return},
        {'title': 'Cancelled Sales', 'icon': Icons.cancel},
      ]
    },
    {'title': 'Purchases', 'icon': Icons.shopping_cart},
    {'title': 'Suppliers', 'icon': Icons.store},
    {'title': 'Customers', 'icon': Icons.people},
    {'title': 'Expenses', 'icon': Icons.receipt_long},
    {'title': 'Users', 'icon': Icons.manage_accounts},
    {'title': 'Settings', 'icon': Icons.settings},
  ];

  void _navigateTo(String title) {
    Navigator.pop(context);
    switch (title) {
      case 'Dashboard':
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 'Products':
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) =>
                    Products(username: widget.username)));
        break;
      case 'Sales':
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) =>
                    Sales(username: widget.username)));
        break;
      case 'Purchases':
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) =>
                    Purchase(username: widget.username)));
        break;
      case 'Expenses':
      // already here
        break;
      default:
        break;
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
          'Expenses',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 18,
            child: Text(
              widget.username[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.green,
              padding: const EdgeInsets.symmetric(
                  vertical: 40, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MobiPos',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    backgroundColor: Colors.orange,
                    radius: 30,
                    child: Text(
                      widget.username[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(widget.username,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _menuItems.map((item) {
                  final bool isSelected =
                      item['title'] == 'Expenses';

                  if (item['children'] != null) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(item['icon'],
                              color: _salesExpanded
                                  ? Colors.green
                                  : Colors.grey[700]),
                          title: Text(item['title'],
                              style: TextStyle(
                                  color: _salesExpanded
                                      ? Colors.green
                                      : Colors.black,
                                  fontWeight: _salesExpanded
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                          trailing: Icon(
                              _salesExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: _salesExpanded
                                  ? Colors.green
                                  : Colors.grey),
                          onTap: () => setState(
                                  () => _salesExpanded = !_salesExpanded),
                        ),
                        if (_salesExpanded)
                          ...item['children'].map<Widget>((child) {
                            return ListTile(
                              contentPadding:
                              const EdgeInsets.only(left: 40),
                              leading: Icon(child['icon'],
                                  color: Colors.grey[600], size: 20),
                              title: Text(child['title'],
                                  style:
                                  const TextStyle(fontSize: 14)),
                              onTap: () {
                                Navigator.pop(context);
                                if (child['title'] == 'Sales') {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Sales(
                                            username:
                                            widget.username)),
                                  );
                                }
                              },
                            );
                          }).toList(),
                      ],
                    );
                  }

                  return ListTile(
                    leading: Icon(item['icon'],
                        color: isSelected
                            ? Colors.green
                            : Colors.grey[700]),
                    title: Text(item['title'],
                        style: TextStyle(
                            color: isSelected
                                ? Colors.green
                                : Colors.black,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal)),
                    tileColor: isSelected ? Colors.green[50] : null,
                    onTap: () => _navigateTo(item['title']),
                  );
                }).toList(),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout',
                  style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold)),
              onTap: _logout,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Expenses — Coming Soon',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey),
        ),
      ),
    );
  }
}