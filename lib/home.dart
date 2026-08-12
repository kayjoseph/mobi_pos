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
