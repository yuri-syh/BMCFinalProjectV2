import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import 'address_form_screen.dart';
import '../models/address.dart';

class MyAddressesScreen extends StatelessWidget {
  final bool isSelectionMode;
  const MyAddressesScreen({super.key, this.isSelectionMode = false});

  static const Color _appBarColor = Color(0xFF75a2b9);

  void _navigateToAddEditScreen(BuildContext context, {Address? address}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(existingAddress: address),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AddressProvider>(
      builder: (context, addressProvider, child) {
        final addresses = addressProvider.addresses;

        return Scaffold(
          appBar: AppBar(
            title: Text(isSelectionMode ? "Select Address" : "My Addresses"),
          ),
          body: Column(
            children: [
              // Add New Address
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _navigateToAddEditScreen(context);
                    },
                    style: OutlinedButton.styleFrom(
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),

              const Divider(),

              Expanded(
                child: addresses.isEmpty
                    ? const Center(child: Text('No saved addresses yet.'))
                    : ListView.builder(
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on, color: _appBarColor),
                      title: Text(address.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(address.details),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit Icon
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
                            onPressed: () => _navigateToAddEditScreen(context, address: address),
                          ),
                          // Delete Icon
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                            onPressed: () {
                              _showDeleteConfirmation(context, addressProvider, address);
                            },
                          ),
                        ],
                      ),

                      onTap: () {
                        if (isSelectionMode) {
                          Navigator.pop(context, address.fullAddress);
                        } else {
                          _navigateToAddEditScreen(context, address: address);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, AddressProvider provider, Address address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete the address"${address.label}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAddress(address.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Address successfully deleted.')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}