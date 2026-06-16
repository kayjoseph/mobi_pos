import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/products.dart';
import 'package:mobi_pos/sales.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Purchase extends StatefulWidget {
  final String username;
  const Purchase({super.key, required this.username});

  @override
  State<Purchase> createState() => _PurchaseState();
}

class _PurchaseState extends State<Purchase>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();
  TabController? _tabController;
  bool _salesExpanded = false;

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
    Navigator.pop(context);
    if (title == 'Dashboard') {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (title == 'Products') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (context) =>
                  Products(username: widget.username)));
    } else if (title == 'Sales') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(
              builder: (context) =>
                  Sales(username: widget.username)));
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
        title: const Text('Purchases',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
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
            Tab(icon: Icon(Icons.add_shopping_cart), text: 'New Purchase'),
            Tab(icon: Icon(Icons.list_alt), text: 'Purchase List'),
          ],
        ),
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
                      item['title'] == 'Purchases';
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
                    tileColor:
                    isSelected ? Colors.green[50] : null,
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
      body: TabBarView(
        controller: _tabController!,
        children: [
          _NewPurchaseTab(username: widget.username),
          _PurchaseListTab(username: widget.username),
        ],
      ),
    );
  }
}

// ---- NEW PURCHASE TAB ----
class _NewPurchaseTab extends StatefulWidget {
  final String username;
  const _NewPurchaseTab({required this.username});

  @override
  State<_NewPurchaseTab> createState() => _NewPurchaseTabState();
}

