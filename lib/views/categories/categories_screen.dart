import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/empty_state.dart';

/// Categories screen with add/edit functionality
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  Future<void> _showCategoryDialog({CategoryModel? category}) async {
    final isEdit = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(text: category?.description ?? '');
    final formKey = GlobalKey<FormState>();
    
    // Default color options
    final colorOptions = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.success,
      AppColors.warning,
      AppColors.info,
      AppColors.error,
    ];
    
    int selectedColor = category?.colorValue ?? AppColors.primary.value;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit Category' : 'Add Category'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    label: 'Category Name',
                    hint: 'Enter category name',
                    controller: nameController,
                    validator: (value) => Validators.validateRequired(value, 'Category name'),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Description',
                    hint: 'Enter description',
                    controller: descController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  const Text('Select Color:'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: colorOptions.map((color) {
                      final isSelected = selectedColor == color.value;
                      return GestureDetector(
                        onTap: () => setState(() => selectedColor = color.value),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.black : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: AppColors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final categoryProvider = context.read<CategoryProvider>();
                  final categoryModel = CategoryModel(
                    id: category?.id ?? '',
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    colorValue: selectedColor,
                    createdAt: category?.createdAt ?? DateTime.now(),
                  );

                  bool success;
                  if (isEdit) {
                    success = await categoryProvider.updateCategory(category!.id, categoryModel);
                  } else {
                    success = await categoryProvider.addCategory(categoryModel);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? '${isEdit ? 'Updated' : 'Added'} category successfully'
                              : 'Failed to ${isEdit ? 'update' : 'add'} category',
                        ),
                        backgroundColor: success ? AppColors.success : AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteCategory(String id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
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
      final categoryProvider = context.read<CategoryProvider>();
      final success = await categoryProvider.deleteCategory(id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Category deleted successfully' : 'Failed to delete category'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categories;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Categories'),
      body: categories.isEmpty
          ? const EmptyState(
              icon: Icons.category,
              title: 'No Categories',
              message: 'Add your first category to organize products',
            )
          : ListView.builder(
              itemCount: categories.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final color = Color(category.colorValue);
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.category, color: color),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: category.description.isNotEmpty
                        ? Text(category.description)
                        : null,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showCategoryDialog(category: category);
                        } else if (value == 'delete') {
                          _deleteCategory(category.id, category.name);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }
}
