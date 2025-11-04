import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'account_details_screen.dart';
import 'my_addresses_screen.dart';
import 'favorites_screen.dart';
import 'package:stationery_store/admin/admin_add_product_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  static const Color _appBarColor = Color(0xFF75a2b9);
  static const Color _darkColor = Color(0xFF464c56);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  late Future<String> _userRoleFuture;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _userRoleFuture = _fetchUserRole();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  Future<String> _fetchUserRole() async {
    if (_currentUser == null) return 'guest';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      return doc.data()?['role'] ?? 'user';
    } catch (e) {
      print("Error fetching user role: $e");
      return 'user';
    }
  }

  void _navigateToAdminPanel() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminAddProductScreen()),
    );
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Office Stationery'),
        backgroundColor: ProductsScreen._appBarColor,
        actions: [
          FutureBuilder<String>(
            future: _userRoleFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data != 'admin') {

                return Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    final itemCount = cart.totalItemCount;

                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0, top: 2.0),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: IconButton(
                              icon: const Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 30,
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                              },
                            ),
                          ),
                        ),

                        if (itemCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                itemCount > 99 ? '99+' : itemCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: ProductsScreen._appBarColor,
              ),
              // User Account Icon
              currentAccountPicture: const Padding(
                padding: EdgeInsets.only(bottom: 5.0), // Konting baba
                child: Icon(Icons.account_circle, size: 65, color: Colors.white),
              ),
              // Email
              accountName: const Text(
                'Aisle Kazuichi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                _currentUser?.email ?? 'Guest User',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 15,
                ),
              ),
            ),

            Expanded(
              child: FutureBuilder<String>(
                future: _userRoleFuture,
                builder: (context, snapshot) {
                  final isAdmin = snapshot.hasData && snapshot.data == 'admin';

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Account Details
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Account Details'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountDetailsScreen()));
                        },
                      ),

                      // Favorites
                      if (!isAdmin)
                        ListTile(
                          leading: const Icon(Icons.favorite),
                          title: const Text('Favorites'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesScreen()));
                          },
                        ),

                      // My Addresses
                      if (!isAdmin)
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: const Text('My Addresses'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MyAddressesScreen()));
                          },
                        ),

                      // Admin Panel
                      if (isAdmin)
                        ListTile(
                          leading: const Icon(Icons.admin_panel_settings, color: ProductsScreen._appBarColor),
                          title: const Text('Admin Panel'),
                          onTap: _navigateToAdminPanel,
                        ),
                    ],
                  );
                },
              ),
            ),

            const Divider(), // Horizontal line
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      body: FutureBuilder<String>(
        future: _userRoleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final isAdmin = snapshot.hasData && snapshot.data == 'admin';

          if (isAdmin) {
            // Admin Home Screen
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_person, size: 80, color: ProductsScreen._appBarColor),
                    SizedBox(height: 20),
                    Text(
                      "Welcome, Admin!",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: ProductsScreen._darkColor),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "You are successfully logged in.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          // User Home Screen
          return Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                        : null,
                  ),
                ),
              ),

              // Product
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text("No products available."));
                    }

                    final allProducts = snapshot.data!.docs
                        .map((doc) => Product.fromFirestore(doc))
                        .toList();

                    final filteredProducts = allProducts.where((product) {
                      return product.name.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (_searchQuery.length >= 3 && filteredProducts.isEmpty) {
                      return const Center(
                        child: Text(
                          "No products found matching your search.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    final displayProducts = _searchQuery.length < 3 ? allProducts : filteredProducts;

                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 310,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: displayProducts.length,
                      itemBuilder: (context, i) => ProductCard(product: displayProducts[i]),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}