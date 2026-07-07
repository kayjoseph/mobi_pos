import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobi_pos/app_drawer.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---- SHARED DATE RANGE SELECTOR ----
class _DateRangeSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onTap;

  const _DateRangeSelector({
    required this.startDate,
    required this.endDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today,
                color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Text(
              '${fmt.format(startDate)}  →  ${fmt.format(endDate)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_drop_down,
                color: Colors.green),
          ],
        ),
      ),
    );
  }
}

// ---- SHARED SUMMARY CARD ----
Widget _summaryCard(String label, String value,
    {Color color = Colors.green, IconData icon = Icons.info}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: Colors.grey)),
        ],
      ),
    ),
  );
}

// ================================================================
// SALES REPORT
// ================================================================
class SalesReport extends StatefulWidget {
  final String username;
  const SalesReport({super.key, required this.username});

  @override
  State<SalesReport> createState() => _SalesReportState();
}

class _SalesReportState extends State<SalesReport> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _sales = [];
  bool _isLoading = false;
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _start = DateTime(today.year, today.month, today.day);
    _end = DateTime(today.year, today.month, today.day, 23, 59, 59);
    _fetchSales();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _start, end: _end),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme:
          const ColorScheme.light(primary: Colors.green),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = DateTime(picked.end.year, picked.end.month,
            picked.end.day, 23, 59, 59);
      });
      _fetchSales();
    }
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

  String _fmt(String d) =>
      DateFormat('dd/MM/yyyy').format(DateTime.parse(d).toLocal());

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    final fmt = DateFormat('dd/MM/yyyy');
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Sales Report',
              style: pw.TextStyle(
                  fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text(
              'Period: ${fmt.format(_start)} to ${fmt.format(_end)}'),
          pw.SizedBox(height: 16),
          pw.Row(children: [
            pw.Text(
                'Total: KES ${_totalSales.toStringAsFixed(2)}'),
            pw.SizedBox(width: 20),
            pw.Text('Paid: KES ${_totalPaid.toStringAsFixed(2)}'),
            pw.SizedBox(width: 20),
            pw.Text(
                'Balance: KES ${_totalBalance.toStringAsFixed(2)}'),
          ]),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: ['INV No.', 'Date', 'Total', 'Paid', 'Status'],
            data: _sales
                .map((s) => [
              'INV-${s['id'].toString().padLeft(5, '0')}',
              _fmt(s['created_at']),
              'KES ${s['total_amount']}',
              'KES ${s['amount_paid']}',
              s['status'].toString().toUpperCase(),
            ])
                .toList(),
            headerStyle:
            pw.TextStyle(fontWeight: pw.FontWeight.bold),
            border: pw.TableBorder.all(),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(
        onLayout: (format) async => pdf.save());
  }

  void _logout() => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (r) => false);

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
        title: const Text('Sales Report',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf,
                color: Colors.white),
            onPressed: _sales.isEmpty ? null : _downloadPdf,
          ),
          CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 18,
            child: Text(widget.username[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
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
      ),
      drawer: AppDrawer(
          username: widget.username, currentPage: 'Sales Report'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _DateRangeSelector(
                    startDate: _start,
                    endDate: _end,
                    onTap: _pickDateRange),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh,
                      color: Colors.green),
                  onPressed: _fetchSales,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _summaryCard(
                    'Total Sales',
                    'KES ${_totalSales.toStringAsFixed(2)}',
                    color: Colors.green,
                    icon: Icons.point_of_sale),
                const SizedBox(width: 8),
                _summaryCard(
                    'Total Paid',
                    'KES ${_totalPaid.toStringAsFixed(2)}',
                    color: Colors.blue,
                    icon: Icons.payments),
                const SizedBox(width: 8),
                _summaryCard(
                    'Balance',
                    'KES ${_totalBalance.toStringAsFixed(2)}',
                    color: Colors.red,
                    icon: Icons.money_off),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                SizedBox(
                    width: 75,
                    child: Text('INV No.',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                SizedBox(
                    width: 75,
                    child: Text('Date',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                Expanded(
                    child: Text('Total',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                Expanded(
                    child: Text('Paid',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                SizedBox(
                    width: 55,
                    child: Text('Status',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _sales.isEmpty
                ? const Center(
                child: Text('No sales for selected period',
                    style: TextStyle(color: Colors.grey)))
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
                            color: Colors.grey[200]!)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 75,
                        child: Text(
                          'INV-${sale['id'].toString().padLeft(5, '0')}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight:
                              FontWeight.w600),
                        ),
                      ),
                      SizedBox(
                        width: 75,
                        child: Text(
                            _fmt(sale['created_at']),
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey)),
                      ),
                      Expanded(
                          child: Text(
                              'KES ${sale['total_amount']}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight:
                                  FontWeight.bold))),
                      Expanded(
                          child: Text(
                              'KES ${sale['amount_paid']}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue))),
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
      ),
    );
  }
}

// ================================================================
// PURCHASE REPORT
// ================================================================
class PurchaseReport extends StatefulWidget {
  final String username;
  const PurchaseReport({super.key, required this.username});

  @override
  State<PurchaseReport> createState() => _PurchaseReportState();
}

class _PurchaseReportState extends State<PurchaseReport> {
  final supabase = Supabase.instance.client;
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _purchases = [];
  bool _isLoading = false;
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _start = DateTime(today.year, today.month, today.day);
    _end = DateTime(today.year, today.month, today.day, 23, 59, 59);
    _fetchPurchases();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _start, end: _end),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme:
          const ColorScheme.light(primary: Colors.green),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = DateTime(picked.end.year, picked.end.month,
            picked.end.day, 23, 59, 59);
      });
      _fetchPurchases();
    }
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

  String _fmt(String d) =>
      DateFormat('dd/MM/yyyy').format(DateTime.parse(d).toLocal());

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    final fmt = DateFormat('dd/MM/yyyy');
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text('Purchase Report',
              style: pw.TextStyle(
                  fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.Text(
              'Period: ${fmt.format(_start)} to ${fmt.format(_end)}'),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: [
              'PO No.',
              'Date',
              'Supplier',
              'Total',
              'Status'
            ],
            data: _purchases
                .map((p) => [
              'PO-${p['id'].toString().padLeft(5, '0')}',
              _fmt(p['created_at']),
              p['suppliers']?['name'] ?? '-',
              'KES ${p['total_amount']}',
              p['status'].toString().toUpperCase(),
            ])
                .toList(),
            headerStyle:
            pw.TextStyle(fontWeight: pw.FontWeight.bold),
            border: pw.TableBorder.all(),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(
        onLayout: (format) async => pdf.save());
  }

  void _logout() => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (r) => false);

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
        title: const Text('Purchase Report',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf,
                color: Colors.white),
            onPressed: _purchases.isEmpty ? null : _downloadPdf,
          ),
          CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 18,
            child: Text(widget.username[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
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
      ),
      drawer: AppDrawer(
          username: widget.username,
          currentPage: 'Purchase Report'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _DateRangeSelector(
                    startDate: _start,
                    endDate: _end,
                    onTap: _pickDateRange),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh,
                      color: Colors.green),
                  onPressed: _fetchPurchases,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _summaryCard(
                    'Total Purchases',
                    'KES ${_totalPurchases.toStringAsFixed(2)}',
                    color: Colors.orange,
                    icon: Icons.shopping_cart),
                const SizedBox(width: 8),
                _summaryCard(
                    'Total Paid',
                    'KES ${_totalPaid.toStringAsFixed(2)}',
                    color: Colors.blue,
                    icon: Icons.payments),
                const SizedBox(width: 8),
                _summaryCard(
                    'Balance',
                    'KES ${_totalBalance.toStringAsFixed(2)}',
                    color: Colors.red,
                    icon: Icons.money_off),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8)),
            child: const Row(
              children: [
                SizedBox(
                    width: 65,
                    child: Text('PO No.',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                SizedBox(
                    width: 70,
                    child: Text('Date',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                Expanded(
                    child: Text('Supplier',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                Expanded(
                    child: Text('Total',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                SizedBox(
                    width: 55,
                    child: Text('Status',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _purchases.isEmpty
                ? const Center(
                child: Text(
                    'No purchases for selected period',
                    style: TextStyle(color: Colors.grey)))
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
                            color: Colors.grey[200]!)),
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
                        width: 70,
                        child: Text(_fmt(p['created_at']),
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey)),
                      ),
                      Expanded(
                          child: Text(
                              p['suppliers']?['name'] ??
                                  '-',
                              style: const TextStyle(
                                  fontSize: 11),
                              overflow:
                              TextOverflow.ellipsis)),
                      Expanded(
                          child: Text(
                              'KES ${p['total_amount']}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange,
                                  fontWeight:
                                  FontWeight.bold))),
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
      ),
    );
  }
}

// ================================================================
// ACCOUNTING REPORTS (P&L)
// ================================================================
class AccountingReports extends StatefulWidget {
  final String username;
  const AccountingReports({super.key, required this.username});

  @override
  State<AccountingReports> createState() =>
      _AccountingReportsState();
}

class _AccountingReportsState extends State<AccountingReports>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _logout() => Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (r) => false);

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
        title: const Text('Accounting Reports',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 18,
            child: Text(widget.username[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
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
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
                icon: Icon(Icons.account_balance),
                text: 'P&L Statement'),
          ],
        ),
      ),
      drawer: AppDrawer(
          username: widget.username,
          currentPage: 'Accounting Reports'),
      body: TabBarView(
        controller: _tabController!,
        children: [
          _PLTab(username: widget.username),
        ],
      ),
    );
  }
}

