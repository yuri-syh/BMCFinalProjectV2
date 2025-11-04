import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/address_provider.dart';
import 'package:stationery_store/admin/admin_add_product_screen.dart';
import 'screens/login_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/products_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const StationeryApp());
}

class StationeryApp extends StatelessWidget {
  const StationeryApp({super.key});

  Future<Widget> _getRoleBasedScreen(User user) async {
    if (user.uid.isEmpty) {
      return const WelcomeScreen();
    }
      return const ProductsScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: MaterialApp(
        title: 'Office Stationery Store',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasData) {
              final user = snapshot.data!;
              return FutureBuilder<Widget>(
                future: _getRoleBasedScreen(user),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (roleSnapshot.hasError || !roleSnapshot.hasData) {
                    // Log error for debugging and fallback
                    print('Role fetch error: ${roleSnapshot.error}');
                    return const ProductsScreen();
                  }
                  return roleSnapshot.data!;
                },
              );
            }
            return const WelcomeScreen();
          },
        ),
      ),
    );
  }
}
