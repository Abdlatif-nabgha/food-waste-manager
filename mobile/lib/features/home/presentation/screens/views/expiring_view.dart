import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../products/presentation/providers/product_provider.dart';
import '../../../../products/presentation/widgets/product_card.dart';

class ExpiringView extends StatelessWidget {
  const ExpiringView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Expiring Soon'),
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
          ),
          body: provider.isLoading && provider.expiringProducts.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchAllData(),
                  child: provider.expiringProducts.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                            const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                                  SizedBox(height: 16),
                                  Text(
                                    'Great job!\nYou have no products expiring soon.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppColors.textLight, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16).copyWith(bottom: 80),
                          itemCount: provider.expiringProducts.length,
                          itemBuilder: (context, index) {
                            final product = provider.expiringProducts[index];
                            return ProductCard(
                              product: product,
                              onConsume: () => provider.consumeProduct(product.id),
                              onDelete: () => provider.deleteProduct(product.id),
                              onEdit: () {},
                            );
                          },
                        ),
                ),
        );
      },
    );
  }
}
