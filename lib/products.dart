import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobi_pos/sales.dart';
import 'package:mobi_pos/purchase.dart';
import 'package:mobi_pos/expense.dart';

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
// Replace the _menuItems list:
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
    {'title': 'Expenses', 'icon': Icons.receipt_long},
    {'title': 'Customers', 'icon': Icons.people},
  ];

// Add this to your state variables:
  bool _salesExpanded = false;
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
        Navigator.pushReplacement(context,
            MaterialPageRoute(
                builder: (context) =>
                    Expense(username: widget.username)));
        break;
    // Others coming soon — do nothing for now
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
          'Products',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // actions: [
        //   CircleAvatar(
        //     backgroundColor: Colors.orange,
        //     radius: 18,
        //     child: Text(
        //       widget.username[0].toUpperCase(),
        //       style: const TextStyle(
        //         color: Colors.white,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ),
        //   const SizedBox(width: 10),
        //   TextButton.icon(
        //     onPressed: _logout,
        //     icon: const Icon(Icons.logout, color: Colors.white),
        //     label: const Text(
        //       'Logout',
        //       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        //     ),
        //     style: TextButton.styleFrom(
        //       backgroundColor: Colors.red,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(8),
        //       ),
        //     ),
        //   ),
        //   const SizedBox(width: 5),
        // ],

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

                  // Sales item with expandable children
                  if (item['children'] != null) {
                    return Column(
                      children: [
                        // Sales parent item
                        ListTile(
                          leading: Icon(
                            item['icon'],
                            color: _salesExpanded ? Colors.green : Colors.grey[700],
                          ),
                          title: Text(
                            item['title'],
                            style: TextStyle(
                              color: _salesExpanded ? Colors.green : Colors.black,
                              fontWeight: _salesExpanded
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: Icon(
                            _salesExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: _salesExpanded ? Colors.green : Colors.grey,
                          ),
                          onTap: () {
                            setState(() => _salesExpanded = !_salesExpanded);
                          },
                        ),
                        // Dropdown children
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
                                Navigator.pop(context); // close drawer
                                if (child['title'] == 'Sales') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          Sales(username: widget.username),
                                    ),
                                  );
                                } else if (child['title'] == 'Sales Return') {
                                  // Navigate to Sales Return later
                                } else if (child['title'] == 'Cancelled Sales') {
                                  // Navigate to Cancelled Sales later
                                }
                              },
                            );
                          }).toList(),
                      ],
                    );
                  }

                  // Regular menu items
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
                    onTap: () {
                      Navigator.pop(context);
                      if (item['title'] == 'Products') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                Products(username: widget.username),
                          ),
                        );
                      } else {
                        final bool isSelected = item['title'] == 'Products';
                      }
                    },
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
        controller: _tabController!,
        children: [
          _NewItemTab(tabController: _tabController!), // 👈 pass controller
          const _ItemsListTab(),
          const _CategoriesTab(),
          const _StockManagerTab(),
        ],
      ),
    );
  }
}

// ---- NEW ITEM TAB ----
class _NewItemTab extends StatefulWidget {
  final TabController tabController;
  const _NewItemTab({required this.tabController});

  @override
  State<_NewItemTab> createState() => _NewItemTabState();
}

