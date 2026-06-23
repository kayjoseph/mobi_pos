import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/products.dart';
import 'package:mobi_pos/sales.dart';
import 'package:mobi_pos/purchase.dart';
import 'package:mobi_pos/app_drawer.dart';

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
      drawer: AppDrawer(
        username: widget.username,
        currentPage: 'Expenses',
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