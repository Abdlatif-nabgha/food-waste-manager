import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/product_provider.dart';
import 'package:intl/intl.dart';

import '../../utils/category_icon_helper.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  
  DateTime? _selectedDate;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<ProductProvider>().categories.isEmpty) {
        context.read<ProductProvider>().fetchAllData();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _showAddCategoryDialog(BuildContext context, ProductProvider provider) async {
    final TextEditingController categoryController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('New Category'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: categoryController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'e.g., Snacks, Fruits',
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context); // Close dialog early
                  try {
                    await provider.addCategory(categoryController.text.trim());
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Category added!'), backgroundColor: AppColors.success),
                    );
                    // Automatically select the newly created category by picking the last one
                    if (provider.categories.isNotEmpty) {
                      setState(() {
                        _selectedCategoryId = provider.categories.last.id;
                      });
                    }
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an expiry date')),
        );
        return;
      }
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      final provider = context.read<ProductProvider>();
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);

      try {
        await provider.addProduct(
          name: _nameController.text.trim(),
          quantity: int.parse(_quantityController.text.trim()),
          expiryDate: formattedDate,
          categoryId: _selectedCategoryId!,
        );

        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!', style: TextStyle(color: Colors.white)), backgroundColor: AppColors.success),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e', style: const TextStyle(color: Colors.white)), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Product', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: provider.isLoading && provider.categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        hintText: 'e.g., Milk, Apples, Bread',
                        prefixIcon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 20),

                    // Category Dropdown
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                            ),
                            value: _selectedCategoryId,
                            items: provider.categories.map((cat) {
                              return DropdownMenuItem<int>(
                                value: cat.id,
                                child: Text(CategoryIconHelper.formatNameWithIcon(cat.name)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value;
                              });
                            },
                            validator: (value) => value == null ? 'Please select a category' : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _showAddCategoryDialog(context, provider),
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 32),
                          tooltip: 'Add new category',
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quantity and Expiry Date Row
                    Row(
                      children: [
                        // Quantity
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Quantity',
                              prefixIcon: const Icon(Icons.numbers_rounded, color: AppColors.primary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Expiry Date
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Expiry Date',
                                prefixIcon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                errorText: _selectedDate == null ? '' : null,
                                errorStyle: const TextStyle(height: 0),
                              ),
                              child: Text(
                                _selectedDate == null ? 'Select Date' : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                                style: TextStyle(
                                  color: _selectedDate == null ? AppColors.textLight : AppColors.textDark,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Submit Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Save Product',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
