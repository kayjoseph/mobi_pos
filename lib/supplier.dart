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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supplier Details',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Supplier Name *',
                hintText: 'e.g. Bidco Africa',
                prefixIcon: Icon(Icons.store),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.trim().isEmpty
                  ? 'Supplier name is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'e.g. 0123456789',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.trim().isEmpty
                  ? 'Phone number is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // Till number
            TextFormField(
              controller: _tillController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Till Number (optional)',
                hintText: 'e.g. 123456',
                prefixIcon: Icon(Icons.point_of_sale),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Opening balance
            TextFormField(
              controller: _openingBalanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Opening Balance (optional)',
                hintText: 'e.g. 5000',
                prefixText: 'KES ',
                prefixIcon: Icon(Icons.account_balance_wallet),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveSupplier,
                icon: _isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Supplier',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- SUPPLIER LIST TAB ----
class _SupplierListTab extends StatefulWidget {
  const _SupplierListTab();

  @override
  State<_SupplierListTab> createState() => _SupplierListTabState();
}

class _SupplierListTabState extends State<_SupplierListTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _suppliers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('suppliers')
          .select()
          .order('name');
      setState(() {
        _suppliers = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> supplier) async {
    final nameController =
    TextEditingController(text: supplier['name']);
    final phoneController =
    TextEditingController(text: supplier['phone'] ?? '');
    final tillController =
    TextEditingController(text: supplier['till_number'] ?? '');
    final balanceController = TextEditingController(
        text: supplier['opening_balance']?.toString() ?? '0');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Edit Supplier'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Supplier Name *',
                    prefixIcon: Icon(Icons.store),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.trim().isEmpty
                      ? 'Phone is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: tillController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Till Number (optional)',
                    prefixIcon: Icon(Icons.point_of_sale),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Opening Balance',
                    prefixText: 'KES ',
                    prefixIcon:
                    Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(context);
              try {
                await supabase.from('suppliers').update({
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'till_number':
                  tillController.text.trim().isEmpty
                      ? null
                      : tillController.text.trim(),
                  'opening_balance':
                  double.tryParse(balanceController.text) ??
                      0,
                }).eq('id', supplier['id']);
                _fetchSuppliers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Supplier updated'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text('Update',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSupplier(
      Map<String, dynamic> supplier) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Supplier'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete:',
                style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              '"${supplier['name']}"?',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber,
                      color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(
                          color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete, color: Colors.white),
            label: const Text('Yes, Delete',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase
            .from('suppliers')
            .delete()
            .eq('id', supplier['id']);
        _fetchSuppliers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Supplier deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '${_suppliers.length} supplier${_suppliers.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _fetchSuppliers,
                icon: const Icon(Icons.refresh,
                    color: Colors.green),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Table header
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 46,
                  child: Text('ID',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Name',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Phone',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                SizedBox(
                  width: 80,
                  child: Text('Actions',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _suppliers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined,
                      size: 60,
                      color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  const Text('No suppliers yet',
                      style: TextStyle(
                          color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _suppliers.length,
              itemBuilder: (context, index) {
                final supplier = _suppliers[index];
                final isEven = index % 2 == 0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isEven
                        ? Colors.grey[50]
                        : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.grey[200]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      // ID
                      SizedBox(
                        width: 46,
                        child: Text(
                          supplier['id']
                              .toString()
                              .padLeft(4, '0'),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight:
                              FontWeight.w500),
                        ),
                      ),
                      // Name
                      Expanded(
                        flex: 3,
                        child: Text(
                          supplier['name'],
                          style: const TextStyle(
                              fontWeight:
                              FontWeight.w600,
                              fontSize: 13),
                          overflow:
                          TextOverflow.ellipsis,
                        ),
                      ),
                      // Phone
                      Expanded(
                        flex: 2,
                        child: Text(
                          supplier['phone'] ?? '-',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey),
                        ),
                      ),
                      // Actions
                      SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 18),
                              padding: EdgeInsets.zero,
                              constraints:
                              const BoxConstraints(),
                              onPressed: () =>
                                  _showEditDialog(
                                      supplier),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 18),
                              padding: EdgeInsets.zero,
                              constraints:
                              const BoxConstraints(),
                              onPressed: () =>
                                  _deleteSupplier(
                                      supplier),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}