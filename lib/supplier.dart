import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/app_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Supplier extends StatefulWidget {
  final String username;
  const Supplier({super.key, required this.username});

  @override
  State<Supplier> createState() => _SupplierState();
}

class _SupplierState extends State<Supplier>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
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
          'Suppliers',
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
        bottom: TabBar(
          controller: _tabController!,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.person_add), text: 'New Supplier'),
            Tab(icon: Icon(Icons.list_alt), text: 'Supplier List'),
          ],
        ),
      ),
      drawer: AppDrawer(
        username: widget.username,
        currentPage: 'Suppliers',
      ),
      body: TabBarView(
        controller: _tabController!,
        children: [
          _NewSupplierTab(tabController: _tabController!),
          const _SupplierListTab(),
        ],
      ),
    );
  }
}

// ---- NEW SUPPLIER TAB ----
class _NewSupplierTab extends StatefulWidget {
  final TabController tabController;
  const _NewSupplierTab({required this.tabController});

  @override
  State<_NewSupplierTab> createState() => _NewSupplierTabState();
}

class _NewSupplierTabState extends State<_NewSupplierTab> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _tillController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _tillController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  Future<void> _saveSupplier() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await supabase.from('suppliers').insert({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'till_number': _tillController.text.trim().isEmpty
            ? null
            : _tillController.text.trim(),
        'opening_balance': double.tryParse(
            _openingBalanceController.text.trim()) ??
            0,
      });

      // Clear form
      _nameController.clear();
      _phoneController.clear();
      _tillController.clear();
      _openingBalanceController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplier saved successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Navigate to supplier list tab
        widget.tabController.animateTo(1);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,