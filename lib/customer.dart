import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/app_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Customer extends StatefulWidget {
  final String username;
  const Customer({super.key, required this.username});

  @override
  State<Customer> createState() => _CustomerState();
}

class _CustomerState extends State<Customer>
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
          'Customers',
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
            Tab(icon: Icon(Icons.person_add), text: 'New Customer'),
            Tab(icon: Icon(Icons.list_alt), text: 'Customer List'),
          ],
        ),
      ),
      drawer: AppDrawer(
        username: widget.username,
        currentPage: 'Customers',
      ),
      body: TabBarView(
        controller: _tabController!,
        children: [
          _NewCustomerTab(tabController: _tabController!),
          const _CustomerListTab(),
        ],
      ),
    );
  }
}

// ---- NEW CUSTOMER TAB ----
class _NewCustomerTab extends StatefulWidget {
  final TabController tabController;
  const _NewCustomerTab({required this.tabController});

  @override
  State<_NewCustomerTab> createState() => _NewCustomerTabState();
}

class _NewCustomerTabState extends State<_NewCustomerTab> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _openingBalanceController.clear();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await supabase.from('customers').insert({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        'address': _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        'opening_balance':
        double.tryParse(_openingBalanceController.text.trim()) ??
            0,
      });

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer saved successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
              'Customer Details',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Customer Name *',
                hintText: 'e.g. John Doe',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) => value!.trim().isEmpty
                  ? 'Customer name is required'
                  : null,
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'e.g. 0712345678',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                counterText: '',
              ),
              validator: (value) {
                if (value!.trim().isEmpty) {
                  return 'Phone number is required';
                }
                if (value.trim().length < 10) {
                  return 'Phone must be 10 digits';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email (optional)',
                hintText: 'e.g. john@email.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address (optional)',
                hintText: 'e.g. Nairobi, Kenya',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Opening balance
            TextFormField(
              controller: _openingBalanceController,
              keyboardType: const TextInputType.numberWithOptions(
                  signed: true, decimal: true),
              decoration: const InputDecoration(
                labelText: 'Opening Balance (optional)',
                hintText: 'e.g. -500 for advance, 500 for outstanding',
                prefixText: 'KES ',
                prefixIcon: Icon(Icons.account_balance_wallet),
                border: OutlineInputBorder(),
                helperText:
                '( -ve = advance payment, +ve = outstanding balance)',
                helperMaxLines: 2,
              ),
            ),
            const SizedBox(height: 30),

            // Buttons
            Row(
              children: [
                // Cancel
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _clearForm,
                    icon: const Icon(Icons.clear, color: Colors.white),
                    label: const Text(
                      'Cancel',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.orange),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Save
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveCustomer,
                    icon: _isSaving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : const Icon(Icons.save, color: Colors.white),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save Customer',
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
          ],
        ),
      ),
    );
  }
}

// ---- CUSTOMER LIST TAB ----
class _CustomerListTab extends StatefulWidget {
  const _CustomerListTab();

  @override
  State<_CustomerListTab> createState() => _CustomerListTabState();
}

class _CustomerListTabState extends State<_CustomerListTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _customers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('customers')
          .select()
          .order('name');
      setState(() {
        _customers = List<Map<String, dynamic>>.from(data);
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

  Future<void> _showEditDialog(Map<String, dynamic> customer) async {
    final nameController =
    TextEditingController(text: customer['name']);
    final phoneController =
    TextEditingController(text: customer['phone'] ?? '');
    final emailController =
    TextEditingController(text: customer['email'] ?? '');
    final addressController =
    TextEditingController(text: customer['address'] ?? '');
    final balanceController = TextEditingController(
        text: customer['opening_balance']?.toString() ?? '0');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8),
            Text('Edit Customer'),
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
                    labelText: 'Customer Name *',
                    prefixIcon: Icon(Icons.person),
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
                  maxLength: 10,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number *',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) {
                      return 'Phone is required';
                    }
                    if (value.trim().length < 10) {
                      return 'Phone must be 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (optional)',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address (optional)',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                      signed: true, decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Opening Balance',
                    prefixText: 'KES ',
                    prefixIcon:
                    Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(),
                    helperText:
                    'Negative = advance, Positive = outstanding',
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
                await supabase.from('customers').update({
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'email': emailController.text.trim().isEmpty
                      ? null
                      : emailController.text.trim(),
                  'address': addressController.text.trim().isEmpty
                      ? null
                      : addressController.text.trim(),
                  'opening_balance':
                  double.tryParse(balanceController.text) ?? 0,
                }).eq('id', customer['id']);
                _fetchCustomers();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Customer updated'),
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

  Future<void> _deleteCustomer(Map<String, dynamic> customer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Customer'),
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
              '"${customer['name']}"?',
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
            .from('customers')
            .delete()
            .eq('id', customer['id']);
        _fetchCustomers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Customer deleted'),
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
                  '${_customers.length} customer${_customers.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _fetchCustomers,
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
                  child: Text('Curr. Bal',
                      textAlign: TextAlign.center,
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
                : _customers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 60,
                      color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  const Text('No customers yet',
                      style: TextStyle(
                          color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _customers.length,
              itemBuilder: (context, index) {
                final customer = _customers[index];
                final isEven = index % 2 == 0;
                final balance =
                (customer['opening_balance'] ?? 0)
                    .toDouble();
                final isNegative = balance < 0;
                final isZero = balance == 0;

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
                          customer['id']
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
                          customer['name'],
                          style: const TextStyle(
                              fontWeight:
                              FontWeight.w600,
                              fontSize: 13),
                          overflow:
                          TextOverflow.ellipsis,
                        ),
                      ),
                      // Balance
                      Expanded(
                        flex: 2,
                        child: Text(
                          balance == 0
                              ? 'KES 0.00'
                              : 'KES ${balance.toStringAsFixed(2)}',
                          textAlign: TextAlign.center,  // 👈 add this
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
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
                                      customer),
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
                                  _deleteCustomer(
                                      customer),
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