class _NewPurchaseTabState extends State<_NewPurchaseTab> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _cart = [];
  Map<String, dynamic>? _selectedSupplier;
  bool _isLoading = true;
  String _searchQuery = '';
  String _paymentMethod = 'Cash';
  final _amountPaidController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final suppliers = await supabase
          .from('suppliers')
          .select('id, name')
          .order('name');
      final products = await supabase
          .from('products')
          .select('id, name, buying_price, opening_stock, categories(name)')
          .order('name');
      setState(() {
        _suppliers = List<Map<String, dynamic>>.from(suppliers);
        _products = List<Map<String, dynamic>>.from(products);
        _selectedSupplier =
        _suppliers.isNotEmpty ? _suppliers.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final index =
      _cart.indexWhere((c) => c['id'] == product['id']);
      if (index >= 0) {
        _cart[index]['qty']++;
      } else {
        _cart.add({
          'id': product['id'],
          'name': product['name'],
          'price': product['buying_price'] ?? 0,
          'qty': 1,
        });
      }
    });
  }

  void _removeFromCart(int productId) {
    setState(() {
      final index =
      _cart.indexWhere((c) => c['id'] == productId);
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

  int _cartQty(int productId) {
    final item = _cart.where((c) => c['id'] == productId);
    return item.isEmpty ? 0 : item.first['qty'];
  }

  double get _total =>
      _cart.fold(0, (sum, item) => sum + item['price'] * item['qty']);

  Future<void> _completePurchase() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add items to purchase'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final amountPaid =
        double.tryParse(_amountPaidController.text) ?? 0;
    final balance = _total - amountPaid;
    final status = amountPaid >= _total ? 'paid' : 'unpaid';

    try {
      // Save purchase
      await supabase.from('purchases').insert({
        'supplier_id': _selectedSupplier?['id'],
        'total_amount': _total,
        'amount_paid': amountPaid,
        'balance': balance < 0 ? 0 : balance,
        'payment_method':
        amountPaid > 0 ? _paymentMethod : null,
        'status': status,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'created_by': widget.username,
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

      // Update stock for each item
      for (final item in _cart) {
        final product = await supabase
            .from('products')
            .select('opening_stock')
            .eq('id', item['id'])
            .single();

        final currentStock =
        (product['opening_stock'] ?? 0).toInt();
        final newStock = currentStock + item['qty']; // ADD stock

        await supabase.from('products').update({
          'opening_stock': newStock,
        }).eq('id', item['id']);
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Purchase Recorded!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _summaryRow('Supplier',
                          _selectedSupplier?['name'] ?? '-'),
                      _summaryRow('Total',
                          'KES ${_total.toStringAsFixed(2)}'),
                      _summaryRow('Paid',
                          'KES ${amountPaid.toStringAsFixed(2)}'),
                      if (balance > 0)
                        _summaryRow(
                          'Balance',
                          'KES ${balance.toStringAsFixed(2)}',
                          valueColor: Colors.red,
                        ),
                      _summaryRow('Status',
                          status.toUpperCase(),
                          valueColor: status == 'paid'
                              ? Colors.green
                              : Colors.red),
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
                    _amountPaidController.clear();
                    _notesController.clear();
                    _paymentMethod = 'Cash';
                  });
                  _fetchData();
                },
                icon: const Icon(Icons.refresh,
                    color: Colors.white),
                label: const Text('New Purchase',
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
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _summaryRow(String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: valueColor)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
      children: [
        // Supplier selector
        Container(
          color: Colors.grey[50],
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              DropdownButtonFormField<Map<String, dynamic>>(
                value: _selectedSupplier,
                decoration: const InputDecoration(
                  labelText: 'Supplier',
                  prefixIcon: Icon(Icons.store),
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _suppliers.map((s) {
                  return DropdownMenuItem(
                    value: s,
                    child: Text(s['name']),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedSupplier = value),
              ),
              const SizedBox(height: 8),
              // Search
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10)),
                  contentPadding:
                  const EdgeInsets.symmetric(
                      vertical: 8),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (v) =>
                    setState(() => _searchQuery = v),
              ),
            ],
          ),
        ),

        // Products + Cart
        Expanded(
          child: Row(
            children: [
              // Products list
              Expanded(
                flex: 3,
                child: _filteredProducts.isEmpty
                    ? const Center(
                    child: Text('No items found',
                        style: TextStyle(
                            color: Colors.grey)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product =
                    _filteredProducts[index];
                    final inCart =
                    _cartQty(product['id']);

                    return GestureDetector(
                      onTap: () =>
                          _addToCart(product),
                      child: Container(
                        margin: const EdgeInsets
                            .only(bottom: 6),
                        padding:
                        const EdgeInsets.all(
                            10),
                        decoration: BoxDecoration(
                          color: inCart > 0
                              ? Colors.green[50]
                              : Colors.white,
                          borderRadius:
                          BorderRadius.circular(
                              8),
                          border: Border.all(
                            color: inCart > 0
                                ? Colors.green
                                : Colors.grey[200]!,
                            width:
                            inCart > 0 ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                              Colors.green[100],
                              radius: 18,
                              child: Text(
                                product['name'][0]
                                    .toUpperCase(),
                                style:
                                const TextStyle(
                                    color: Colors
                                        .green,
                                    fontWeight:
                                    FontWeight
                                        .bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    product['name'],
                                    style: const TextStyle(
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                        fontSize: 13),
                                    overflow:
                                    TextOverflow
                                        .ellipsis,
                                  ),
                                  Text(
                                    product['categories'] !=
                                        null
                                        ? product[
                                    'categories']
                                    ['name']
                                        : '-',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors
                                            .grey),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment
                                  .end,
                              children: [
                                Text(
                                  'KES ${product['buying_price'] ?? 0}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color:
                                      Colors.green,
                                      fontWeight:
                                      FontWeight
                                          .bold),
                                ),
                                if (inCart > 0)
                                  Container(
                                    padding:
                                    const EdgeInsets
                                        .symmetric(
                                        horizontal:
                                        6,
                                        vertical:
                                        2),
                                    decoration:
                                    BoxDecoration(
                                      color:
                                      Colors.green,
                                      borderRadius:
                                      BorderRadius
                                          .circular(
                                          8),
                                    ),
                                    child: Text(
                                      'x$inCart',
                                      style: const TextStyle(
                                          color: Colors
                                              .white,
                                          fontSize: 10),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Container(width: 1, color: Colors.grey[200]),

              // Cart
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
                          const Text('Items',
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
                            Icon(
                                Icons
                                    .shopping_cart_outlined,
                                size: 40,
                                color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No items added',
                                style: TextStyle(
                                    color: Colors.grey)),
                          ],
                        ),
                      )
                          : ListView.builder(
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          if (index >= _cart.length) {
                            return const SizedBox();
                          }
                          final item =
                          Map<String, dynamic>.from(
                              _cart[index]);

                          return Container(
                            padding:
                            const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color:
                                    Colors.grey[100]!),
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
                                            FontWeight
                                                .w600,
                                            fontSize: 13),
                                        overflow:
                                        TextOverflow
                                            .ellipsis,
                                      ),
                                    ),
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
                                        GestureDetector(
                                          onTap: () async {
                                            final controller =
                                            TextEditingController(
                                                text: item[
                                                'qty']
                                                    .toString());
                                            await showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  AlertDialog(
                                                    title: Text(
                                                        'Qty — ${item['name']}',
                                                        style: const TextStyle(
                                                            fontSize:
                                                            14)),
                                                    content: TextField(
                                                      controller:
                                                      controller,
                                                      keyboardType:
                                                      TextInputType
                                                          .number,
                                                      autofocus: true,
                                                      textAlign:
                                                      TextAlign
                                                          .center,
                                                      style: const TextStyle(
                                                          fontSize: 22,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                      decoration:
                                                      const InputDecoration(
                                                        border:
                                                        OutlineInputBorder(),
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context),
                                                        child: const Text(
                                                            'Cancel'),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          int typed =
                                                              int.tryParse(
                                                                  controller
                                                                      .text) ??
                                                                  1;
                                                          if (typed < 1)
                                                            typed = 1;
                                                          setState(() {
                                                            final i = _cart
                                                                .indexWhere((c) =>
                                                            c['id'] ==
                                                                item['id']);
                                                            if (i >= 0)
                                                              _cart[i][
                                                              'qty'] =
                                                                  typed;
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                            backgroundColor:
                                                            Colors.green),
                                                        child: const Text(
                                                            'OK',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          },
                                          child: Container(
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal: 10,
                                                vertical: 4),
                                            decoration:
                                            BoxDecoration(
                                              border: Border.all(
                                                  color: Colors
                                                      .grey[300]!),
                                              borderRadius:
                                              BorderRadius
                                                  .circular(6),
                                            ),
                                            child: Text(
                                              '${item['qty']}',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              _addToCart(item),
                                          child: const Icon(
                                              Icons
                                                  .add_circle_outline,
                                              size: 20,
                                              color: Colors.green),
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

                    // Payment section
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
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // Total
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('TOTAL',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Text(
                                'KES ${_total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Colors.green),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Payment method
                          Row(
                            children: ['Cash', 'M-Pesa', 'Bank']
                                .map((method) {
                              final isSelected =
                                  _paymentMethod == method;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() =>
                                  _paymentMethod = method),
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        right: 4),
                                    padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.green
                                          : Colors.grey[100],
                                      borderRadius:
                                      BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.green
                                            : Colors.grey[300]!,
                                      ),
                                    ),
                                    child: Text(
                                      method,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 8),

                          // Amount paid
                          TextField(
                            controller: _amountPaidController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText:
                              'Amount Paid (leave empty if unpaid)',
                              prefixText: 'KES ',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Notes
                          TextField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes (optional)',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Record button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _cart.isEmpty
                                  ? null
                                  : _completePurchase,
                              icon: const Icon(Icons.save,
                                  color: Colors.white),
                              label: const Text('Record Purchase',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding:
                                const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(8)),
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

// ---- PURCHASE LIST TAB ----
class _PurchaseListTab extends StatefulWidget {
  final String username;
  const _PurchaseListTab({required this.username});

  @override
  State<_PurchaseListTab> createState() => _PurchaseListTabState();
}

class _PurchaseListTabState extends State<_PurchaseListTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _purchases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPurchases();
  }

  Future<void> _fetchPurchases() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('purchases')
          .select('*, suppliers(name)')
          .order('created_at', ascending: false);
      setState(() {
        _purchases = List<Map<String, dynamic>>.from(data);
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

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr).toLocal();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDetails(Map<String, dynamic> purchase) {
    final items = purchase['items'] as List<dynamic>;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PO-${purchase['id'].toString().padLeft(5, '0')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: purchase['status'] == 'paid'
                    ? Colors.green
                    : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                purchase['status'].toString().toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _infoRow('Date',
                        _formatDate(purchase['created_at'])),
                    _infoRow('Supplier',
                        purchase['suppliers']?['name'] ?? '-'),
                    _infoRow('Created By',
                        purchase['created_by'] ?? '-'),
                    if (purchase['payment_method'] != null)
                      _infoRow('Payment',
                          purchase['payment_method']),
                    if (purchase['notes'] != null &&
                        purchase['notes'].isNotEmpty)
                      _infoRow('Notes', purchase['notes']),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('Items',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...items.map((item) => Padding(
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
                            const TextStyle(fontSize: 13))),
                    Text('KES ${item['subtotal']}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              )),
              const Divider(),
              _infoRow('Total',
                  'KES ${purchase['total_amount']}',
                  bold: true),
              _infoRow('Paid',
                  'KES ${purchase['amount_paid']}'),
              if ((purchase['balance'] ?? 0) > 0)
                _infoRow('Balance Due',
                    'KES ${purchase['balance']}',
                    valueColor: Colors.red,
                    bold: true),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green),
            child: const Text('Close',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value,
      {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 13)),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                  bold ? FontWeight.bold : FontWeight.w500,
                  color: valueColor)),
        ],
      ),
    );
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
                  '${_purchases.length} purchases',
                  style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _fetchPurchases,
                icon:
                const Icon(Icons.refresh, color: Colors.green),
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
                  width: 70,
                  child: Text('PO No.',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                Expanded(
                  child: Text('Supplier',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                SizedBox(
                  width: 70,
                  child: Text('Total',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                SizedBox(
                  width: 55,
                  child: Text('Status',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
                SizedBox(width: 36),
              ],
            ),
          ),
          const SizedBox(height: 4),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _purchases.isEmpty
                ? const Center(
                child: Text('No purchases yet',
                    style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: _purchases.length,
              itemBuilder: (context, index) {
                final purchase = _purchases[index];
                final isEven = index % 2 == 0;
                final isPaid =
                    purchase['status'] == 'paid';

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
                      SizedBox(
                        width: 70,
                        child: Text(
                          'PO-${purchase['id'].toString().padLeft(5, '0')}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          purchase['suppliers']
                          ?['name'] ??
                              '-',
                          style: const TextStyle(
                              fontSize: 12),
                          overflow:
                          TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 70,
                        child: Text(
                          'KES ${purchase['total_amount']}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight:
                              FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 55,
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3),
                          decoration: BoxDecoration(
                            color: isPaid
                                ? Colors.green
                                : Colors.red,
                            borderRadius:
                            BorderRadius.circular(
                                10),
                          ),
                          child: Text(
                            isPaid ? 'Paid' : 'Unpaid',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight:
                                FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 36,
                        child: IconButton(
                          icon: const Icon(
                              Icons.visibility,
                              color: Colors.blue,
                              size: 18),
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              _showDetails(purchase),
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