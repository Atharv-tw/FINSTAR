import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_tokens.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';

/// Shop Screen - Purchase avatars, themes, power-ups, and badges with coins
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  ItemType? _selectedFilter;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.vibrantBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildFilterChips(),
              const SizedBox(height: 16),
              Expanded(child: _buildShopGrid()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final userAsync = ref.watch(userProfileProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: DesignTokens.textDarkPrimary,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Shop',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: DesignTokens.textDarkPrimary,
              ),
            ),
          ),
          // Coin balance
          userAsync.when(
            data: (user) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: DesignTokens.accentGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: DesignTokens.accentGlow(0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${user?.coins ?? 0}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: DesignTokens.accentGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      (null, 'All', Icons.apps),
      (ItemType.avatar, 'Avatars', Icons.face),
      (ItemType.theme, 'Themes', Icons.palette),
      (ItemType.boost, 'Boosts', Icons.bolt),
      (ItemType.powerup, 'Power-ups', Icons.flash_on),
      (ItemType.badge, 'Badges', Icons.military_tech),
    ];

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final (type, label, icon) = filters[index];
          final isSelected = _selectedFilter == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? DesignTokens.primaryGradient : null,
                  color: isSelected ? null : Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : DesignTokens.primarySolid.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : DesignTokens.textDarkSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : DesignTokens.textDarkPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopGrid() {
    final shopItemsAsync = ref.watch(shopItemsProvider);
    final ownedItemsAsync = ref.watch(ownedItemsProvider);

    return shopItemsAsync.when(
      data: (items) {
        // Filter items based on selected filter
        final filteredItems = _selectedFilter == null
            ? items
            : items.where((item) => item.type == _selectedFilter).toList();

        if (filteredItems.isEmpty) {
          return _buildEmptyState();
        }

        // Get owned item IDs
        final ownedIds = ownedItemsAsync.when(
          data: (owned) => owned.map((e) => e.id).toSet(),
          loading: () => <String>{},
          error: (_, __) => <String>{},
        );

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final isOwned = ownedIds.contains(item.id);
            final delay = index * 0.05;

            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final staggerValue =
                    (_animationController.value - delay).clamp(0.0, 1.0);
                return Transform.scale(
                  scale: staggerValue,
                  child: Opacity(
                    opacity: staggerValue,
                    child: child,
                  ),
                );
              },
              child: _buildShopItem(item, isOwned),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: DesignTokens.primarySolid,
        ),
      ),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: DesignTokens.textDarkTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No items available',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DesignTokens.textDarkSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new items!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: DesignTokens.textDarkTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: DesignTokens.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load shop',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DesignTokens.textDarkPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: DesignTokens.textDarkTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopItem(ShopItem item, bool isOwned) {
    final typeColors = {
      ItemType.avatar: DesignTokens.primarySolid,
      ItemType.theme: DesignTokens.secondaryEnd,
      ItemType.boost: DesignTokens.accentEnd,
      ItemType.powerup: DesignTokens.info,
      ItemType.badge: const Color(0xFFFFD700),
      ItemType.other: DesignTokens.textDarkTertiary,
    };
    final color = typeColors[item.type] ?? DesignTokens.primarySolid;

    final typeIcons = {
      ItemType.avatar: Icons.face,
      ItemType.theme: Icons.palette,
      ItemType.boost: Icons.bolt,
      ItemType.powerup: Icons.flash_on,
      ItemType.badge: Icons.military_tech,
      ItemType.other: Icons.shopping_bag,
    };
    final icon = typeIcons[item.type] ?? Icons.shopping_bag;

    return GestureDetector(
      onTap: isOwned ? null : () => _showPurchaseDialog(item),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isOwned
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isOwned
                    ? DesignTokens.success.withValues(alpha: 0.5)
                    : color.withValues(alpha: 0.3),
                width: isOwned ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Item icon
                      Expanded(
                        child: Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  color.withValues(alpha: 0.2),
                                  color.withValues(alpha: 0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              size: 36,
                              color: color,
                            ),
                          ),
                        ),
                      ),

                      // Item name
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.textDarkPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Description
                      Text(
                        item.description,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: DesignTokens.textDarkTertiary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Price or Owned badge
                      if (isOwned)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: DesignTokens.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: DesignTokens.success.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle,
                                  color: DesignTokens.success, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Owned',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: DesignTokens.success,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: DesignTokens.accentGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.monetization_on,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${item.price}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Premium badge
                if (item.isPremiumOnly)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text(
                            'VIP',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPurchaseDialog(ShopItem item) {
    final userAsync = ref.read(userProfileProvider);
    final userCoins = userAsync.when(
      data: (user) => user?.coins ?? 0,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final canAfford = userCoins >= item.price;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Item preview
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: DesignTokens.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getItemIcon(item.type),
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            // Item name
            Text(
              item.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: DesignTokens.textDarkPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              item.description,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: DesignTokens.textDarkSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Price info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Price',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: DesignTokens.textDarkSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: DesignTokens.accentEnd, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${item.price}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: DesignTokens.textDarkPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Balance info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: canAfford
                    ? DesignTokens.success.withValues(alpha: 0.1)
                    : DesignTokens.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your Balance',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: DesignTokens.textDarkSecondary,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: canAfford
                            ? DesignTokens.success
                            : DesignTokens.error,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$userCoins',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: canAfford
                              ? DesignTokens.success
                              : DesignTokens.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (!canAfford) ...[
              const SizedBox(height: 12),
              Text(
                'You need ${item.price - userCoins} more coins',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: DesignTokens.error,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: DesignTokens.textDarkTertiary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textDarkSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: canAfford && !_isPurchasing
                        ? () => _purchaseItem(item)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: DesignTokens.primarySolid,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isPurchasing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Purchase',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  IconData _getItemIcon(ItemType type) {
    switch (type) {
      case ItemType.avatar:
        return Icons.face;
      case ItemType.theme:
        return Icons.palette;
      case ItemType.boost:
        return Icons.bolt;
      case ItemType.powerup:
        return Icons.flash_on;
      case ItemType.badge:
        return Icons.military_tech;
      case ItemType.other:
        return Icons.shopping_bag;
    }
  }

  Future<void> _purchaseItem(ShopItem item) async {
    setState(() => _isPurchasing = true);

    try {
      final purchase = ref.read(purchaseItemProvider);
      await purchase(item.id);

      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        _showSuccessDialog(item);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: DesignTokens.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPurchasing = false);
      }
    }
  }

  void _showSuccessDialog(ShopItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: DesignTokens.secondaryGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Purchase Successful!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: DesignTokens.textDarkPrimary,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'You now own ${item.name}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: DesignTokens.textDarkSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: DesignTokens.primarySolid,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
