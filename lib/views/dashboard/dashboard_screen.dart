import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../services/product_service.dart';
import '../../services/transaction_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_indicator.dart';
import '../products/products_screen.dart';
import '../categories/categories_screen.dart';
import '../transactions/transactions_screen.dart';
import '../auth/login_screen.dart';

/// Main dashboard screen with bottom navigation
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final ProductService _productService = ProductService();
  final TransactionService _transactionService = TransactionService();
  
  int _totalProducts = 0;
  int _lowStockCount = 0;
  double _totalSales = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      final totalProducts = await _productService.getTotalProductCount();
      final lowStock = await _productService.getLowStockCount();
      final sales = await _transactionService.getTotalSales();
      
      setState(() {
        _totalProducts = totalProducts;
        _lowStockCount = lowStock;
        _totalSales = sales;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDashboardHome() {
    final authProvider = context.watch<AuthProvider>();
    final userName = authProvider.user?.name ?? 'User';

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: _isLoading
            ? const LoadingIndicator()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome message
                      Card(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: AppColors.white.withOpacity(0.9),
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                userName,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Manage your pharmacy efficiently',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.white.withOpacity(0.8),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Statistics section
                      Text(
                        'Overview',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      
                      // Stats grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                        children: [
                          StatCard(
                            icon: Icons.inventory_2,
                            title: 'Total Products',
                            value: _totalProducts.toString(),
                            color: AppColors.primary,
                            onTap: () => setState(() => _currentIndex = 1),
                          ),
                          StatCard(
                            icon: Icons.warning_amber,
                            title: 'Low Stock',
                            value: _lowStockCount.toString(),
                            color: _lowStockCount > 0 ? AppColors.warning : AppColors.success,
                            onTap: () => setState(() => _currentIndex = 1),
                          ),
                          StatCard(
                            icon: Icons.attach_money,
                            title: 'Total Sales',
                            value: DateFormatter.formatCurrency(_totalSales),
                            color: AppColors.success,
                            onTap: () => setState(() => _currentIndex = 3),
                          ),
                          StatCard(
                            icon: Icons.receipt_long,
                            title: 'Transactions',
                            value: context.watch<TransactionProvider>().transactions.length.toString(),
                            color: AppColors.info,
                            onTap: () => setState(() => _currentIndex = 3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Quick actions
                      Text(
                        'Quick Actions',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.add_box,
                              title: 'Add Product',
                              color: AppColors.primary,
                              onTap: () => setState(() => _currentIndex = 1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _QuickActionCard(
                              icon: Icons.point_of_sale,
                              title: 'New Sale',
                              color: AppColors.secondary,
                              onTap: () => setState(() => _currentIndex = 3),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboardHome(),
      const ProductsScreen(),
      const CategoriesScreen(),
      const TransactionsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
        ],
      ),
    );
  }
}

/// Quick action card widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
