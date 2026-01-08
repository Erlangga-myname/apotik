import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/empty_state.dart';
import 'add_transaction_screen.dart';

/// Transactions screen showing sales history
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactionProvider = context.watch<TransactionProvider>();
    final transactions = transactionProvider.transactions;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Transactions'),
      body: transactions.isEmpty
          ? const EmptyState(
              icon: Icons.receipt_long,
              title: 'No Transactions',
              message: 'Record your first sale to see transaction history',
            )
          : Column(
              children: [
                // Total sales summary
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Sales',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.white.withOpacity(0.9),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatter.formatCurrency(transactionProvider.totalSales),
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transactions.length} transactions',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                      ),
                    ],
                  ),
                ),
                
                // Transactions list
                Expanded(
                  child: ListView.builder(
                    itemCount: transactions.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.receipt,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          transaction.productName,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormatter.formatDateTime(transaction.transactionDate),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    DateFormatter.formatCurrency(transaction.totalAmount),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _InfoChip(
                                    label: 'Quantity',
                                    value: '${transaction.quantity}',
                                    icon: Icons.shopping_cart,
                                  ),
                                  _InfoChip(
                                    label: 'Unit Price',
                                    value: DateFormatter.formatCurrency(transaction.unitPrice),
                                    icon: Icons.attach_money,
                                  ),
                                ],
                              ),
                              if (transaction.customerName != null && transaction.customerName!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Customer: ${transaction.customerName}',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                              if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.note, size: 16, color: AppColors.textSecondary),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Notes: ${transaction.notes}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Sale'),
      ),
    );
  }
}

/// Info chip widget for transaction details
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
