import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:quan_ly_chi_tieu/screens/transactions_screen.dart';

/// Model tạm cho Transaction
class SimpleTransaction {
  final String type; // 'income' hoặc 'expense'
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

  int _chartMode = 6;
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

    double income = 0;
    double expense = 0;
    final List<SimpleTransaction> allTx = [];
    for (var doc in qs.docs) {
      final data = doc.data();
      final type = data['type'] ?? 'expense';
      final amount = (data['amount'] ?? 0).toDouble();
      final ts = data['date'] as Timestamp?;
      final date = ts?.toDate() ?? DateTime.now();
      final desc = data['description'] ?? '';
      final cat = data['category'] ?? 'Khác';

      if (type == 'income') {
        income += amount;
      } else {
        expense += amount;
      }
      allTx.add(SimpleTransaction(type, amount, date, desc, cat));
    }
    _totalIncome = income;
    _totalExpense = expense;
    _allTransactions = allTx;

    _buildChartData();
    setState(() => _isLoading = false);
  }

  void _buildChartData() {
    if (_chartMode == 6) {
      _build6MonthsChart();
    } else {
      _build1MonthChart();
    }
  }

  void _build6MonthsChart() {
    final now = DateTime.now();
    int year = now.year;
    int startMonth = _isFirstHalf ? 1 : 7;
    int endMonth = _isFirstHalf ? 6 : 12;

    final Map<int, double> monthlyExpense = {};
    for (int m = startMonth; m <= endMonth; m++) {
      monthlyExpense[m] = 0;
    }

    for (var tx in _allTransactions) {
      if (tx.type == 'expense' && tx.date.year == year) {
        final m = tx.date.month;
        if (m >= startMonth && m <= endMonth) {
          monthlyExpense[m] = (monthlyExpense[m] ?? 0) + tx.amount;
        }
      }
    }

    final List<FlSpot> spots = [];
    int index = 0;
    for (int m = startMonth; m <= endMonth; m++) {
      final val = monthlyExpense[m] ?? 0;
      spots.add(FlSpot(index.toDouble(), val));
      index++;
    }
    double maxY = 0;
    for (var s in spots) {
      if (s.y > maxY) maxY = s.y;
    }
    setState(() {
      _lineSpots = spots;
      _maxY = maxY;
    });
  }

  void _build1MonthChart() {
    int year = _selectedYear;
    int month = _selectedMonth;
    int lastDay = DateTime(year, month + 1, 0).day;

    final Map<int, double> dailyExpense = {};
    for (int d = 1; d <= lastDay; d++) {
      dailyExpense[d] = 0;
    }

    for (var tx in _allTransactions) {
      if (tx.type == 'expense' &&
          tx.date.year == year &&
          tx.date.month == month) {
        dailyExpense[tx.date.day] =
            (dailyExpense[tx.date.day] ?? 0) + tx.amount;
      }
    }
    final List<FlSpot> spots = [];
    for (int d = 1; d <= lastDay; d++) {
      spots.add(FlSpot((d - 1).toDouble(), dailyExpense[d] ?? 0));
    }
    double maxY = 0;
    for (var s in spots) {
      if (s.y > maxY) maxY = s.y;
    }
    setState(() {
      _lineSpots = spots;
      _maxY = maxY;
    });
  }

  Widget _buildChartModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text("1 tháng"),
          selected: _chartMode == 1,
          onSelected: (selected) {
            if (selected) {
              setState(() => _chartMode = 1);
              _buildChartData();
            }
          },
        ),
        const SizedBox(width: 16),
        ChoiceChip(
          label: const Text("6 tháng"),
          selected: _chartMode == 6,
          onSelected: (selected) {
            if (selected) {
              setState(() => _chartMode = 6);
              _buildChartData();
            }
          },
        ),
      ],
    );
  }

  Widget _buildMonthDropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Chọn tháng: "),
        DropdownButton<int>(
          value: _selectedMonth,
          items: List.generate(12, (index) {
            int m = index + 1;
            return DropdownMenuItem(value: m, child: Text("M$m"));
          }),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedMonth = val);
              _buildChartData();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSixMonthDropdown() {
    return Row(
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
  }

  /// Hàm tính ticks: 4 mốc => [0, step, 2step, maxY]
  /// step = (maxY / 3).roundToDouble()
  List<double> _getCustomTicks(double maxY) {
    if (maxY <= 0) {
      return [0, 1];
    }
    double step = (maxY / 3).roundToDouble();
    if (step < 1) step = 1; // tránh step=0
    List<double> ticks = [0, step, step * 2];
    if (step * 2 < maxY) {
      ticks.add(maxY);
    }
    // nếu step*2 == maxY, thì 3 mốc. Nếu step*2 > maxY => ta vẫn add maxY
    // => [0, step, step*2, maxY] (có thể trùng step*2==maxY => hiển thị 3 mốc)
    return ticks;
  }

  Widget _buildLineChart() {
    double chartMaxY = _maxY <= 0 ? 1 : _maxY;
    List<double> ticks = _getCustomTicks(chartMaxY);

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
                // So sánh value với ticks
                double nearest = _findNearest(value, ticks);
                if ((nearest - value).abs() < 0.5) {
                  // In integer => .toStringAsFixed(0)
                  // Ví dụ 5800 => "5800", 1933 => "1933"
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
                  // 6 tháng => M + actualMonth
                  int startMonth = _isFirstHalf ? 1 : 7;
                  int index = value.toInt();
                  int actualMonth = startMonth + index;
                  return Transform.translate(
                    offset: const Offset(0, 6),
                    child: Text(
                      "M$actualMonth",
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                } else {
                  // 1 tháng => hiển thị day
                  final day = value.toInt() + 1;
                  return Transform.translate(
                    offset: const Offset(0, 6),
                    child: Text("$day", style: const TextStyle(fontSize: 12)),
                  );
                }
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

  /// Tìm tick y gần nhất
  double _findNearest(double value, List<double> ticks) {
    double minDiff = double.infinity;
    double nearest = value;
    for (double t in ticks) {
      double diff = (t - value).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearest = t;
      }
    }
    return nearest;
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
        if (snapshot.hasError) {
          return Text("Lỗi: ${snapshot.error}");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("Không có khoản chi gần đây");
        }

        final docs = snapshot.data!.docs;
        final List<SimpleTransaction> allTx =
            docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final type = data['type'] ?? 'expense';
              final amount = (data['amount'] ?? 0).toDouble();
              final desc = data['description'] ?? '';
              final category = data['category'] ?? 'Khác';
              final ts = data['date'] as Timestamp?;
              final dt = ts?.toDate() ?? DateTime.now();
              return SimpleTransaction(type, amount, dt, desc, category);
            }).toList();

        final expenseTx = allTx.where((tx) => tx.type == 'expense').toList();
        expenseTx.sort((a, b) => b.date.compareTo(a.date));
        final recent = expenseTx.take(3).toList();

        if (recent.isEmpty) {
          return const Text("Không có khoản chi gần đây");
        }

        return Column(
          children:
              recent.map((tx) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

                      // Toggle biểu đồ
                      _buildChartModeToggle(),
                      const SizedBox(height: 16),

                      // Dropdown theo chế độ
                      _chartMode == 1
                          ? _buildMonthDropdown()
                          : _buildSixMonthDropdown(),
                      const SizedBox(height: 16),

                      // Biểu đồ
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

                      // Recent Transaction
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
                                  builder:
                                      (context) => const TransactionScreen(),
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
