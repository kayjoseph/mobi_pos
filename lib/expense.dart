import 'package:flutter/material.dart';
import 'package:mobi_pos/login_page.dart';
import 'package:mobi_pos/app_drawer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Expense extends StatefulWidget {
  final String username;
  const Expense({super.key, required this.username});

  @override
  State<Expense> createState() => _ExpenseState();
}

class _ExpenseState extends State<Expense>
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
          'Expenses',
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
            Tab(icon: Icon(Icons.add_card), text: 'New Expense'),
            Tab(icon: Icon(Icons.list_alt), text: 'Expense List'),
          ],
        ),
      ),
      drawer: AppDrawer(
        username: widget.username,
        currentPage: 'Expenses',
      ),
      body: TabBarView(
        controller: _tabController!,
        children: [
          _NewExpenseTab(
            username: widget.username,
            tabController: _tabController!,
          ),
          const _ExpenseListTab(),
        ],
      ),
    );
  }
}

// ---- NEW EXPENSE TAB ----
class _NewExpenseTab extends StatefulWidget {
  final String username;
  final TabController tabController;

  const _NewExpenseTab({
    required this.username,
    required this.tabController,
  });

  @override
  State<_NewExpenseTab> createState() => _NewExpenseTabState();
}

class _NewExpenseTabState extends State<_NewExpenseTab> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();

  bool _isSaving = false;
  String _selectedCategory = 'Rent';
  String _selectedPaymentMethod = 'Cash';

  final List<String> _categories = [
    'Rent',
    'Salaries',
    'Utilities',
    'Transport',
    'Stationery',
    'Maintenance',
    'Marketing',
    'Insurance',
    'Taxes',
    'Other',
  ];

  final List<String> _paymentMethods = ['Cash', 'M-Pesa', 'Bank'];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    _referenceController.clear();
    setState(() {
      _selectedCategory = 'Rent';
      _selectedPaymentMethod = 'Cash';
    });
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      await supabase.from('expenses').insert({
        'category': _selectedCategory,
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
        'payment_method': _selectedPaymentMethod,
        'reference': _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        'created_by': widget.username,
      });

      _clearForm();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense saved successfully'),
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
              'Expense Details',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Expense Category *',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _categories.map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(cat),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedCategory = value!),
              validator: (value) =>
              value == null ? 'Please select a category' : null,
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount *',
                prefixText: 'KES ',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value!.trim().isEmpty) return 'Amount is required';
                if (double.tryParse(value) == null) {
                  return 'Enter a valid amount';
                }
                if (double.parse(value) <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'e.g. Monthly office rent for January',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Payment method
            const Text('Payment Method',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: _paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                            () => _selectedPaymentMethod = method),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding:
                      const EdgeInsets.symmetric(vertical: 12),
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

            // Reference
            TextFormField(
              controller: _referenceController,
              maxLength: 30,
              decoration: const InputDecoration(
                labelText: 'Reference (optional)',
                hintText: 'e.g. Receipt no, Invoice no',
                prefixIcon: Icon(Icons.receipt),
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 30),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isSaving ? null : _clearForm,
                    icon: const Icon(Icons.clear, color: Colors.red),
                    label: const Text('Cancel',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    style: OutlinedButton.styleFrom(
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveExpense,
                    icon: _isSaving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                        : const Icon(Icons.save,
                        color: Colors.white),
                    label: Text(
                      _isSaving ? 'Saving...' : 'Save Expense',
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

// ---- EXPENSE LIST TAB ----
class _ExpenseListTab extends StatefulWidget {
  const _ExpenseListTab();

  @override
  State<_ExpenseListTab> createState() => _ExpenseListTabState();
}

class _ExpenseListTabState extends State<_ExpenseListTab> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = true;
  String _selectedFilter = 'Today';

  final List<String> _filters = [
    'Today',
    'Yesterday',
    'Last 7 Days',
    'Last Month',
    'Last 3 Months',
  ];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  DateTime get _startDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_selectedFilter) {
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
    final today = DateTime(now.year, now.month, now.day);
    if (_selectedFilter == 'Yesterday') {
      return today;
    }
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  Future<void> _fetchExpenses() async {
    setState(() => _isLoading = true);
    try {
      final data = await supabase
          .from('expenses')
          .select()
          .gte('created_at', _startDate.toIso8601String())
          .lte('created_at', _endDate.toIso8601String())
          .order('created_at', ascending: false);
      setState(() {
        _expenses = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _totalExpenses =>
      _expenses.fold(0, (s, e) => s + (e['amount'] ?? 0));

  String _formatDate(String d) {
    final date = DateTime.parse(d).toLocal();
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _deleteExpense(Map<String, dynamic> expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Expense'),
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
              '"${expense['category']} — KES ${expense['amount']}"?',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 15),
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
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await supabase
            .from('expenses')
            .delete()
            .eq('id', expense['id']);
        _fetchExpenses();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense deleted'),
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
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Date filter chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
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
                    onSelected: (_) {
                      setState(() => _selectedFilter = filter);
                      _fetchExpenses();
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),

          // Total + refresh row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  'Total: KES ${_totalExpenses.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _fetchExpenses,
                icon:
                const Icon(Icons.refresh, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Table header
          Container(
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
                    child: Text('Date',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                Expanded(
                    flex: 2,
                    child: Text('Category',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                Expanded(
                    flex: 3,
                    child: Text('Description',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                SizedBox(
                    width: 75,
                    child: Text('Amount',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11))),
                SizedBox(width: 36),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _expenses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long,
                      size: 60,
                      color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'No expenses for $_selectedFilter',
                    style: const TextStyle(
                        color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _expenses.length,
              itemBuilder: (context, index) {
                final expense = _expenses[index];
                final isEven = index % 2 == 0;

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
                      // Date
                      SizedBox(
                        width: 70,
                        child: Text(
                          _formatDate(
                              expense['created_at']),
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey),
                        ),
                      ),
                      // Category
                      Expanded(
                        flex: 2,
                        child: Text(
                          expense['category'],
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight:
                              FontWeight.w600),
                          overflow:
                          TextOverflow.ellipsis,
                        ),
                      ),
                      // Description
                      Expanded(
                        flex: 3,
                        child: Text(
                          expense['description'] ?? '-',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey),
                          overflow:
                          TextOverflow.ellipsis,
                        ),
                      ),
                      // Amount
                      SizedBox(
                        width: 75,
                        child: Text(
                          'KES ${expense['amount']}',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.red,
                              fontWeight:
                              FontWeight.bold),
                        ),
                      ),
                      // Delete
                      SizedBox(
                        width: 36,
                        child: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.red,
                              size: 18),
                          padding: EdgeInsets.zero,
                          onPressed: () =>
                              _deleteExpense(expense),
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