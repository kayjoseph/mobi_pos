import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/products.dart';
import 'package:mobi_pos/sales.dart';
import 'package:mobi_pos/purchase.dart';

class Home extends StatefulWidget {
  final String username;

  const Home({super.key, required this.username});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _currentPage = 'Dashboard';
  bool _salesExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Welcome, ${widget.username}!',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 10, 0),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            widget.username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'change_password',
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text('Change Password'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'change_password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Change password coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
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
        title: Text(
          _currentPage,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showProfileMenu(context),
            child: CircleAvatar(
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
          ),
          const SizedBox(width: 10),
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
      ),
      drawer: Drawer(
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
                      _currentPage == item['title'];

                  // Sales expandable
                  if (item['children'] != null) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            item['icon'],
                            color: _salesExpanded
                                ? Colors.green
                                : Colors.grey[700],
                          ),
                          title: Text(
                            item['title'],
                            style: TextStyle(
                              color: _salesExpanded
                                  ? Colors.green
                                  : Colors.black,
                              fontWeight: _salesExpanded
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: Icon(
                            _salesExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: _salesExpanded
                                ? Colors.green
                                : Colors.grey,
                          ),
                          onTap: () => setState(
                                  () => _salesExpanded = !_salesExpanded),
                        ),
                        if (_salesExpanded)
                          ...item['children'].map<Widget>((child) {
                            return ListTile(
                              contentPadding:
                              const EdgeInsets.only(left: 40),
                              leading: Icon(
                                child['icon'],
                                color: Colors.grey[600],
                                size: 20,
                              ),
                              title: Text(
                                child['title'],
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                if (child['title'] == 'Sales') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Sales(
                                          username: widget.username),
                                    ),
                                  );
                                }
                                // Sales Return + Cancelled Sales — coming soon
                              },
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
                    onTap: () => _navigate(item['title']),
                  );
                }).toList(),
              ),
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Logout',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: _logout,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      body: Center(
        child: Text(
          '$_currentPage Module',
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}