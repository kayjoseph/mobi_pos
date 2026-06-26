import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobi_pos/app_drawer.dart';

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
            Tab(icon: Icon(Icons.add_shopping_cart), text: 'New Purchase'),
            Tab(icon: Icon(Icons.list_alt), text: 'Purchase List'),
          ],
        ),
      ),
      drawer: AppDrawer(
        username: widget.username,
        currentPage: 'Purchase',   // change per page
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
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _purchaseItems = [];
  Map<String, dynamic>? _selectedSupplier;
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  String _paymentMethod = 'Cash';
  final _amountPaidController = TextEditingController();
  final _notesController = TextEditingController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  @override
  void dispose() {
    _amountPaidController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSuppliers() async {
    setState(() => _isLoading = true);
    try {
      final suppliers = await supabase
          .from('suppliers')
          .select('id, name')
          .order('name');
      setState(() {
        _suppliers = List<Map<String, dynamic>>.from(suppliers);
        _selectedSupplier =
        _suppliers.isNotEmpty ? _suppliers.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchProducts(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final data = await supabase
          .from('products')
          .select('id, name, buying_price, categories(name)')
          .ilike('name', '%$query%')
          .limit(10);
      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(data);
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  bool _isInPurchase(int productId) {
    return _purchaseItems.any((p) => p['id'] == productId);
  }

  void _addItem(Map<String, dynamic> product) {
    if (_isInPurchase(product['id'])) return;
    setState(() {
      _purchaseItems.add({
        'id': product['id'],
        'name': product['name'],
        'price': (product['buying_price'] ?? 0).toDouble(),
        'qty': 1,
      });
      _searchResults = [];
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _removeItem(int productId) {
    setState(() =>
        _purchaseItems.removeWhere((p) => p['id'] == productId));
  }

  double get _total => _purchaseItems.fold(
      0, (sum, item) => sum + item['price'] * item['qty']);

  Future<void> _showEditItemDialog(
      Map<String, dynamic> item, int index) async {
    final qtyController =
    TextEditingController(text: item['qty'].toString());
    final priceController =
    TextEditingController(text: item['price'].toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item['name'],
          style: const TextStyle(fontSize: 15),
          overflow: TextOverflow.ellipsis,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Buying Price (KES)',
                prefixText: 'KES ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 1;
              final price =
                  double.tryParse(priceController.text) ?? 0;
              setState(() {
                _purchaseItems[index]['qty'] =
                qty < 1 ? 1 : qty;
                _purchaseItems[index]['price'] = price;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green),
            child: const Text('Save',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _completePurchase() async {
    if (_purchaseItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add at least one item'),
            backgroundColor: Colors.red),
      );
      return;
    }

    final amountPaid =
        double.tryParse(_amountPaidController.text) ?? 0;
    final balance = _total - amountPaid;
    final status = amountPaid >= _total ? 'paid' : 'unpaid';

    try {
      await supabase.from('purchases').insert({
        'supplier_id': _selectedSupplier?['id'],
        'total_amount': _total,
        'amount_paid': amountPaid,
        'balance': balance < 0 ? 0 : balance,
        'payment_method': amountPaid > 0 ? _paymentMethod : null,
        'status': status,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        'created_by': widget.username,
        'items': _purchaseItems
            .map((item) => {
          'product_id': item['id'],
          'name': item['name'],
          'qty': item['qty'],
          'price': item['price'],
          'subtotal': item['price'] * item['qty'],
        })
            .toList(),
      });

      // Add stock for each item
      for (final item in _purchaseItems) {
        final product = await supabase
            .from('products')
            .select('opening_stock')
            .eq('id', item['id'])
            .single();

        final currentStock =
        (product['opening_stock'] ?? 0).toInt();
        final newStock = currentStock + item['qty'];

        await supabase.from('products').update({
          'opening_stock': newStock,
          'buying_price': item['price'], // update price too
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
            content: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _summaryRow('Supplier',
                      _selectedSupplier?['name'] ?? '-'),
                  _summaryRow('Items',
                      '${_purchaseItems.length} item(s)'),
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
                  _summaryRow(
                    'Status',
                    status.toUpperCase(),
                    valueColor: status == 'paid'
                        ? Colors.green
                        : Colors.red,
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _purchaseItems.clear();
                    _amountPaidController.clear();
                    _notesController.clear();
                    _paymentMethod = 'Cash';
                  });
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
        : SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Supplier dropdown
          DropdownButtonFormField<Map<String, dynamic>>(
            value: _selectedSupplier,
            decoration: const InputDecoration(
              labelText: 'Supplier',
              prefixIcon: Icon(Icons.store),
              border: OutlineInputBorder(),
              isDense: true,
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
          const SizedBox(height: 12),

          // Search box
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search and add item...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _searchResults = [];
                  });
                },
              )
                  : null,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10)),
              isDense: true,
            ),
            onChanged: (v) {
              setState(() => _searchQuery = v);
              _searchProducts(v);
            },
          ),

          // Search results dropdown
          if (_searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: _searchResults.map((product) {
                  final alreadyAdded =
                  _isInPurchase(product['id']);
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.green[100],
                      radius: 16,
                      child: Text(
                        product['name'][0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                    title: Text(product['name'],
                        style: const TextStyle(fontSize: 13)),
                    subtitle: Text(
                      product['categories'] != null
                          ? product['categories']['name']
                          : '-',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: alreadyAdded
                        ? const Icon(Icons.check,
                        color: Colors.green)
                        : const Icon(Icons.add_circle,
                        color: Colors.green),
                    onTap: alreadyAdded
                        ? null
                        : () => _addItem(product),
                  );
                }).toList(),
              ),
            ),

          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Center(
                  child: CircularProgressIndicator()),
            ),

          const SizedBox(height: 16),

          // Purchase items list
          if (_purchaseItems.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Center(
                child: Text(
                  'Search and add items above',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else ...[
            // Items header
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('Item',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text('Qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text('Price',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text('Subtotal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                  SizedBox(width: 50),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // Items rows
            ...List.generate(_purchaseItems.length, (index) {
              final item = _purchaseItems[index];
              final subtotal = item['price'] * item['qty'];
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: index % 2 == 0
                      ? Colors.grey[50]
                      : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                        color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    // Item name
                    Expanded(
                      flex: 3,
                      child: Text(
                        item['name'],
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Qty
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${item['qty']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Price
                    SizedBox(
                      width: 70,
                      child: Text(
                        '${item['price']}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey),
                      ),
                    ),
                    // Subtotal
                    SizedBox(
                      width: 70,
                      child: Text(
                        subtotal.toStringAsFixed(2),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Actions
                    SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () =>
                                _showEditItemDialog(
                                    item, index),
                            child: const Icon(Icons.edit,
                                color: Colors.blue,
                                size: 18),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () =>
                                _removeItem(item['id']),
                            child: const Icon(Icons.close,
                                color: Colors.red,
                                size: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // Total
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
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
            ),
            const SizedBox(height: 12),

            // Payment method
            Row(
              children: ['Cash', 'M-Pesa', 'Bank']
                  .map((method) {
                final isSelected = _paymentMethod == method;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                            () => _paymentMethod = method),
                    child: Container(
                      margin:
                      const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.green
                            : Colors.grey[100],
                        borderRadius:
                        BorderRadius.circular(8),
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
                          fontSize: 12,
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
            const SizedBox(height: 10),

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
            const SizedBox(height: 10),

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
            const SizedBox(height: 12),

            // Record button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _purchaseItems.isEmpty
                    ? null
                    : _completePurchase,
                icon: const Icon(Icons.save,
                    color: Colors.white),
                label: const Text('Record Purchase',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
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