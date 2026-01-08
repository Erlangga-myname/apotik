import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/product_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// Add product screen
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedCategoryName;
  DateTime? _expiryDate;

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      if (_expiryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an expiry date'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final product = ProductModel(
        id: '',
        name: _nameController.text.trim(),
        categoryId: _selectedCategoryId!,
        categoryName: _selectedCategoryName!,
        stock: int.parse(_stockController.text),
        price: double.parse(_priceController.text),
        expiryDate: _expiryDate!,
        createdAt: DateTime.now(),
      );

      final productProvider = context.read<ProductProvider>();
      final success = await productProvider.addProduct(product);

      if (mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product added successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                productProvider.errorMessage ?? 'Failed to add product',
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
    final categoryProvider = context.watch<CategoryProvider>();
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Add Product'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product name
              CustomTextField(
                label: 'Product Name',
                hint: 'Enter product name',
                controller: _nameController,
                validator: (value) =>
                    Validators.validateRequired(value, 'Product name'),
                prefixIcon: const Icon(Icons.medication),
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<String>(
                // Defensive: only use value if it exists in current items
                value:
                    categoryProvider.categories.any(
                      (c) => c.id == _selectedCategoryId,
                    )
                    ? _selectedCategoryId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: categoryProvider.categories.map((category) {
                  return DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                    // Safe lookup with null handling
                    final category = categoryProvider.categories
                        .cast<dynamic>()
                        .firstWhere((c) => c.id == value, orElse: () => null);
                    _selectedCategoryName = category?.name;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16),

              // Stock
              CustomTextField(
                label: 'Stock Quantity',
                hint: 'Enter stock quantity',
                controller: _stockController,
                keyboardType: TextInputType.number,
                validator: Validators.validateStock,
                prefixIcon: const Icon(Icons.inventory_2),
              ),
              const SizedBox(height: 16),

              // Price
              CustomTextField(
                label: 'Price (Rp)',
                hint: 'Enter price',
                controller: _priceController,
                keyboardType: TextInputType.number,
                validator: Validators.validatePrice,
                prefixIcon: const Icon(Icons.attach_money),
              ),
              const SizedBox(height: 16),

              // Expiry date picker
              InkWell(
                onTap: _selectExpiryDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _expiryDate == null
                        ? 'Select expiry date'
                        : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                    style: TextStyle(
                      color: _expiryDate == null
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              CustomButton(
                text: 'Save Product',
                onPressed: _handleSave,
                isLoading: productProvider.isLoading,
                icon: Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
