import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import 'package:flutter/foundation.dart';

/// Shop item model
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final ItemType type;
  final int price; // in coins
  final bool isPremiumOnly;
  final bool isOwned;
  final DateTime? purchasedAt;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.type,
    required this.price,
    this.isPremiumOnly = false,
    this.isOwned = false,
    this.purchasedAt,
  });

  factory ShopItem.fromFirestore(String id, Map<String, dynamic> data) {
    return ShopItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      iconPath: data['iconPath'] ?? 'assets/icons/item_default.png',
      type: ItemType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ItemType.other,
      ),
      price: data['price'] ?? 100,
      isPremiumOnly: data['isPremiumOnly'] ?? false,
      isOwned: data['isOwned'] ?? false,
      purchasedAt: data['purchasedAt'] != null
          ? (data['purchasedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'type': type.name,
      'price': price,
      'isPremiumOnly': isPremiumOnly,
      'isOwned': isOwned,
      'purchasedAt': purchasedAt != null ? Timestamp.fromDate(purchasedAt!) : null,
    };
  }
}

enum ItemType {
  avatar, // Avatar customizations
  theme, // App themes
  powerup, // Game power-ups
  boost, // XP/Coin boosters
  badge, // Decorative badges
  other,
}

/// Default shop items
final defaultShopItems = [
  // Avatars
  {
    'id': 'avatar_panda',
    'name': 'Panda Avatar',
    'description': 'Cute panda profile picture',
    'iconPath': 'assets/shop/avatar_panda.png',
    'type': 'avatar',
    'price': 200,
    'isPremiumOnly': false,
  },
  {
    'id': 'avatar_robot',
    'name': 'Robot Avatar',
    'description': 'Futuristic robot profile picture',
    'iconPath': 'assets/shop/avatar_robot.png',
    'type': 'avatar',
    'price': 250,
    'isPremiumOnly': false,
  },
  {
    'id': 'avatar_unicorn',
    'name': 'Unicorn Avatar',
    'description': 'Magical unicorn profile picture',
    'iconPath': 'assets/shop/avatar_unicorn.png',
    'type': 'avatar',
    'price': 300,
    'isPremiumOnly': true,
  },

  // Themes
  {
    'id': 'theme_dark',
    'name': 'Dark Mode',
    'description': 'Easy on the eyes dark theme',
    'iconPath': 'assets/shop/theme_dark.png',
    'type': 'theme',
    'price': 500,
    'isPremiumOnly': false,
  },
  {
    'id': 'theme_neon',
    'name': 'Neon Theme',
    'description': 'Vibrant neon colors',
    'iconPath': 'assets/shop/theme_neon.png',
    'type': 'theme',
    'price': 750,
    'isPremiumOnly': true,
  },

  // Power-ups
  {
    'id': 'powerup_xp_2x',
    'name': '2x XP Boost',
    'description': 'Double XP for 24 hours',
    'iconPath': 'assets/shop/powerup_xp.png',
    'type': 'boost',
    'price': 400,
    'isPremiumOnly': false,
  },
  {
    'id': 'powerup_coin_2x',
    'name': '2x Coin Boost',
    'description': 'Double coins for 24 hours',
    'iconPath': 'assets/shop/powerup_coin.png',
    'type': 'boost',
    'price': 350,
    'isPremiumOnly': false,
  },
  {
    'id': 'powerup_hint',
    'name': 'Game Hints (5x)',
    'description': 'Get hints in quiz games',
    'iconPath': 'assets/shop/powerup_hint.png',
    'type': 'powerup',
    'price': 150,
    'isPremiumOnly': false,
  },

  // Badges
  {
    'id': 'badge_vip',
    'name': 'VIP Badge',
    'description': 'Show off your VIP status',
    'iconPath': 'assets/shop/badge_vip.png',
    'type': 'badge',
    'price': 1000,
    'isPremiumOnly': true,
  },
  {
    'id': 'badge_supporter',
    'name': 'Supporter Badge',
    'description': 'Support badge for your profile',
    'iconPath': 'assets/shop/badge_supporter.png',
    'type': 'badge',
    'price': 600,
    'isPremiumOnly': false,
  },
];

/// Provider for all shop items
final shopItemsProvider = StreamProvider<List<ShopItem>>((ref) {
  // Global shop catalog stored at /store/items/{itemId}
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('store')
      .doc('items')
      .collection('items')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => ShopItem.fromFirestore(doc.id, doc.data()))
        .toList()
      ..sort((a, b) => a.price.compareTo(b.price)); // Sort by price
  });
});

/// Provider for user's owned items
final ownedItemsProvider = StreamProvider<List<ShopItem>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value([]);
  }

  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('users')
      .doc(userId)
      .collection('inventory')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => ShopItem.fromFirestore(doc.id, doc.data()))
        .toList()
      ..sort((a, b) => b.purchasedAt!.compareTo(a.purchasedAt!)); // Recent first
  });
});

/// Provider for purchasing items
final purchaseItemProvider = Provider((ref) {
  return (String itemId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('User not authenticated');

    final firestore = FirebaseFirestore.instance;
    final itemsRef = firestore.collection('store').doc('items').collection('items');

    // Get item details
    final itemDoc = await itemsRef.doc(itemId).get();
    if (!itemDoc.exists) {
      throw Exception('Item not found');
    }

    final item = ShopItem.fromFirestore(itemId, itemDoc.data()!);

    // Check if already owned
    final ownedItem = await firestore
        .collection('users')
        .doc(userId)
        .collection('inventory')
        .doc(itemId)
        .get();

    if (ownedItem.exists) {
      throw Exception('Item already owned');
    }

    // Check user's coins
    final userDoc = await firestore.collection('users').doc(userId).get();
    final userData = userDoc.data()!;
    final userCoins = userData['coins'] ?? 0;

    if (userCoins < item.price) {
      throw Exception('Not enough coins');
    }

    // Check premium requirement
    if (item.isPremiumOnly) {
      final isPremium = userData['isPremium'] ?? false;
      if (!isPremium) {
        throw Exception('Premium membership required');
      }
    }

    // Execute purchase
    final batch = firestore.batch();

    // Deduct coins
    final userRef = firestore.collection('users').doc(userId);
    batch.update(userRef, {
      'coins': FieldValue.increment(-item.price),
    });

    // Add to inventory
    final inventoryRef = firestore
        .collection('users')
        .doc(userId)
        .collection('inventory')
        .doc(itemId);

    batch.set(inventoryRef, {
      ...item.toFirestore(),
      'isOwned': true,
      'purchasedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    debugPrint('Item purchased: $itemId for ${item.price} coins');
  };
});

/// Initialize shop items in Firestore (run once)
Future<void> initializeShopItems() async {
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();
  final itemsRef = firestore.collection('store').doc('items').collection('items');

  for (var itemData in defaultShopItems) {
    final docRef = itemsRef.doc(itemData['id'] as String);

    batch.set(docRef, {
      'name': itemData['name'],
      'description': itemData['description'],
      'iconPath': itemData['iconPath'],
      'type': itemData['type'],
      'price': itemData['price'],
      'isPremiumOnly': itemData['isPremiumOnly'],
    });
  }

  await batch.commit();
  debugPrint('Initialized ${defaultShopItems.length} shop items');
}

/// Provider for checking if item is owned
final isItemOwnedProvider = Provider.family<bool, String>((ref, itemId) {
  final ownedItems = ref.watch(ownedItemsProvider);

  return ownedItems.when(
    data: (items) => items.any((item) => item.id == itemId),
    loading: () => false,
    error: (error, stack) => false,
  );
});