// ---- P&L TAB ----
class _PLTab extends StatefulWidget {
  final String username;
  const _PLTab({required this.username});

  @override
  State<_PLTab> createState() => _PLTabState();
}

class _PLTabState extends State<_PLTab> {
  final supabase = Supabase.instance.client;
  bool _isLoading = false;
  late DateTime _start;
  late DateTime _end;
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

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _start, end: _end),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme:
          const ColorScheme.light(primary: Colors.green),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _start = picked.start;
        _end = DateTime(picked.end.year, picked.end.month,
            picked.end.day, 23, 59, 59);
      });
      _fetchData();
    }
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
        _totalExpenses = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _grossProfit => _totalSales - _totalPurchases;
  double get _netProfit => _grossProfit - _totalExpenses;

  Future<void> _downloadPdf() async {
    final pdf = pw.Document();
    final fmt = DateFormat('dd/MM/yyyy');
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Profit & Loss Statement',
                style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold)),
            pw.Text(
                'Period: ${fmt.format(_start)} to ${fmt.format(_end)}'),
            pw.SizedBox(height: 20),
            pw.Text('INCOME',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14)),
            pw.Divider(),
            _pdfRow('Sales Revenue',
                'KES ${_totalSales.toStringAsFixed(2)}'),
            pw.Divider(),
            _pdfRow('Total Income',
                'KES ${_totalSales.toStringAsFixed(2)}',
                bold: true),
            pw.SizedBox(height: 16),
            pw.Text('COST OF GOODS SOLD',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14)),
            pw.Divider(),
            _pdfRow('Purchases',
                'KES ${_totalPurchases.toStringAsFixed(2)}'),
            pw.Divider(),
            _pdfRow('Total COGS',
                'KES ${_totalPurchases.toStringAsFixed(2)}',
                bold: true),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(border: pw.Border.all()),
              child: _pdfRow(
                  'GROSS PROFIT',
                  'KES ${_grossProfit.toStringAsFixed(2)}',
                  bold: true),
            ),
            pw.SizedBox(height: 16),
            pw.Text('OPERATING EXPENSES',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14)),
            pw.Divider(),
            _pdfRow('Expenses',
                'KES ${_totalExpenses.toStringAsFixed(2)}'),
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration:
              pw.BoxDecoration(border: pw.Border.all(width: 2)),
              child: _pdfRow(
                  'NET PROFIT',
                  'KES ${_netProfit.toStringAsFixed(2)}',
                  bold: true),
            ),
          ],
        ),
      ),
    );
    await Printing.layoutPdf(
        onLayout: (format) async => pdf.save());
  }

  pw.Widget _pdfRow(String label, String value,
      {bool bold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                fontWeight: bold
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal)),
        pw.Text(value,
            style: pw.TextStyle(
                fontWeight: bold
                    ? pw.FontWeight.bold
                    : pw.FontWeight.normal)),
      ],
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
                  fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13)),
          Text('KES ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontWeight:
                  bold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                  color: color)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _DateRangeSelector(
                  startDate: _start,
                  endDate: _end,
                  onTap: _pickDateRange),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf,
                    color: Colors.green),
                onPressed: _downloadPdf,
              ),
              IconButton(
                icon: const Icon(Icons.refresh,
                    color: Colors.green),
                onPressed: _fetchData,
              ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('INCOME', Colors.green),
                  _plRow('Sales Revenue', _totalSales,
                      Colors.green),
                  const Divider(),
                  _plRow('Total Income', _totalSales, Colors.green,
                      bold: true),
                  const SizedBox(height: 16),
                  _sectionHeader('COST OF GOODS', Colors.orange),
                  _plRow('Purchases', _totalPurchases,
                      Colors.orange),
                  const Divider(),
                  _plRow('Total COGS', _totalPurchases,
                      Colors.orange,
                      bold: true),
                  const SizedBox(height: 16),
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
                              : Colors.red),
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
                                    : Colors.red)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sectionHeader(
                      'OPERATING EXPENSES', Colors.red),
                  _plRow('Expenses', _totalExpenses, Colors.red),
                  const Divider(),
                  _plRow('Total Expenses', _totalExpenses,
                      Colors.red,
                      bold: true),
                  const SizedBox(height: 16),
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
                          width: 2),
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
                                    : Colors.red)),
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
}