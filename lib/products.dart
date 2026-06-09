import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
          .select('id, name, barcode, buying_price, selling_price, opening_stock, categories(name)')
          .order('name');

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
    return _products.where((p) {
      return p['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search + count row
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              // Refresh button
              IconButton(
                onPressed: _fetchProducts,
                icon: const Icon(Icons.refresh, color: Colors.green),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? const Center(
                child: Text('No items found',
                    style: TextStyle(color: Colors.grey)))
                : ListView.separated(
              itemCount: _filteredProducts.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final category = product['categories'];
                final quantity = product['opening_stock'] ?? 0;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: Text(
                      product['name'][0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    product['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${category != null ? category['name'] : 'No category'}'
                        '${product['barcode'] != null ? ' • ${product['barcode']}' : ''}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'KES ${product['selling_price']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'Stock: $quantity',
                        style: TextStyle(
                          fontSize: 12,
                          color: quantity <= 10 ? Colors.red : Colors.grey,
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
      // Fetch categories with product count
      final data = await supabase
          .from('categories')
          .select('id, name, description, products(count)')
          .order('name');

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
    // If category is passed, we are editing. Otherwise adding new.
    final nameController = TextEditingController(
        text: category != null ? category['name'] : '');
    final descController = TextEditingController(
        text: category != null ? category['description'] ?? '' : '');
    final formKey = GlobalKey<FormState>();
    final isEditing = category != null;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Category' : 'Add New Category'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a category name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
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
          ElevatedButton(
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing
                        ? 'Category updated successfully'
                        : 'Category added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(
              isEditing ? 'Update' : 'Add',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    // Check if category has products
    final productCount = category['products'][0]['count'] as int;

    if (productCount > 0) {
      // Block deletion
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
            'The category "${category['name']}" has $productCount product(s) assigned to it.\n\n'
                'Please reassign or delete those products first before deleting this category.',
          ),
          actions: [
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

    // Confirm deletion if empty
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Are you sure you want to delete "${category['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
            const Text('Delete', style: TextStyle(color: Colors.white)),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category deleted'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Summary + Add button row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Total categories badge
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                      'Total: ${_categories.length} categories',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              // Add category button
              ElevatedButton.icon(
                onPressed: () => _showCategoryDialog(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Category',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Categories list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                ? const Center(
              child: Text('No categories yet. Add one!',
                  style: TextStyle(color: Colors.grey)),
            )
                : ListView.separated(
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final productCount =
                cat['products'][0]['count'] as int;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[100],
                    child: const Icon(Icons.category,
                        color: Colors.green),
                  ),
                  title: Text(
                    cat['name'],
                    style:
                    const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    cat['description'] != null &&
                        cat['description'].isNotEmpty
                        ? cat['description']
                        : 'No description',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  // Product count chip
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(
                          '$productCount item${productCount == 1 ? '' : 's'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: productCount > 0
                            ? Colors.blue[50]
                            : Colors.grey[200],
                      ),
                      // Edit button
                      IconButton(
                        icon: const Icon(Icons.edit,
                            color: Colors.blue),
                        onPressed: () =>
                            _showCategoryDialog(category: cat),
                      ),
                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red),
                        onPressed: () => _deleteCategory(cat),
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
          .select('id, name, buying_price, selling_price, opening_stock, categories(name)')
          .order('name');
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
    final buyingPriceController =
    TextEditingController(text: product['buying_price']?.toString() ?? '0');
    final sellingPriceController =
    TextEditingController(text: product['selling_price']?.toString() ?? '0');
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
                  // Category
                  if (product['categories'] != null)
                    Chip(
                      label: Text(product['categories']['name']),
                      backgroundColor: Colors.green[50],
                      avatar: const Icon(Icons.category,
                          size: 16, color: Colors.green),
                    ),
                  const SizedBox(height: 16),

                  // Stock adjuster
                  const Text(
                    'Stock Quantity',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                            stockController.text = currentStock.toString();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Buying price
                  const Text(
                    'Buying Price (KES)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Selling price
                  const Text(
                    'Selling Price (KES)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
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
              color: Colors.green,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Item / Category',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('Buy / Sell',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 1,
                  child: Text('Qty',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 48,
                  child: Text('',
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                ? const Center(
                child: Text('No items found',
                    style: TextStyle(color: Colors.grey)))
                : ListView.separated(
              itemCount: _filteredProducts.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                final category = product['categories'];
                final qty =
                (product['opening_stock'] ?? 0).toInt();
                final buyPrice = product['buying_price'] ?? 0;
                final sellPrice =
                    product['selling_price'] ?? 0;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: qty <= 10
                        ? Colors.red[50]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      // Name + category
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              category != null
                                  ? category['name']
                                  : 'No category',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      // Buy / Sell
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'KES $buyPrice',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.red),
                            ),
                            Text(
                              'KES $sellPrice',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight:
                                  FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // Qty badge
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: qty <= 10
                                ? Colors.red
                                : Colors.green,
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$qty',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                      ),
                      // Adjust button
                      SizedBox(
                        width: 48,
                        child: IconButton(
                          icon: const Icon(Icons.tune,
                              color: Colors.blue),
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