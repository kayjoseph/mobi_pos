import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/app_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  final String username;

  const Home({super.key, required this.username});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();
  final supabase = Supabase.instance.client;

  // Stats
  int _totalCustomers = 0;
  int _totalSuppliers = 0;
  double _todaySales = 0;
  double _monthSales = 0;
  int _pendingSales = 0;
  int _pendingPurchases = 0;
  int _totalInvoicesMonth = 0;
  bool _isLoading = true;

  // Pie chart data — sales by category
  List<Map<String, dynamic>> _salesByCategory = [];

  final List<Color> _chartColors = [
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Welcome, ${widget.username}!',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
      );
    });
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final now = DateTime.now();
      final todayStart =
      DateTime(now.year, now.month, now.day).toIso8601String();
      final todayEnd = DateTime(
          now.year, now.month, now.day, 23, 59, 59)
          .toIso8601String();
      final monthStart =
      DateTime(now.year, now.month, 1).toIso8601String();

      // Customers count
      final customers = await supabase
          .from('customers')
          .select('id', const FetchOptions(count: CountOption.exact));

      // Suppliers count
      final suppliers = await supabase
          .from('suppliers')
          .select('id', const FetchOptions(count: CountOption.exact));

      // Today sales
      final todaySalesData = await supabase
          .from('sales')
          .select('total_amount')
          .gte('created_at', todayStart)
          .lte('created_at', todayEnd);

      // Month sales + invoices
      final monthSalesData = await supabase
          .from('sales')
          .select('total_amount, status')
          .gte('created_at', monthStart);

      // Pending purchases
      final pendingPurchases = await supabase
          .from('purchases')
          .select('id', const FetchOptions(count: CountOption.exact))
          .eq('status', 'unpaid');

      // Sales by category from items jsonb
      final allSales = await supabase
          .from('sales')
          .select('items')
          .gte('created_at', monthStart);

      // Process category sales
      final Map<String, double> categoryTotals = {};
      for (final sale in allSales) {
        final items = sale['items'] as List<dynamic>;
        for (final item in items) {
          // We use product name first letter as category placeholder
          // This will be improved when category is stored in sales items
          final name = item['name'].toString();
          final subtotal =
          (item['subtotal'] ?? 0).toDouble();
          categoryTotals[name] =
              (categoryTotals[name] ?? 0) + subtotal;
        }
      }

      // Get actual categories from products in sales
      final productsData = await supabase
          .from('products')
          .select('name, categories(name)');

      final Map<String, String> productCategoryMap = {};
      for (final p in productsData) {
        productCategoryMap[p['name']] =
            p['categories']?['name'] ?? 'Other';
      }

      final Map<String, double> catSales = {};
      categoryTotals.forEach((productName, total) {
        final cat =
            productCategoryMap[productName] ?? 'Other';
        catSales[cat] = (catSales[cat] ?? 0) + total;
      });

      final List<Map<String, dynamic>> salesByCategory =
      catSales.entries
          .map((e) => {'name': e.key, 'total': e.value})
          .toList()
        ..sort((a, b) =>
            (b['total'] as double)
                .compareTo(a['total'] as double));

      setState(() {
        _totalCustomers = customers.count ?? 0;
        _totalSuppliers = suppliers.count ?? 0;
        _todaySales = (todaySalesData as List).fold(
            0, (s, r) => s + (r['total_amount'] ?? 0));
        _totalInvoicesMonth = (monthSalesData as List).length;
        _monthSales = (monthSalesData as List).fold(
            0, (s, r) => s + (r['total_amount'] ?? 0));
        _pendingSales = (monthSalesData as List)
            .where((s) => s['status'] == 'unpaid')
            .length;
        _pendingPurchases = pendingPurchases.count ?? 0;
        _salesByCategory = salesByCategory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 10, 0),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: Text(
            widget.username,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'change_password',
          child: Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text('Change Password'),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'change_password') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Change password coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  // ---- STAT CARD ----
  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          if (subtitle != null)
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  // ---- SECTION HEADER ----
  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Refresh
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchDashboardData,
            tooltip: 'Refresh',
          ),
          GestureDetector(
            onTap: () => _showProfileMenu(context),
            child: CircleAvatar(
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
          ),
          const SizedBox(width: 10),
          TextButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
      ),
      drawer: AppDrawer(
        username: widget.username,
        currentPage: 'Dashboard',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- TODAY SALES + MONTH SALES ----
              _sectionHeader(
                  "Today's Overview", Icons.today),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: "Today's Sales",
                      value:
                      'KES ${_todaySales.toStringAsFixed(0)}',
                      icon: Icons.point_of_sale,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      title: 'Pending Sales',
                      value: '$_pendingSales',
                      icon: Icons.pending_actions,
                      color: Colors.orange,
                      subtitle: 'Unpaid invoices',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // ---- MONTH STATS ----
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: 'Month Sales',
                      value:
                      'KES ${_monthSales.toStringAsFixed(0)}',
                      icon: Icons.calendar_month,
                      color: Colors.blue,
                      subtitle: '$_totalInvoicesMonth invoices',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      title: 'Pending Purchases',
                      value: '$_pendingPurchases',
                      icon: Icons.shopping_cart,
                      color: Colors.red,
                      subtitle: 'Unpaid orders',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---- CUSTOMERS + SUPPLIERS ----
              _sectionHeader(
                  'Business Overview', Icons.business),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      title: 'Customers',
                      value: '$_totalCustomers',
                      icon: Icons.people,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _statCard(
                      title: 'Suppliers',
                      value: '$_totalSuppliers',
                      icon: Icons.store,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---- PIE CHART ----
              _sectionHeader(
                  'Sales by Category (This Month)',
                  Icons.pie_chart),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: _salesByCategory.isEmpty
                    ? const SizedBox(
                  height: 120,
                  child: Center(
                    child: Text(
                      'No sales data for this month',
                      style: TextStyle(
                          color: Colors.grey),
                    ),
                  ),
                )
                    : Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: List.generate(
                            _salesByCategory.length,
                                (index) {
                              final item =
                              _salesByCategory[
                              index];
                              final total =
                              _salesByCategory.fold(
                                  0.0,
                                      (s, e) =>
                                  s +
                                      (e['total']
                                      as double));
                              final pct =
                              ((item['total']
                              as double) /
                                  total *
                                  100)
                                  .toStringAsFixed(
                                  1);
                              return PieChartSectionData(
                                value: (item['total']
                                as double)
                                    .toDouble(),
                                title: '$pct%',
                                color: _chartColors[
                                index %
                                    _chartColors
                                        .length],
                                radius: 70,
                                titleStyle:
                                const TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          sectionsSpace: 2,
                          centerSpaceRadius: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Legend
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: List.generate(
                        _salesByCategory.length,
                            (index) {
                          final item =
                          _salesByCategory[index];
                          return Row(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration:
                                BoxDecoration(
                                  color: _chartColors[
                                  index %
                                      _chartColors
                                          .length],
                                  borderRadius:
                                  BorderRadius
                                      .circular(3),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${item['name']} — KES ${(item['total'] as double).toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 11),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}