import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product_model.dart';
import '../../models/transaction_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/date_formatter.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Add transaction (new sale) screen
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _notesController = TextEditingController();

  ProductModel? _selectedProduct;
  double _totalAmount = 0;

  @override
  void dispose() {
    _quantityController.dispose();
    _customerNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateTotal() {
    if (_selectedProduct != null && _quantityController.text.isNotEmpty) {
      final quantity = int.tryParse(_quantityController.text) ?? 0;
      setState(() {
        _totalAmount = _selectedProduct!.price * quantity;
      });
    } else {
      setState(() {
        _totalAmount = 0;
      });
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedProduct == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a product'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final quantity = int.parse(_quantityController.text);

      // Check if sufficient stock
      if (quantity > _selectedProduct!.stock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient stock. Available: ${_selectedProduct!.stock}',
            ),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final transaction = TransactionModel(
        id: '',
        productId: _selectedProduct!.id,
        productName: _selectedProduct!.name,
        quantity: quantity,
        unitPrice: _selectedProduct!.price,
        totalAmount: _totalAmount,
        transactionDate: DateTime.now(),
        customerName: _customerNameController.text.trim().isNotEmpty
            ? _customerNameController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final transactionProvider = context.read<TransactionProvider>();
      final success = await transactionProvider.addTransaction(transaction);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaction recorded successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                transactionProvider.errorMessage ??
                    'Failed to record transaction',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final products = productProvider.products;

    return Scaffold(
      appBar: const CustomAppBar(title: 'New Sale'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product dropdown
              DropdownButtonFormField<ProductModel>(
                value: _selectedProduct,
                decoration: const InputDecoration(
                  labelText: 'Select Product',
                  prefixIcon: Icon(Icons.medication),
                ),
                items: products.map((product) {
                  return DropdownMenuItem(
                    value: product,
                    child: Text(
                      '${product.name} - ${DateFormatter.formatCurrency(product.price)} (Stock: ${product.stock})',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProduct = value;
                    _calculateTotal();
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a product' : null,
              ),
              const SizedBox(height: 16),

              // Selected product info
              if (_selectedProduct != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Product Details',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedProduct!.name,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Price: ${DateFormatter.formatCurrency(_selectedProduct!.price)}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedProduct!.stock < 10
                                  ? AppColors.error.withOpacity(0.1)
                                  : AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Stock: ${_selectedProduct!.stock}',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: _selectedProduct!.stock < 10
                                        ? AppColors.error
                                        : AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              if (_selectedProduct != null) const SizedBox(height: 16),

              // Quantity
              CustomTextField(
                label: 'Quantity',
                hint: 'Enter quantity',
                controller: _quantityController,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    Validators.validatePositiveNumber(value, 'Quantity'),
                prefixIcon: const Icon(Icons.shopping_cart),
                onChanged: (_) => _calculateTotal(),
              ),
              const SizedBox(height: 16),

              // Total amount display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      DateFormatter.formatCurrency(_totalAmount),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Optional fields
              Text(
                'Optional Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),

              // Customer name
              CustomTextField(
                label: 'Customer Name (Optional)',
                hint: 'Enter customer name',
                controller: _customerNameController,
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 16),

              // Notes
              CustomTextField(
                label: 'Notes (Optional)',
                hint: 'Enter any notes',
                controller: _notesController,
                maxLines: 3,
                prefixIcon: const Icon(Icons.note),
              ),
              const SizedBox(height: 32),

              // Save button
              CustomButton(
                text: 'Record Sale',
                onPressed: _handleSave,
                isLoading: transactionProvider.isLoading,
                icon: Icons.check,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
