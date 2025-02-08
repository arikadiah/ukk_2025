import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'product.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> users = [];
   final List<Widget> _pages = [
    ProductScreen(),
   ];

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  // Mengambil data user dari Supabase
  Future<void> fetchUser() async {
    try {
      final response = await Supabase.instance.client.from('user').select();
      if (mounted) {
        setState(() {
          users = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load users: $e')),
        );
      }
    }
  }

  // Menambahkan user baru
  Future<void> addUser(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username & password cannot be empty')),
      );
      return;
    }

    try {
      await Supabase.instance.client.from('user').insert({
        'username': username,
        'password': password,
      });
      fetchUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User added successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding user: $e')),
      );
    }
  }

  // Menghapus user
  Future<void> deleteUser(int id) async {
    try {
      await Supabase.instance.client.from('user').delete().eq('id', id);
      fetchUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  // Menampilkan dialog untuk menambahkan atau mengedit user
  void _showUserDialog({Map<String, dynamic>? user}) {
    final TextEditingController usernameController = TextEditingController(
      text: user?['username'] ?? '',
    );
    final TextEditingController passwordController = TextEditingController(
      text: user?['password'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user == null ? "Add User" : "Edit User"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (user == null) {
                addUser(usernameController.text, passwordController.text);
              } else {
                editUser(user['id'], usernameController.text,
                    passwordController.text);
              }
              Navigator.pop(context);
            },
            child: Text(user == null ? "Add" : "Save"),
          ),
        ],
      ),
    );
  }

  // Mengedit user
  Future<void> editUser(int id, String username, String password) async {
    try {
      await Supabase.instance.client.from('user').update({
        'username': username,
        'password': password,
      }).eq('id', id);
      fetchUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user: $e')),
      );
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await Supabase.instance.client.auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe2e5e7),
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "KASIR",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            Text(
              "QU",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Color(0xfffba808),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
        backgroundColor: const Color(0xff3a57e8),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Product'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Customer'),
          BottomNavigationBarItem(
              icon: Icon(Icons.app_registration), label: 'Payment'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
        selectedItemColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "List User", // Menambahkan teks List User
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            users.isEmpty
                ? const Center(child: Text("No users available"))
                : Expanded(
                    child: ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            title: Text("ID: ${user['id']}"),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    "Username: ${user['username']}"), // Menambahkan tampilan password
                                Text(
                                    "Password: ${user['password']}"), // Menampilkan ID setelah password
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () {
                                    _showUserDialog(user: user);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () => deleteUser(user['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUserDialog,
        backgroundColor: const Color(0xff3a57e8),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
