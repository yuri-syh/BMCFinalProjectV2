import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/address_provider.dart';
import '../models/address.dart';

class AddressFormScreen extends StatefulWidget {
  final Address? existingAddress;
  const AddressFormScreen({super.key, this.existingAddress});

  static const Color _appBarColor = Color(0xFF75a2b9);

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _label = '';
  String _details = '';

  @override
  void initState() {
    super.initState();
    if (widget.existingAddress != null) {
      _label = widget.existingAddress!.label;
      _details = widget.existingAddress!.details;
    }
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final addressProvider = Provider.of<AddressProvider>(context, listen: false);

    addressProvider.saveAddress(
      label: _label,
      details: _details,
      existingAddress: widget.existingAddress,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingAddress == null
              ? 'New address saved successfully!'
              : 'Address updated successfully!',
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingAddress == null ? "Add New Address" : "Edit Address"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AddressFormScreen._appBarColor, Color(0xFF464c56)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // Save button
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Label (Home, Office, etc.)
              TextFormField(
                initialValue: _label,
                decoration: InputDecoration(
                  labelText: 'Address Label (e.g., Home, Office)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a label.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _label = value!;
                },
              ),
              const SizedBox(height: 20),

              // Details
              TextFormField(
                initialValue: _details,
                decoration: InputDecoration(
                  labelText: 'Full Address Details',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the full address details.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _details = value!;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}