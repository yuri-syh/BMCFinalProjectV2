import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});

  static const Color _appBarColor = Color(0xFF75a2b9);

  @override
  Widget build(BuildContext context) {
    final productsCollection = FirebaseFirestore.instance.collection('products');

    return Consumer<FavoritesProvider>(
      builder: (context, favorites, child) {
        final favoriteIds = favorites.favoriteProductIds;

        if (favoriteIds.isEmpty) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.favorite_border,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "You haven't added any favorites yet!",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: productsCollection.where(FieldPath.documentId, whereIn: favoriteIds.toList()).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(appBar: _buildAppBar(), body: const Center(child: CircularProgressIndicator()));
            }

            // Error Handling
            if (snapshot.hasError) {
              return Scaffold(
                  appBar: _buildAppBar(),
                  body: const Center(
                      child: Text(
                        'An error occurred while loading your favorites. Please try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      )
                  )
              );
            }

            final _favoriteProducts = snapshot.data!.docs
                .map((doc) => Product.fromFirestore(doc))
                .toList();

            if (_favoriteProducts.isEmpty) {
              return Scaffold(
                appBar: _buildAppBar(),
                body: const Center(
                  child: Text(
                      "Your favorites list is currently empty.",
                      style: TextStyle(fontSize: 16, color: Colors.grey)
                  ),
                ),
              );
            }


            return Scaffold(
              appBar: _buildAppBar(),
              body: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 310,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _favoriteProducts.length,
                itemBuilder: (context, i) => ProductCard(product: _favoriteProducts[i]),
              ),
            );
          },
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("My Favorites"),
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_appBarColor, Color(0xFF464c56)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}