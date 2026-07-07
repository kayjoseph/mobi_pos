import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/app_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Reports extends StatefulWidget {
  final String username;
  const Reports({super.key, required this.username});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();
  TabController? _tabController;

  final List<Map<String, dynamic>> _reportTabs = [
    {
      'title': 'Sales',
      'icon': Icons.point_of_sale,
    },
    {
      'title': 'Purchases',
      'icon': Icons.shopping_cart,
    },
    {
      'title': 'P&L',
      'icon': Icons.account_balance,
    },
    {
      'title': 'Debtors/Creditors',
      'icon': Icons.people,
    },
    {
      'title': 'Stock',
      'icon': Icons.inventory_2,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: _reportTabs.length, vsync: this);
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
          'Reports',
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
          isScrollable: true,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 12),
          tabs: _reportTabs.map((tab) {
            return Tab(
              icon: Icon(tab['icon'] as IconData),
              text: tab['title'] as String,
            );
          }).toList(),
        ),
      ),
      drawer: AppDrawer(
        username: widget.username,
        currentPage: 'Reports',
      ),
      body: TabBarView(
        controller: _tabController!,
        children: [
          _SalesReportTab(),
          _PurchaseReportTab(),
          _ProfitLossTab(),
          _DebtorsCreditorsTab(),
          _StockReportTab(),
        ],
      ),
    );
  }
}

// ---- DATE FILTER WIDGET (shared) ----
class _DateFilter extends StatefulWidget {
  final Function(DateTime start, DateTime end, String label)
  onFilterChanged;

  const _DateFilter({required this.onFilterChanged});

  @override
  State<_DateFilter> createState() => _DateFilterState();
}

class _DateFilterState extends State<_DateFilter> {
  String _selected = 'Today';

  final List<String> _filters = [
    'Today',
    'Yesterday',
    'Last 7 Days',
    'Last Month',
    'Last 3 Months',
  ];