class _NewItemTabState extends State<_NewItemTab> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _buyingPriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _openingStockController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;
  bool _isFetchingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _openingStockController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final data = await supabase
          .from('categories')
          .select('id, name')
          .order('name');
      setState(() {
        _categories = List<Map<String, dynamic>>.from(data);
        _isFetchingCategories = false;
      });
    } catch (e) {
      setState(() => _isFetchingCategories = false);
    }
  }

  void _clearForm() {
    _nameController.clear();
    _barcodeController.clear();
    _buyingPriceController.clear();
    _sellingPriceController.clear();
    _openingStockController.clear();
    setState(() => _selectedCategoryId = null);
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Save product
      final productResult = await supabase.from('products').insert({
        'name': _nameController.text.trim(),
        'barcode': _barcodeController.text.trim().isEmpty
            ? null
            : _barcodeController.text.trim(),
        'category_id': _selectedCategoryId,
        'buying_price': double.tryParse(_buyingPriceController.text) ?? 0,
        'selling_price': double.parse(_sellingPriceController.text),
        'opening_stock': double.tryParse(_openingStockController.text) ?? 0,
      }).select().single();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      _clearForm();

      // Navigate to Items List tab (index 1)
      widget.tabController.animateTo(1);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
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
              'Item Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Item Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                hintText: 'e.g. Coca Cola 500ml',
                prefixIcon: Icon(Icons.inventory_2),
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
              value!.isEmpty ? 'Please enter item name' : null,
            ),
            const SizedBox(height: 16),

            // Barcode
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                labelText: 'Barcode (optional)',
                hintText: 'e.g. 6001234567890',
                prefixIcon: Icon(Icons.qr_code),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Category dropdown
            _isFetchingCategories
                ? const LinearProgressIndicator()
                : DropdownButtonFormField<int>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: 'Category *',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem<int>(
                  value: cat['id'] as int,
                  child: Text(cat['name']),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategoryId = value),
              validator: (value) =>
              value == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // Buying & Selling Price side by side
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _buyingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Buying Price',
                      prefixIcon: Icon(Icons.arrow_downward, color: Colors.red),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _sellingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Selling Price *',
                      prefixIcon:
                      Icon(Icons.arrow_upward, color: Colors.green),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Opening Stock
            TextFormField(
              controller: _openingStockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Opening Stock',
                hintText: 'e.g. 100',
                prefixIcon: Icon(Icons.warehouse),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveItem,
                icon: _isLoading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
                    : const Icon(Icons.save, color: Colors.white),
                label: Text(
                  _isLoading ? 'Saving...' : 'Save Item',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- ITEMS LIST TAB ----
class _ItemsListTab extends StatefulWidget {
  const _ItemsListTab();

  @override
  State<_ItemsListTab> createState() => _ItemsListTabState();
}

class _ItemsListTabState extends State<_ItemsListTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('products')
          .select('id, name, barcode, buying_price, selling_price, opening_stock, categories(id, name)')
          .order('id');
      setState(() {
        _products = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where((p) => p['name']
        .toString()
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _showEditDialog(Map<String, dynamic> product) async {
    final nameController =
    TextEditingController(text: product['name']);
    final barcodeController =
    TextEditingController(text: product['barcode'] ?? '');
    final buyingPriceController =
    TextEditingController(text: product['buying_price']?.toString() ?? '0');
    final sellingPriceController =
    TextEditingController(text: product['selling_price']?.toString() ?? '0');
    final formKey = GlobalKey<FormState>();

    // Fetch categories for dropdown
    List<Map<String, dynamic>> categories = [];
    int? selectedCategoryId = product['categories'] != null
        ? product['categories']['id'] as int?
        : null;

    try {
      final catData = await supabase
          .from('categories')
          .select('id, name')
          .order('name');
      categories = List<Map<String, dynamic>>.from(catData);
    } catch (_) {}

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit, color: Colors.blue),
              SizedBox(width: 8),
              Text('Edit Item'),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Item name
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name *',
                      prefixIcon: Icon(Icons.inventory_2),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter item name' : null,
                  ),
                  const SizedBox(height: 12),

                  // Barcode
                  TextFormField(
                    controller: barcodeController,
                    decoration: const InputDecoration(
                      labelText: 'Barcode (optional)',
                      prefixIcon: Icon(Icons.qr_code),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category dropdown
                  DropdownButtonFormField<int>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category *',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem<int>(
                        value: cat['id'] as int,
                        child: Text(cat['name']),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setDialogState(() => selectedCategoryId = value),
                    validator: (value) =>
                    value == null ? 'Please select a category' : null,
                  ),
                  const SizedBox(height: 12),

                  // Buying price
                  TextFormField(
                    controller: buyingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Buying Price',
                      prefixText: 'KES ',
                      prefixIcon:
                      Icon(Icons.arrow_downward, color: Colors.red),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Selling price
                  TextFormField(
                    controller: sellingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Selling Price *',
                      prefixText: 'KES ',
                      prefixIcon:
                      Icon(Icons.arrow_upward, color: Colors.green),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      final selling = double.parse(value);
                      final buying =
                          double.tryParse(buyingPriceController.text) ?? 0;
                      if (selling < buying) {
                        return 'Must be ≥ buying price';
                      }
                      return null;
                    },
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
                  await supabase.from('products').update({
                    'name': nameController.text.trim(),
                    'barcode': barcodeController.text.trim().isEmpty
                        ? null
                        : barcodeController.text.trim(),
                    'category_id': selectedCategoryId,
                    'buying_price':
                    double.tryParse(buyingPriceController.text) ?? 0,
                    'selling_price':
                    double.tryParse(sellingPriceController.text) ?? 0,
                  }).eq('id', product['id']);

                  _fetchProducts();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Item updated successfully'),
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
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search + refresh + count
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) =>
                      setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '${_filteredProducts.length} items',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _fetchProducts,
                icon: const Icon(Icons.refresh, color: Colors.green),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Table header
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    'ID',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Item Name',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Category',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    'Stock',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    'Edit',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Table rows
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? const Center(
                child: Text('No items found',
                    style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final category = product['categories'];
                final qty =
                (product['opening_stock'] ?? 0).toInt();
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
                          color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // ID
                      SizedBox(
                        width: 50,
                        // With this:
                        child: Text(
                          product['id'].toString().padLeft(4, '0'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Item name
                      Expanded(
                        flex: 3,
                        child: Text(
                          product['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Category
                      Expanded(
                        flex: 2,
                        child: Text(
                          category != null
                              ? category['name']
                              : '-',
                          style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Stock badge
                      SizedBox(
                        width: 50,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: qty <= 10
                                ? Colors.red
                                : Colors.green,
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$qty',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Edit button
                      SizedBox(
                        width: 48,
                        child: IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.blue, size: 20),
                          onPressed: () =>
                              _showEditDialog(product),
                          tooltip: 'Edit item',
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

// ---- CATEGORIES TAB ----
class _CategoriesTab extends StatefulWidget {
  const _CategoriesTab();

  @override
  State<_CategoriesTab> createState() => _CategoriesTabState();
}

class _CategoriesTabState extends State<_CategoriesTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('categories')
          .select('id, name, description, products(count)')
          .order('id');
      setState(() {
        _categories = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _showCategoryDialog({Map<String, dynamic>? category}) async {
    final nameController =
    TextEditingController(text: category?['name'] ?? '');
    final descController =
    TextEditingController(text: category?['description'] ?? '');
    final formKey = GlobalKey<FormState>();
    final isEditing = category != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(isEditing ? Icons.edit : Icons.add_circle,
                color: isEditing ? Colors.blue : Colors.green),
            const SizedBox(width: 8),
            Text(isEditing ? 'Edit Category' : 'Add New Category'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name *',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a category name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
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
                if (isEditing) {
                  await supabase.from('categories').update({
                    'name': nameController.text.trim(),
                    'description': descController.text.trim(),
                  }).eq('id', category['id']);
                } else {
                  await supabase.from('categories').insert({
                    'name': nameController.text.trim(),
                    'description': descController.text.trim(),
                  });
                }
                _fetchCategories();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEditing
                          ? 'Category updated successfully'
                          : 'Category added successfully'),
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
            icon: Icon(isEditing ? Icons.save : Icons.add,
                color: Colors.white),
            label: Text(
              isEditing ? 'Update' : 'Add',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isEditing ? Colors.blue : Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    final productCount = category['products'][0]['count'] as int;

    if (productCount > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Cannot Delete'),
            ],
          ),
          content: Text(
            '"${category['name']}" has $productCount product(s) assigned.\n\n'
                'Reassign or delete those products first.',
          ),
          actions: [
            // Only one button needed here — just close
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Category'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              '"${category['name']}"?',
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
                  Icon(Icons.warning_amber, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: TextStyle(color: Colors.red, fontSize: 12),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase
            .from('categories')
            .delete()
            .eq('id', category['id']);
        _fetchCategories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error: $e'), backgroundColor: Colors.red),
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
          // Top row — count + add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.category, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      '${_categories.length} categories',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _fetchCategories,
                    icon: const Icon(Icons.refresh, color: Colors.lightBlue),
                    tooltip: 'Refresh',
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('Add Category',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Table header
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange,
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
                  flex: 2,
                  child: Text('Category Name',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Description',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                SizedBox(
                  width: 50,
                  child: Text('Items',
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

          // Table rows
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined,
                      size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  const Text('No categories yet',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showCategoryDialog(),
                    icon: const Icon(Icons.add,
                        color: Colors.white),
                    label: const Text('Add First Category',
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final productCount =
                cat['products'][0]['count'] as int;
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
                          color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // ID
                      SizedBox(
                        width: 46,
                        child: Text(
                            cat['id'].toString().padLeft(4, '0'),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      // Category name
                      Expanded(
                        flex: 2,
                        child: Text(
                          cat['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Description
                      Expanded(
                        flex: 3,
                        child: Text(
                          cat['description'] != null &&
                              cat['description']
                                  .toString()
                                  .isNotEmpty
                              ? cat['description']
                              : '—',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Product count badge
                      SizedBox(
                        width: 50,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: productCount > 0
                                ? Colors.blue
                                : Colors.grey[300],
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$productCount',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: productCount > 0
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Actions — edit + delete
                      SizedBox(
                        width: 80,
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit,
                                  color: Colors.blue, size: 18),
                              tooltip: 'Edit',
                              padding: EdgeInsets.zero,
                              constraints:
                              const BoxConstraints(),
                              onPressed: () =>
                                  _showCategoryDialog(
                                      category: cat),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red, size: 18),
                              tooltip: 'Delete',
                              padding: EdgeInsets.zero,
                              constraints:
                              const BoxConstraints(),
                              onPressed: () =>
                                  _deleteCategory(cat),
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

// ---- STOCK MANAGER TAB ----
class _StockManagerTab extends StatefulWidget {
  const _StockManagerTab();

  @override
  State<_StockManagerTab> createState() => _StockManagerTabState();
}

class _StockManagerTabState extends State<_StockManagerTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('products')
          .select('id, name, buying_price, selling_price, opening_stock, categories(id, name)')
          .order('id');
      setState(() {
        _products = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where((p) => p['name']
        .toString()
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _showAdjustDialog(Map<String, dynamic> product) async {
    int currentStock = (product['opening_stock'] ?? 0).toInt();
    final stockController =
    TextEditingController(text: currentStock.toString());
    final buyingPriceController = TextEditingController(
        text: product['buying_price']?.toString() ?? '0');
    final sellingPriceController = TextEditingController(
        text: product['selling_price']?.toString() ?? '0');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.tune, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  product['name'],
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  if (product['categories'] != null)
                    Chip(
                      label: Text(product['categories']['name']),
                      backgroundColor: Colors.green[50],
                      avatar: const Icon(Icons.category,
                          size: 16, color: Colors.green),
                    ),
                  const SizedBox(height: 16),

                  // Stock adjuster
                  const Text('Stock Quantity',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle,
                            color: Colors.red, size: 36),
                        onPressed: () {
                          if (currentStock > 0) {
                            setDialogState(() {
                              currentStock--;
                              stockController.text =
                                  currentStock.toString();
                            });
                          }
                        },
                      ),
                      SizedBox(
                        width: 80,
                        child: TextFormField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              currentStock =
                                  int.tryParse(value) ?? currentStock;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle,
                            color: Colors.green, size: 36),
                        onPressed: () {
                          setDialogState(() {
                            currentStock++;
                            stockController.text =
                                currentStock.toString();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Buying price
                  const Text('Buying Price (KES)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: buyingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: 'KES ',
                      prefixIcon:
                      Icon(Icons.arrow_downward, color: Colors.red),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Selling price
                  const Text('Selling Price (KES)',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: sellingPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: 'KES ',
                      prefixIcon:
                      Icon(Icons.arrow_upward, color: Colors.green),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Required';
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      final selling = double.parse(value);
                      final buying =
                          double.tryParse(buyingPriceController.text) ?? 0;
                      if (selling < buying) return 'Must be ≥ buying price';
                      return null;
                    },
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
                  await supabase.from('products').update({
                    'opening_stock':
                    int.tryParse(stockController.text) ?? 0,
                    'buying_price':
                    double.tryParse(buyingPriceController.text) ?? 0,
                    'selling_price':
                    double.tryParse(sellingPriceController.text) ?? 0,
                  }).eq('id', product['id']);

                  _fetchProducts();

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                        Text('${product['name']} updated successfully'),
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
              label: const Text('Save',
                  style: TextStyle(color: Colors.white)),
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search + refresh
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) =>
                      setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  '${_filteredProducts.length} items',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _fetchProducts,
                icon: const Icon(Icons.refresh, color: Colors.green),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Table header
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange,
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
                  child: Text('Item Name',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Category',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                SizedBox(
                  width: 44,
                  child: Text('Qty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                SizedBox(
                  width: 60,
                  child: Text('Cost',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                SizedBox(
                  width: 60,
                  child: Text('Sell',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                SizedBox(
                  width: 44,
                  child: Text('Action',
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

          // Table rows
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? const Center(
                child: Text('No items found',
                    style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final category = product['categories'];
                final qty =
                (product['opening_stock'] ?? 0).toInt();
                final buyPrice =
                    product['buying_price'] ?? 0;
                final sellPrice =
                    product['selling_price'] ?? 0;
                final isEven = index % 2 == 0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: qty <= 10
                        ? Colors.red[50]
                        : isEven
                        ? Colors.grey[50]
                        : Colors.white,
                    border: Border(
                      bottom: BorderSide(
                          color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // ID
                      SizedBox(
                        width: 46,
                        // With this:
                        child: Text(
                          product['id'].toString().padLeft(4, '0'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      // Item name
                      Expanded(
                        flex: 3,
                        child: Text(
                          product['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Category
                      Expanded(
                        flex: 2,
                        child: Text(
                          category != null
                              ? category['name']
                              : '-',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Stock badge
                      SizedBox(
                        width: 44,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 3),
                          decoration: BoxDecoration(
                            color: qty <= 10
                                ? Colors.red
                                : Colors.green,
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$qty',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      // Cost
                      SizedBox(
                        width: 60,
                        child: Text(
                          '$buyPrice',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red),
                        ),
                      ),
                      // Sell
                      SizedBox(
                        width: 60,
                        child: Text(
                          '$sellPrice',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Adjust button
                      SizedBox(
                        width: 44,
                        child: IconButton(
                          icon: const Icon(Icons.tune,
                              color: Colors.blue, size: 20),
                          tooltip: 'Adjust',
                          onPressed: () =>
                              _showAdjustDialog(product),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Legend
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                ),
              ),
              const SizedBox(width: 6),
              const Text('Low stock (≤ 10 units)',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}