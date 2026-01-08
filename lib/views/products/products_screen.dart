import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';

/// Products list screen with search and filter
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteProduct(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final productProvider = context.read<ProductProvider>();
      final success = await productProvider.deleteProduct(id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Product deleted successfully' : 'Failed to delete product'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final products = productProvider.products;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Products'),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.white,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              productProvider.searchProducts('');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => productProvider.searchProducts(value),
                ),
                const SizedBox(height: 12),
                
                // Category filter chips
                if (categoryProvider.categories.isNotEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: const Text('All'),
                          selected: productProvider.selectedCategoryId == null,
                          onSelected: (_) => productProvider.filterByCategory(null),
                        ),
                        const SizedBox(width: 8),
                        ...categoryProvider.categories.map((category) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category.name),
                              selected: productProvider.selectedCategoryId == category.id,
                              onSelected: (_) => productProvider.filterByCategory(category.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Products list
          Expanded(
            child: products.isEmpty
                ? EmptyState(
                    icon: Icons.inventory_2,
                    title: 'No Products',
                    message: productProvider.searchQuery.isNotEmpty || productProvider.selectedCategoryId != null
                        ? 'No products match your filters'
                        : 'Add your first product to get started',
                  )
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProductScreen(product: product),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProductScreen(product: product),
                            ),
                          );
                        },
                        onDelete: () => _deleteProduct(product.id, product.name),
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
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }
}
