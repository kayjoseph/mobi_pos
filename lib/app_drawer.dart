import 'package:flutter/material.dart';
import 'package:mobi_pos/customer.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/home.dart';
import 'package:mobi_pos/products.dart';
import 'package:mobi_pos/sales.dart';
import 'package:mobi_pos/purchase.dart';
import 'package:mobi_pos/expense.dart';
import 'package:mobi_pos/supplier.dart';
import 'package:mobi_pos/reports.dart';

class AppDrawer extends StatefulWidget {
  final String username;
  final String currentPage;

  const AppDrawer({
    super.key,
    required this.username,
    required this.currentPage,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  bool _salesExpanded = false;
  bool _reportsExpanded = false;

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
    {
      'title': 'Reports',
      'icon': Icons.bar_chart,
      'children': [
        {'title': 'Accounting Reports', 'icon': Icons.account_balance},
        {'title': 'Sales Report', 'icon': Icons.point_of_sale},
        {'title': 'Purchase Report', 'icon': Icons.shopping_cart},
      ]
    },
    {'title': 'Users', 'icon': Icons.manage_accounts},
    {'title': 'Settings', 'icon': Icons.settings},
  ];

  void _navigateTo(BuildContext context, String title) {
    Navigator.pop(context);

    if (title == widget.currentPage) return;

    switch (title) {
      case 'Dashboard':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => Home(username: widget.username)),
              (route) => false,
        );
        break;
      case 'Products':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Products(username: widget.username)),
              (route) => false,
        );
        break;
      case 'Sales':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => Sales(username: widget.username)),
              (route) => false,
        );
        break;
      case 'Purchases':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Purchase(username: widget.username)),
              (route) => false,
        );
        break;
      case 'Expenses':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Expense(username: widget.username)),
              (route) => false,
        );
        break;
      case 'Suppliers':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Supplier(username: widget.username)),
              (route) => false,
        );
        break;
      case 'Customers':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Customer(username: widget.username)),
              (route) => false,
        );
        break;
      case 'Accounting Reports':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AccountingReports(username: widget.username)),
              (route) => false,
        );
        break;
      case 'Sales Report':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SalesReport(username: widget.username)),
              (route) => false,
        );
        break;
      case 'Purchase Report':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  PurchaseReport(username: widget.username)),
              (route) => false,
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title — Coming Soon'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            color: Colors.green,
            padding: const EdgeInsets.symmetric(
                vertical: 40, horizontal: 20),
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

          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: _menuItems.map((item) {
                final bool isSelected =
                    widget.currentPage == item['title'];

                // Expandable items (Sales + Reports)
                if (item['children'] != null) {
                  final bool isSalesPage =
                      widget.currentPage == 'Sales' ||
                          widget.currentPage == 'Sales Return' ||
                          widget.currentPage == 'Cancelled Sales';

                  final bool isReportsPage =
                      widget.currentPage == 'Accounting Reports' ||
                          widget.currentPage == 'Sales Report' ||
                          widget.currentPage == 'Purchase Report';

                  final bool isThisExpanded =
                  item['title'] == 'Sales'
                      ? _salesExpanded || isSalesPage
                      : _reportsExpanded || isReportsPage;

                  final bool isThisPage = item['title'] == 'Sales'
                      ? isSalesPage
                      : isReportsPage;

                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          item['icon'],
                          color: isThisPage || isThisExpanded
                              ? Colors.green
                              : Colors.grey[700],
                        ),
                        title: Text(
                          item['title'],
                          style: TextStyle(
                            color: isThisPage || isThisExpanded
                                ? Colors.green
                                : Colors.black,
                            fontWeight: isThisPage || isThisExpanded
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          isThisExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: isThisPage || isThisExpanded
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onTap: () {
                          setState(() {
                            if (item['title'] == 'Sales') {
                              _salesExpanded = !_salesExpanded;
                            } else {
                              _reportsExpanded = !_reportsExpanded;
                            }
                          });
                        },
                      ),
                      if (isThisExpanded)
                        ...item['children'].map<Widget>((child) {
                          final bool isChildSelected =
                              widget.currentPage == child['title'];
                          return ListTile(
                            contentPadding:
                            const EdgeInsets.only(left: 40),
                            leading: Icon(
                              child['icon'],
                              color: isChildSelected
                                  ? Colors.green
                                  : Colors.grey[600],
                              size: 20,
                            ),
                            title: Text(
                              child['title'],
                              style: TextStyle(
                                fontSize: 14,
                                color: isChildSelected
                                    ? Colors.green
                                    : Colors.black,
                                fontWeight: isChildSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            tileColor: isChildSelected
                                ? Colors.green[50]
                                : null,
                            onTap: () =>
                                _navigateTo(context, child['title']),
                          );
                        }).toList(),
                    ],
                  );
                }

                // Regular items
                return ListTile(
                  leading: Icon(
                    item['icon'],
                    color: isSelected
                        ? Colors.green
                        : Colors.grey[700],
                  ),
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      color:
                      isSelected ? Colors.green : Colors.black,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  tileColor: isSelected ? Colors.green[50] : null,
                  onTap: () => _navigateTo(context, item['title']),
                );
              }).toList(),
            ),
          ),

          // Logout
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginPage()),
                    (route) => false,
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}