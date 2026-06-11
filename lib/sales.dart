import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/products.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Sales extends StatefulWidget {
  final String username;

  const Sales({super.key, required this.username});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController? _tabController;
  bool _salesExpanded = true; // keep sales expanded since we're on sales page

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
    {'title': 'Expenses', 'icon': Icons.receipt_long},
    {'title': 'Customers', 'icon': Icons.people},
  ];

  void _navigateTo(String title) {
    Navigator.pop(context); // close drawer
    if (title == 'Dashboard') {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (title == 'Products') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Products(username: widget.username),
        ),
      );
    }
    // Add other modules here as they are built
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
          'Sales',
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
                    color: Colors.white, fontWeight: FontWeight.bold)),
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
            Tab(icon: Icon(Icons.point_of_sale), text: 'POS'),
            Tab(icon: Icon(Icons.list_alt), text: 'Sales List'),
          ],
        ),
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
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: _menuItems.map((item) {
                  final bool isSelected = item['title'] == 'Sales';

                  if (item['children'] != null) {
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(item['icon'],
                              color: Colors.green),
                          title: Text(
                            item['title'],
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(
                            _salesExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.green,
                          ),
                          onTap: () => setState(
                                  () => _salesExpanded = !_salesExpanded),
                        ),
                        if (_salesExpanded)
                          ...item['children'].map<Widget>((child) {
                            final bool isChildSelected =
                                child['title'] == 'Sales';
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
                              onTap: () {
                                Navigator.pop(context);
                                if (child['title'] == 'Sales') {
                                  // already here
                                }
                                // Sales Return and Cancelled Sales later
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
                    title: Text(
                      item['title'],
                      style: TextStyle(
                        color: isSelected ? Colors.green : Colors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
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
              title: const Text('Logout',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: _logout,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController!,
        children: const [
          _POSTab(),
          _SalesListTab(),
        ],
      ),
    );
  }
}

// ---- POS TAB ----
class _POSTab extends StatefulWidget {
  const _POSTab();

  @override
  State<_POSTab> createState() => _POSTabState();
}

class _POSTabState extends State<_POSTab> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _cart = [];
  int? _selectedCategoryId;
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final products = await supabase
          .from('products')
          .select('id, name, selling_price, opening_stock, categories(id, name)')
          .order('name');
      final categories = await supabase
          .from('categories')
          .select('id, name')
          .order('name');

      setState(() {
        _products = List<Map<String, dynamic>>.from(products);
        _categories = List<Map<String, dynamic>>.from(categories);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _products.where((p) {
      final matchesCategory = _selectedCategoryId == null ||
          (p['categories'] != null &&
              p['categories']['id'] == _selectedCategoryId);
      final matchesSearch = _searchQuery.isEmpty ||
          p['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final index = _cart.indexWhere((c) => c['id'] == product['id']);
      if (index >= 0) {
        _cart[index]['qty']++;
      } else {
        _cart.add({
          'id': product['id'],
          'name': product['name'],
          'price': product['selling_price'],
          'qty': 1,
        });
      }
    });
  }

  void _removeFromCart(int productId) {
    setState(() {
      final index = _cart.indexWhere((c) => c['id'] == productId);
      if (index >= 0) {
        if (_cart[index]['qty'] > 1) {
          _cart[index]['qty']--;
        } else {
          _cart.removeAt(index);
        }
      }
    });
  }

  void _deleteFromCart(int productId) {
    setState(() => _cart.removeWhere((c) => c['id'] == productId));
  }

  double get _total =>
      _cart.fold(0, (sum, item) => sum + item['price'] * item['qty']);

  int _cartQty(int productId) {
    final item = _cart.where((c) => c['id'] == productId);
    return item.isEmpty ? 0 : item.first['qty'];
  }

  void _showPaymentDialog() {
    String _paymentMethod = 'Cash';
    final _transactionController = TextEditingController();
    final _amountController =
    TextEditingController(text: _total.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.payment, color: Colors.green),
              SizedBox(width: 8),
              Text('Payment'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      ..._cart.map((item) => Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item['name']} x${item['qty']}',
                                style:
                                const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'KES ${(item['price'] * item['qty']).toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          Text(
                            'KES ${_total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Payment method
                const Text('Payment Method',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: ['Cash', 'M-Pesa', 'Bank'].map((method) {
                    final isSelected = _paymentMethod == method;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(
                                () => _paymentMethod = method),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding:
                          const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.green
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey[300]!,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                method == 'Cash'
                                    ? Icons.money
                                    : method == 'M-Pesa'
                                    ? Icons.phone_android
                                    : Icons.account_balance,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Amount paid
                const Text('Amount Paid (KES)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: 'KES ',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 12),

                // Transaction code
                const Text('Sales Note',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _transactionController,
                  maxLength: 20,
                  decoration: const InputDecoration(
                    hintText: ' Transaction code etc.',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
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
                final amountPaid =
                    double.tryParse(_amountController.text) ?? 0;
                if (amountPaid < _total) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Amount paid is less than total'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                await _completeSale(
                  paymentMethod: _paymentMethod,
                  amountPaid: amountPaid,
                  transactionCode: _transactionController.text.trim(),
                );
              },
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('Complete Sale',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeSale({
    required String paymentMethod,
    required double amountPaid,
    required String transactionCode,
  }) async {
    try {
      // 1. Save sale to database
      await supabase.from('sales').insert({
        'total_amount': _total,
        'amount_paid': amountPaid,
        'change_amount': amountPaid - _total,
        'payment_method': paymentMethod,
        'transaction_code':
        transactionCode.isEmpty ? null : transactionCode,
        'items': _cart
            .map((item) => {
          'product_id': item['id'],
          'name': item['name'],
          'qty': item['qty'],
          'price': item['price'],
          'subtotal': item['price'] * item['qty'],
        })
            .toList(),
      });

      // 2. Deduct stock for each item in cart
      for (final item in _cart) {
        // First get current stock
        final product = await supabase
            .from('products')
            .select('opening_stock')
            .eq('id', item['id'])
            .single();

        final currentStock =
        (product['opening_stock'] ?? 0).toInt();
        final newStock = currentStock - item['qty'];

        // Update stock — allow negative so we know there's an issue
        await supabase.from('products').update({
          'opening_stock': newStock,
        }).eq('id', item['id']);
      }

      // 3. Show change/success dialog
      final change = amountPaid - _total;
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Sale Complete!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total'),
                          Text(
                            'KES ${_total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Paid'),
                          Text(
                            'KES ${amountPaid.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      if (change > 0) ...[
                        const Divider(),
                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Change',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            Text(
                              'KES ${change.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.green),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _cart.clear();
                    _fetchData(); // reload products with updated stock
                  });
                },
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('New Sale',
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error saving sale: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      children: [
        // ---- TOP: Search + Category filter ----
        Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 8),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (v) =>
                    setState(() => _searchQuery = v),
              ),
              const SizedBox(height: 10),

              // Category filter chips
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // All chip
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategoryId == null,
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(
                          color: _selectedCategoryId == null
                              ? Colors.white
                              : Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) => setState(
                                () => _selectedCategoryId = null),
                      ),
                    ),
                    // Category chips
                    ..._categories.map((cat) {
                      final isSelected =
                          _selectedCategoryId == cat['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat['name']),
                          selected: isSelected,
                          selectedColor: Colors.green,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                          onSelected: (_) => setState(() =>
                          _selectedCategoryId = cat['id']),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ---- MIDDLE: Products grid + Cart side by side ----
        Expanded(
          child: Row(
            children: [
              // Products grid
              Expanded(
                flex: 3,
                child: _filteredProducts.isEmpty
                    ? const Center(
                    child: Text('No items found',
                        style: TextStyle(color: Colors.grey)))
                    : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product =
                    _filteredProducts[index];
                    final inCart =
                    _cartQty(product['id']);

                    return GestureDetector(
                      onTap: () => _addToCart(product),
                      child: Container(
                        decoration: BoxDecoration(
                          color: inCart > 0
                              ? Colors.green[50]
                              : Colors.white,
                          borderRadius:
                          BorderRadius.circular(10),
                          border: Border.all(
                            color: inCart > 0
                                ? Colors.green
                                : Colors.grey[200]!,
                            width:
                            inCart > 0 ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.05),
                              blurRadius: 4,
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            // Item initial avatar
                            CircleAvatar(
                              backgroundColor:
                              Colors.green[100],
                              radius: 22,
                              child: Text(
                                product['name'][0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight:
                                    FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Item name
                            Padding(
                              padding: const EdgeInsets
                                  .symmetric(
                                  horizontal: 4),
                              child: Text(
                                product['name'],
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight:
                                    FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Price
                            Text(
                              'KES ${product['selling_price']}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight:
                                  FontWeight.bold),
                            ),
                            // Cart qty badge
                            if (inCart > 0)
                              Container(
                                margin: const EdgeInsets
                                    .only(top: 4),
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                    horizontal: 8,
                                    vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius:
                                  BorderRadius.circular(
                                      10),
                                ),
                                child: Text(
                                  'x$inCart in cart',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Divider
              Container(
                  width: 1, color: Colors.grey[200]),

              // ---- CART ----
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Cart header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      color: Colors.green,
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Cart',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          if (_cart.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(
                                      () => _cart.clear()),
                              child: const Text('Clear',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13)),
                            ),
                        ],
                      ),
                    ),

                    // Cart items
                    Expanded(
                      child: _cart.isEmpty
                          ? const Center(
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_outlined,
                                size: 40,
                                color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Cart is empty',
                                style: TextStyle(
                                    color: Colors.grey)),
                          ],
                        ),
                      )
                          : ListView.builder(
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey[100]!),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['name'],
                                        style: const TextStyle(
                                            fontWeight:
                                            FontWeight.w600,
                                            fontSize: 13),
                                        overflow: TextOverflow
                                            .ellipsis,
                                      ),
                                    ),
                                    // Delete from cart
                                    GestureDetector(
                                      onTap: () =>
                                          _deleteFromCart(
                                              item['id']),
                                      child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: [
                                    // Qty controls
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () =>
                                              _removeFromCart(
                                                  item['id']),
                                          child: const Icon(
                                              Icons
                                                  .remove_circle_outline,
                                              size: 20,
                                              color:
                                              Colors.red),
                                        ),
                                        Padding(
                                          padding:
                                          const EdgeInsets
                                              .symmetric(
                                              horizontal: 8),
                                          child: Text(
                                            '${item['qty']}',
                                            style: const TextStyle(
                                                fontWeight:
                                                FontWeight
                                                    .bold),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              _addToCart(item),
                                          child: const Icon(
                                              Icons
                                                  .add_circle_outline,
                                              size: 20,
                                              color:
                                              Colors.green),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'KES ${(item['price'] * item['qty']).toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontWeight:
                                          FontWeight.bold,
                                          color: Colors.green,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Total + Pay button
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('TOTAL',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text(
                                'KES ${_total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _cart.isEmpty
                                  ? null
                                  : _showPaymentDialog,
                              icon: const Icon(Icons.payment,
                                  color: Colors.white),
                              label: const Text('Pay Now',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                      FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        8)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// ---- SALES LIST TAB ----
class _SalesListTab extends StatelessWidget {
  const _SalesListTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Sales List — coming soon',
          style: TextStyle(fontSize: 18, color: Colors.grey)),
    );
  }
}