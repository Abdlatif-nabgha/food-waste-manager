import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../products/presentation/providers/product_provider.dart';
import '../../../../products/presentation/widgets/product_card.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchAllData(),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text('Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryLight, AppColors.primary],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Grid
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.5,
                        children: [
                          _SummaryCard(
                            title: 'Total',
                            count: provider.totalProducts,
                            icon: Icons.inventory_2_rounded,
                            color: AppColors.primary,
                          ),
                          _SummaryCard(
                            title: 'Expiring',
                            count: provider.expiringSoonCount,
                            icon: Icons.warning_amber_rounded,
                            color: AppColors.warning,
                          ),
                          _SummaryCard(
                            title: 'Expired',
                            count: provider.expiredCount,
                            icon: Icons.error_outline_rounded,
                            color: AppColors.error,
                          ),
                          _SummaryCard(
                            title: 'Consumed',
                            count: provider.consumedCount,
                            icon: Icons.restaurant_rounded,
                            color: AppColors.consumed,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      const Text(
                        'Recent Products',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: provider.products.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: const [
                                Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.textLighter),
                                SizedBox(height: 16),
                                Text(
                                  'No products found.\nAdd some items to get started!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textLight),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = provider.products[index];
                            return ProductCard(
                              product: product,
                              onConsume: () => provider.consumeProduct(product.id),
                              onDelete: () => provider.deleteProduct(product.id),
                              onEdit: () {
                                // TODO: Navigate to Edit
                              },
                            );
                          },
                          childCount: provider.products.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)), // Bottom padding
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
