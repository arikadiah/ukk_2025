import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  _ProductScreenState createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Map<String, dynamic>> products = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProduct();
  }

  // Mengambil data produk dari Supabase
  Future<void> fetchProduct() async {
    try {
      final response = await Supabase.instance.client.from('produk').select();
      if (mounted) {
        setState(() {
          products = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: $e')),
        );
      }
    }
  }

  // Menambahkan produk baru
  Future<void> addProduct(String name, double price, int stock) async {
    if (name.isEmpty || price <= 0 || stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields must be filled and valid!')),
      );
      return;
    }
    if (price is! double || stock is! int) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Price must be a positive number and stock must be an integer')),
    );
    return;
  }

    try {
      final response = await Supabase.instance.client.from('produk').insert([
        {
          'nama_produk': name,
          'harga': price,
          'stok': stock,
        }
      ]);
      if (response.error == null) {
        fetchProduct();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
      } else {
        throw response.error!;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding product: $e')),
      );
    }
  }

  // Mengedit produk
  Future<void> editProduct(int produkId, String name, double price, int stock) async {
    try {
      final response = await Supabase.instance.client.from('produk').update({
        'nama_produk': name,
        'harga': price,
        'stok': stock,
      }).eq('produk_id', produkId);
      
      if (response.error == null) {
        fetchProduct();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
      } else {
        throw response.error!;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating product: $e')),
      );
    }
  }

  // Menghapus produk
  Future<void> deleteProduct(int produkId) async {
    try {
      final response = await Supabase.instance.client.from('produk').delete().eq('produk_id', produkId);
      
      if (response.error == null) {
        fetchProduct();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted successfully!')),
        );
      } else {
        throw response.error!;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting product: $e')),
      );
    }
  }

  // Menampilkan dialog untuk menambahkan produk baru
  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: stockController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Stock'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text;
                final price = double.tryParse(priceController.text);
                final stock = int.tryParse(stockController.text);

                if (name.isEmpty || price == null || price <= 0 || stock == null || stock <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in valid data!')),
                  );
                } else {
                  addProduct(name, price, stock);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add Product'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Products List"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddProductDialog,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              onChanged: (query) {
                setState(() {
                  products = products.where((product) {
                    final name = product['nama_produk'].toString().toLowerCase();
                    return name.contains(query.toLowerCase());
                  }).toList();
                });
              },
              decoration: InputDecoration(
                hintText: "Search products...",
                filled: true,
                fillColor: Color(0xff4c67ee),
                prefixIcon: Icon(Icons.search, color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            SizedBox(height: 16),
            // Product List
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xffebe7e7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0x4d9e9e9e), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product['nama_produk'] ?? 'No Name',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Color(0xff3a57e8)),
                              onPressed: () {
                                // Handle edit product action
                                final nameController = TextEditingController(text: product['nama_produk']);
                                final priceController = TextEditingController(text: product['harga'].toString());
                                final stockController = TextEditingController(text: product['stok'].toString());

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Edit Product'),
                                      content: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            TextField(
                                              controller: nameController,
                                              decoration: InputDecoration(labelText: 'Product Name'),
                                            ),
                                            TextField(
                                              controller: priceController,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(labelText: 'Price'),
                                            ),
                                            TextField(
                                              controller: stockController,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(labelText: 'Stock'),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            final name = nameController.text;
                                            final price = double.tryParse(priceController.text);
                                            final stock = int.tryParse(stockController.text);

                                            if (name.isEmpty || price == null || price <= 0 || stock == null || stock <= 0) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(content: Text('Please fill in valid data!')),
                                              );
                                            } else {
                                              editProduct(product['produk_id'], name, price, stock);
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          child: Text('Update Product'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                // Handle delete product action
                                deleteProduct(product['produk_id']);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
