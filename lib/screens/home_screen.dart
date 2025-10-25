import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quan_ly_chi_tieu/screens/transactions_screen.dart';
// Import màn Chat
import 'package:quan_ly_chi_tieu/features/chat/presentation/pages/chat_screen.dart';

class SimpleTransaction {
  final String type; // 'income' | 'expense'
  final double amount;
  final DateTime date;
  final String description;
  final String category;
  SimpleTransaction(
    this.type,
    this.amount,
    this.date,
    this.description,
    this.category,
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _totalIncome = 0;
  double _totalExpense = 0;
  String _userName = "Người dùng";
  bool _isLoading = false;

  List<FlSpot> _lineSpots = [];
  double _maxY = 0;

  int _chartMode = 6; // 1: 1 tháng, 6: 6 tháng
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isFirstHalf = true;

  List<SimpleTransaction> _allTransactions = [];

  @override
  void initState() {
    super.initState();
    _fetchHomeData();
  }

  Future<void> _fetchHomeData() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    _userName = user.displayName ?? user.email ?? "Người dùng";

    final qs =
        await FirebaseFirestore.instance
            .collection("transactions")
            .where("userId", isEqualTo: user.uid)
            .get();

    double income = 0, expense = 0;
    final allTx = <SimpleTransaction>[];
    for (var doc in qs.docs) {
      final data = doc.data();
      final type = (data['type'] ?? 'expense') as String;
      final amount = (data['amount'] ?? 0).toDouble();
      final ts = data['date'] as Timestamp?;
      final date = ts?.toDate() ?? DateTime.now();
      final desc = data['description'] ?? '';
      final cat = data['category'] ?? 'Khác';

      if (type == 'income')
        income += amount;
      else
        expense += amount;
      allTx.add(SimpleTransaction(type, amount, date, desc, cat));
    }
    _totalIncome = income;
    _totalExpense = expense;
    _allTransactions = allTx;

    _buildChartData();
    setState(() => _isLoading = false);
  }

  void _buildChartData() =>
      _chartMode == 6 ? _build6MonthsChart() : _build1MonthChart();

  void _build6MonthsChart() {
    final now = DateTime.now();
    final year = now.year;
    final startMonth = _isFirstHalf ? 1 : 7;
    final endMonth = _isFirstHalf ? 6 : 12;

    final monthlyExpense = <int, double>{
      for (var m = startMonth; m <= endMonth; m++) m: 0,
    };
    for (var tx in _allTransactions) {
      if (tx.type == 'expense' && tx.date.year == year) {
        final m = tx.date.month;
        if (m >= startMonth && m <= endMonth) {
          monthlyExpense[m] = (monthlyExpense[m] ?? 0) + tx.amount;
        }
      }
    }

    final spots = <FlSpot>[];
    var idx = 0;
    for (var m = startMonth; m <= endMonth; m++) {
      spots.add(FlSpot(idx.toDouble(), monthlyExpense[m] ?? 0));
      idx++;
    }
    final maxY = spots.fold<double>(0, (p, s) => s.y > p ? s.y : p);
    setState(() {
      _lineSpots = spots;
      _maxY = maxY;
    });
  }

  void _build1MonthChart() {
    final year = _selectedYear;
    final month = _selectedMonth;
    final lastDay = DateTime(year, month + 1, 0).day;

    final dailyExpense = <int, double>{for (var d = 1; d <= lastDay; d++) d: 0};
    for (var tx in _allTransactions) {
      if (tx.type == 'expense' &&
          tx.date.year == year &&
          tx.date.month == month) {
        dailyExpense[tx.date.day] =
            (dailyExpense[tx.date.day] ?? 0) + tx.amount;
      }
    }

    final spots = <FlSpot>[
      for (var d = 1; d <= lastDay; d++)
        FlSpot((d - 1).toDouble(), (dailyExpense[d] ?? 0).toDouble()),
    ];
    final maxY = spots.fold<double>(0, (p, s) => s.y > p ? s.y : p);
    setState(() {
      _lineSpots = spots;
      _maxY = maxY;
    });
  }