  DateTime get _startDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selected) {
      case 'Today':
        return today;
      case 'Yesterday':
        return today.subtract(const Duration(days: 1));
      case 'Last 7 Days':
        return today.subtract(const Duration(days: 7));
      case 'Last Month':
        return DateTime(now.year, now.month - 1, now.day);
      case 'Last 3 Months':
        return DateTime(now.year, now.month - 3, now.day);
      default:
        return today;
    }
  }

  DateTime get _endDate {
    final now = DateTime.now();
    if (_selected == 'Yesterday') {
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _filters.map((filter) {
          final isSelected = _selected == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter,
                  style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              selectedColor: Colors.green,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (_) {
                setState(() => _selected = filter);
                widget.onFilterChanged(
                    _startDate, _endDate, filter);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---- SUMMARY CARD ----
Widget _summaryCard(String label, String value,
    {Color color = Colors.green, IconData icon = Icons.info}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color)),
          Text(label,
              style:
              const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    ),
  );
}

// ---- SALES REPORT TAB ----
class _SalesReportTab extends StatefulWidget {
  @override
  State<_SalesReportTab> createState() => _SalesReportTabState();
}

class _SalesReportTabState extends State<_SalesReportTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _sales = [];
  bool _isLoading = true;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  String _filterLabel = 'Today';

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _start = DateTime(today.year, today.month, today.day);
    _end = DateTime(today.year, today.month, today.day, 23, 59, 59);
    _fetchSales();
  }

  Future<void> _fetchSales() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('sales')
          .select()
          .gte('created_at', _start.toIso8601String())
          .lte('created_at', _end.toIso8601String())
          .order('created_at', ascending: false);
      setState(() {
        _sales = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _totalSales =>
      _sales.fold(0, (s, r) => s + (r['total_amount'] ?? 0));
  double get _totalPaid =>
      _sales.fold(0, (s, r) => s + (r['amount_paid'] ?? 0));
  double get _totalBalance =>
      _sales.fold(0, (s, r) => s + (r['balance'] ?? 0));

  String _formatDate(String d) {
    final date = DateTime.parse(d).toLocal();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _DateFilter(
          onFilterChanged: (start, end, label) {
            _start = start;
            _end = end;
            _filterLabel = label;
            _fetchSales();
          },
        ),
        const SizedBox(height: 10),

        // Summary cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _summaryCard('Total Sales',
                  'KES ${_totalSales.toStringAsFixed(2)}',
                  color: Colors.green,
                  icon: Icons.point_of_sale),
              const SizedBox(width: 8),
              _summaryCard('Total Paid',
                  'KES ${_totalPaid.toStringAsFixed(2)}',
                  color: Colors.blue,
                  icon: Icons.payments),
              const SizedBox(width: 8),
              _summaryCard('Balance Due',
                  'KES ${_totalBalance.toStringAsFixed(2)}',
                  color: Colors.red,
                  icon: Icons.money_off),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Table header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 70,
                child: Text('INV No.',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              SizedBox(
                width: 70,
                child: Text('Date',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              Expanded(
                child: Text('Total',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              Expanded(
                child: Text('Paid',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              SizedBox(
                width: 55,
                child: Text('Status',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _sales.isEmpty
              ? Center(
            child: Text(
              'No sales for $_filterLabel',
              style:
              const TextStyle(color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 12),
            itemCount: _sales.length,
            itemBuilder: (context, index) {
              final sale = _sales[index];
              final isEven = index % 2 == 0;
              final isPaid = sale['status'] == 'paid';

              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
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
                        'INV-${sale['id'].toString().padLeft(5, '0')}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 70,
                      child: Text(
                        _formatDate(sale['created_at']),
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'KES ${sale['total_amount']}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight:
                            FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'KES ${sale['amount_paid']}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blue),
                      ),
                    ),
                    SizedBox(
                      width: 55,
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 4,
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
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---- PURCHASE REPORT TAB ----
class _PurchaseReportTab extends StatefulWidget {
  @override
  State<_PurchaseReportTab> createState() =>
      _PurchaseReportTabState();
}

class _PurchaseReportTabState extends State<_PurchaseReportTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _purchases = [];
  bool _isLoading = true;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  String _filterLabel = 'Today';

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _start = DateTime(today.year, today.month, today.day);
    _end = DateTime(today.year, today.month, today.day, 23, 59, 59);
    _fetchPurchases();
  }

  Future<void> _fetchPurchases() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('purchases')
          .select('*, suppliers(name)')
          .gte('created_at', _start.toIso8601String())
          .lte('created_at', _end.toIso8601String())
          .order('created_at', ascending: false);
      setState(() {
        _purchases = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _totalPurchases =>
      _purchases.fold(0, (s, r) => s + (r['total_amount'] ?? 0));
  double get _totalPaid =>
      _purchases.fold(0, (s, r) => s + (r['amount_paid'] ?? 0));
  double get _totalBalance =>
      _purchases.fold(0, (s, r) => s + (r['balance'] ?? 0));

  String _formatDate(String d) {
    final date = DateTime.parse(d).toLocal();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _DateFilter(
          onFilterChanged: (start, end, label) {
            _start = start;
            _end = end;
            _filterLabel = label;
            _fetchPurchases();
          },
        ),
        const SizedBox(height: 10),

        // Summary cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _summaryCard('Total Purchases',
                  'KES ${_totalPurchases.toStringAsFixed(2)}',
                  color: Colors.orange,
                  icon: Icons.shopping_cart),
              const SizedBox(width: 8),
              _summaryCard('Total Paid',
                  'KES ${_totalPaid.toStringAsFixed(2)}',
                  color: Colors.blue,
                  icon: Icons.payments),
              const SizedBox(width: 8),
              _summaryCard('Balance Due',
                  'KES ${_totalBalance.toStringAsFixed(2)}',
                  color: Colors.red,
                  icon: Icons.money_off),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Table header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 65,
                child: Text('PO No.',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              SizedBox(
                width: 65,
                child: Text('Date',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              Expanded(
                child: Text('Supplier',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              Expanded(
                child: Text('Total',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              SizedBox(
                width: 55,
                child: Text('Status',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _purchases.isEmpty
              ? Center(
            child: Text(
              'No purchases for $_filterLabel',
              style:
              const TextStyle(color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 12),
            itemCount: _purchases.length,
            itemBuilder: (context, index) {
              final p = _purchases[index];
              final isEven = index % 2 == 0;
              final isPaid = p['status'] == 'paid';

              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
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
                      width: 65,
                      child: Text(
                        'PO-${p['id'].toString().padLeft(5, '0')}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight:
                            FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      width: 65,
                      child: Text(
                        _formatDate(p['created_at']),
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        p['suppliers']?['name'] ?? '-',
                        style: const TextStyle(
                            fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'KES ${p['total_amount']}',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.orange,
                            fontWeight:
                            FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 55,
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 4,
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
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---- P&L TAB ----
class _ProfitLossTab extends StatefulWidget {
  @override
  State<_ProfitLossTab> createState() => _ProfitLossTabState();
}

class _ProfitLossTabState extends State<_ProfitLossTab> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  String _filterLabel = 'Today';

  double _totalSales = 0;
  double _totalPurchases = 0;
  double _totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _start = DateTime(today.year, today.month, today.day);
    _end = DateTime(today.year, today.month, today.day, 23, 59, 59);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final sales = await supabase
          .from('sales')
          .select('total_amount')
          .gte('created_at', _start.toIso8601String())
          .lte('created_at', _end.toIso8601String());

      final purchases = await supabase
          .from('purchases')
          .select('total_amount')
          .gte('created_at', _start.toIso8601String())
          .lte('created_at', _end.toIso8601String());

      setState(() {
        _totalSales = (sales as List)
            .fold(0, (s, r) => s + (r['total_amount'] ?? 0));
        _totalPurchases = (purchases as List)
            .fold(0, (s, r) => s + (r['total_amount'] ?? 0));
        _totalExpenses = 0; // update when expenses module is built
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _grossProfit => _totalSales - _totalPurchases;
  double get _netProfit => _grossProfit - _totalExpenses;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        _DateFilter(
          onFilterChanged: (start, end, label) {
            _start = start;
            _end = end;
            _filterLabel = label;
            _fetchData();
          },
        ),
        const SizedBox(height: 16),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profit & Loss — $_filterLabel',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Income section
                  _sectionHeader('INCOME', Colors.green),
                  _plRow('Sales Revenue',
                      _totalSales, Colors.green),
                  const Divider(),
                  _plRow('Total Income',
                      _totalSales, Colors.green,
                      bold: true),
                  const SizedBox(height: 16),

                  // Expenses section
                  _sectionHeader('COST OF GOODS', Colors.orange),
                  _plRow('Purchases',
                      _totalPurchases, Colors.orange),
                  const Divider(),
                  _plRow('Total COGS',
                      _totalPurchases, Colors.orange,
                      bold: true),
                  const SizedBox(height: 16),

                  // Gross profit
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _grossProfit >= 0
                          ? Colors.green[50]
                          : Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _grossProfit >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GROSS PROFIT',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text(
                          'KES ${_grossProfit.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: _grossProfit >= 0
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Operating expenses
                  _sectionHeader(
                      'OPERATING EXPENSES', Colors.red),
                  _plRow('Expenses',
                      _totalExpenses, Colors.red),
                  const Divider(),
                  _plRow('Total Expenses',
                      _totalExpenses, Colors.red,
                      bold: true),
                  const SizedBox(height: 16),

                  // Net profit
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _netProfit >= 0
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _netProfit >= 0
                            ? Colors.green
                            : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('NET PROFIT',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Text(
                          'KES ${_netProfit.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _netProfit >= 0
                                  ? Colors.green
                                  : Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color),
      ),
    );
  }

  Widget _plRow(String label, double amount, Color color,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold
                      ? FontWeight.bold
                      : FontWeight.normal,
                  fontSize: 13)),
          Text(
            'KES ${amount.toStringAsFixed(2)}',
            style: TextStyle(
                fontWeight:
                bold ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
                color: color),
          ),
        ],
      ),
    );
  }
}

// ---- DEBTORS & CREDITORS TAB ----
class _DebtorsCreditorsTab extends StatefulWidget {
  @override
  State<_DebtorsCreditorsTab> createState() =>
      _DebtorsCreditorsTabState();
}

class _DebtorsCreditorsTabState
    extends State<_DebtorsCreditorsTab>
    with SingleTickerProviderStateMixin {
  final supabase = Supabase.instance.client;
  TabController? _innerTabController;
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _suppliers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _innerTabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _innerTabController?.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final customers = await supabase
          .from('customers')
          .select()
          .order('name');
      final suppliers = await supabase
          .from('suppliers')
          .select()
          .order('name');
      setState(() {
        _customers = List<Map<String, dynamic>>.from(customers);
        _suppliers = List<Map<String, dynamic>>.from(suppliers);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Inner tabs
        Container(
          color: Colors.grey[100],
          child: TabBar(
            controller: _innerTabController!,
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'Debtors (Customers)'),
              Tab(text: 'Creditors (Suppliers)'),
            ],
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
            controller: _innerTabController!,
            children: [
              // Debtors
              _buildCustomerList(),
              // Creditors
              _buildSupplierList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerList() {
    final debtors = _customers
        .where((c) => (c['opening_balance'] ?? 0) > 0)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Debtors',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'KES ${debtors.fold(0.0, (s, c) => s + (c['opening_balance'] ?? 0)).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Header
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
                  child: Text('Customer',
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
                Expanded(
                  flex: 2,
                  child: Text('Balance',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          Expanded(
            child: debtors.isEmpty
                ? const Center(
                child: Text('No debtors',
                    style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: debtors.length,
              itemBuilder: (context, index) {
                final c = debtors[index];
                final isEven = index % 2 == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  color: isEven
                      ? Colors.grey[50]
                      : Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(c['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                            overflow:
                            TextOverflow.ellipsis),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                            c['phone'] ?? '-',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'KES ${(c['opening_balance'] ?? 0).toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
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

  Widget _buildSupplierList() {
    final creditors = _suppliers
        .where((s) => (s['opening_balance'] ?? 0) > 0)
        .toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Creditors',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'KES ${creditors.fold(0.0, (s, c) => s + (c['opening_balance'] ?? 0)).toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Header
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
                  child: Text('Supplier',
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
                Expanded(
                  flex: 2,
                  child: Text('Balance',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          Expanded(
            child: creditors.isEmpty
                ? const Center(
                child: Text('No creditors',
                    style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              itemCount: creditors.length,
              itemBuilder: (context, index) {
                final s = creditors[index];
                final isEven = index % 2 == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  color: isEven
                      ? Colors.grey[50]
                      : Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(s['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                            overflow:
                            TextOverflow.ellipsis),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                            s['phone'] ?? '-',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'KES ${(s['opening_balance'] ?? 0).toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold),
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

// ---- STOCK REPORT TAB ----
class _StockReportTab extends StatefulWidget {
  @override
  State<_StockReportTab> createState() => _StockReportTabState();
}

class _StockReportTabState extends State<_StockReportTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  String _filter = 'All';

  final List<String> _filters = ['All', 'Low Stock', 'Out of Stock'];

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
          .select(
          'id, name, opening_stock, buying_price, selling_price, categories(name)')
          .order('name');
      setState(() {
        _products = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    switch (_filter) {
      case 'Low Stock':
        return _products
            .where((p) =>
        (p['opening_stock'] ?? 0) > 0 &&
            (p['opening_stock'] ?? 0) <= 10)
            .toList();
      case 'Out of Stock':
        return _products
            .where((p) => (p['opening_stock'] ?? 0) <= 0)
            .toList();
      default:
        return _products;
    }
  }

  double get _stockValue => _products.fold(
      0,
          (s, p) =>
      s +
          ((p['opening_stock'] ?? 0) * (p['buying_price'] ?? 0)));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),

        // Filter chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _filters.map((filter) {
              final isSelected = _filter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(filter,
                      style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                    color:
                    isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  onSelected: (_) =>
                      setState(() => _filter = filter),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 10),

        // Summary cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _summaryCard('Total Items',
                  '${_products.length} items',
                  color: Colors.blue,
                  icon: Icons.inventory_2),
              const SizedBox(width: 8),
              _summaryCard('Stock Value',
                  'KES ${_stockValue.toStringAsFixed(2)}',
                  color: Colors.green,
                  icon: Icons.attach_money),
              const SizedBox(width: 8),
              _summaryCard('Out of Stock',
                  '${_products.where((p) => (p['opening_stock'] ?? 0) <= 0).length} items',
                  color: Colors.red,
                  icon: Icons.warning),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Table header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
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
                        fontSize: 11)),
              ),
              Expanded(
                flex: 2,
                child: Text('Category',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              SizedBox(
                width: 45,
                child: Text('Qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
              SizedBox(
                width: 70,
                child: Text('Value',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredProducts.isEmpty
              ? const Center(
              child: Text('No items',
                  style: TextStyle(color: Colors.grey)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 12),
            itemCount: _filteredProducts.length,
            itemBuilder: (context, index) {
              final p = _filteredProducts[index];
              final isEven = index % 2 == 0;
              final qty =
              (p['opening_stock'] ?? 0).toInt();
              final value = qty *
                  (p['buying_price'] ?? 0).toDouble();

              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: qty <= 0
                      ? Colors.red[50]
                      : qty <= 10
                      ? Colors.orange[50]
                      : isEven
                      ? Colors.grey[50]
                      : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                        color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        p['name'],
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.w500),
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        p['categories']?['name'] ??
                            '-',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey),
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 45,
                      child: Container(
                        padding:
                        const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2),
                        decoration: BoxDecoration(
                          color: qty <= 0
                              ? Colors.red
                              : qty <= 10
                              ? Colors.orange
                              : Colors.green,
                          borderRadius:
                          BorderRadius.circular(
                              10),
                        ),
                        child: Text(
                          '$qty',
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
                      width: 70,
                      child: Text(
                        'KES ${value.toStringAsFixed(0)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                            fontWeight:
                            FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}