  Widget _buildChartModeToggle() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ChoiceChip(
        label: const Text("1 tháng"),
        selected: _chartMode == 1,
        onSelected: (v) {
          if (v) {
            setState(() => _chartMode = 1);
            _buildChartData();
          }
        },
      ),
      const SizedBox(width: 16),
      ChoiceChip(
        label: const Text("6 tháng"),
        selected: _chartMode == 6,
        onSelected: (v) {
          if (v) {
            setState(() => _chartMode = 6);
            _buildChartData();
          }
        },
      ),
    ],
  );

  Widget _buildMonthDropdown() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Chọn tháng: "),
      DropdownButton<int>(
        value: _selectedMonth,
        items: List.generate(
          12,
          (i) => DropdownMenuItem(value: i + 1, child: Text("M${i + 1}")),
        ),
        onChanged: (val) {
          if (val != null) {
            setState(() => _selectedMonth = val);
            _buildChartData();
          }
        },
      ),
    ],
  );

  Widget _buildSixMonthDropdown() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Chọn: "),
      DropdownButton<bool>(
        value: _isFirstHalf,
        items: const [
          DropdownMenuItem(value: true, child: Text("6 tháng đầu")),
          DropdownMenuItem(value: false, child: Text("6 tháng cuối")),
        ],
        onChanged: (val) {
          if (val != null) {
            setState(() => _isFirstHalf = val);
            _buildChartData();
          }
        },
      ),
    ],
  );

  List<double> _getCustomTicks(double maxY) {
    if (maxY <= 0) return [0, 1];
    var step = (maxY / 3).roundToDouble();
    if (step < 1) step = 1;
    final ticks = [0, step, step * 2];
    if (step * 2 < maxY) ticks.add(maxY);
    return ticks.map((t) => t.toDouble()).toList();
  }

  Widget _buildLineChart() {
    final chartMaxY = _maxY <= 0 ? 1.0 : _maxY;
    final ticks = _getCustomTicks(chartMaxY);
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: _lineSpots.isEmpty ? 0 : (_lineSpots.length - 1).toDouble(),
        minY: 0,
        maxY: chartMaxY,
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                final nearest = _findNearest(value, ticks);
                if ((nearest - value).abs() < 0.5) {
                  return Text(
                    nearest.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (_chartMode == 6) {
                  final startMonth = _isFirstHalf ? 1 : 7;
                  final actualMonth = startMonth + value.toInt();
                  return Transform.translate(
                    offset: const Offset(0, 6),
                    child: Text(
                      "M$actualMonth",
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                } else {
                  final day = value.toInt() + 1;
                  return Transform.translate(
                    offset: const Offset(0, 6),
                    child: Text("$day", style: const TextStyle(fontSize: 12)),
                  );
                }
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: _lineSpots,
            isCurved: true,
            color: Colors.purple,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.purple.withOpacity(0.0)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _findNearest(double value, List<double> ticks) {
    var minDiff = double.infinity;
    var nearest = value;
    for (final t in ticks) {
      final diff = (t - value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearest = t;
      }
    }
    return nearest;
  }

  Widget _buildBalanceCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: color, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentExpense() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Text("Chưa đăng nhập");
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection("transactions")
              .where("userId", isEqualTo: user.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Text("Lỗi: ${snapshot.error}");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("Không có khoản chi gần đây");
        }
        final allTx =
            snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final type = data['type'] ?? 'expense';
              final amount = (data['amount'] ?? 0).toDouble();
              final desc = data['description'] ?? '';
              final cat = data['category'] ?? 'Khác';
              final ts = data['date'] as Timestamp?;
              final dt = ts?.toDate() ?? DateTime.now();
              return SimpleTransaction(type, amount, dt, desc, cat);
            }).toList();

        final recent =
            allTx.where((t) => t.type == 'expense').toList()
              ..sort((a, b) => b.date.compareTo(a.date));
        final show = recent.take(3).toList();
        if (show.isEmpty) return const Text("Không có khoản chi gần đây");

        return Column(
          children:
              show.map((tx) {
                final timeString = DateFormat('dd/MM').format(tx.date);
                return _buildTransactionItem(
                  title: tx.category,
                  subtitle:
                      (tx.description.isNotEmpty
                          ? tx.description
                          : "Không có mô tả") +
                      " - $timeString",
                  time: DateFormat.jm().format(tx.date),
                  amount: -tx.amount,
                  color: Colors.red,
                  icon: Icons.shopping_bag,
                );
              }).toList(),
        );
      },
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required String time,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount < 0
                    ? "-\$${amount.abs().toStringAsFixed(0)}"
                    : "+\$${amount.toStringAsFixed(0)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: amount < 0 ? Colors.red : Colors.green,
                ),
              ),
              Text(
                time,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== Build duy nhất (có AppBar + FAB mở Chat) =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            tooltip: 'Hỏi cố vấn chi tiêu',
            icon: const Icon(Icons.support_agent),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab_chat',
        icon: const Icon(Icons.chat),
        label: const Text('Cố vấn'),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ChatScreen()));
        },
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[200],
                            ),
                            child: const Icon(Icons.person, color: Colors.grey),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Xin chào, $_userName!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Thu nhập & Khoản chi
                      Row(
                        children: [
                          Expanded(
                            child: _buildBalanceCard(
                              'Thu nhập',
                              '\$${_totalIncome.toStringAsFixed(0)}',
                              Colors.green,
                              Icons.arrow_downward,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildBalanceCard(
                              'Khoản chi',
                              '\$${_totalExpense.toStringAsFixed(0)}',
                              Colors.red,
                              Icons.arrow_upward,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildChartModeToggle(),
                      const SizedBox(height: 16),
                      _chartMode == 1
                          ? _buildMonthDropdown()
                          : _buildSixMonthDropdown(),
                      const SizedBox(height: 16),

                      const Text(
                        'Tần suất chi tiêu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 200,
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            _lineSpots.isEmpty
                                ? const Center(
                                  child: Text("Chưa có dữ liệu chi tiêu"),
                                )
                                : _buildLineChart(),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Transaction',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TransactionScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'View All',
                              style: TextStyle(color: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRecentExpense(),
                    ],
                  ),
                ),
      ),
    );
  }
}
