import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import '../utils/color_utils.dart';

// ignore: camel_case_types
class Manage_Account extends StatefulWidget {
  const Manage_Account({Key? key}) : super(key: key);

  @override
  State<Manage_Account> createState() => _Manage_AccountState();
}

// ignore: camel_case_types
class _Manage_AccountState extends State<Manage_Account> {
  late Stream<QuerySnapshot<Map<String, dynamic>>> _accountsStream;
  final TextEditingController _searchController = TextEditingController();
  bool _isAdminFilter = false;

  @override
  void initState() {
    super.initState();
    _accountsStream =
        FirebaseFirestore.instance.collection('users').snapshots();
  }

  Future<void> _showAccountOptionsDialog(
      String accountId, bool isAdmin, String? imageUrl) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Account Options'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (!isAdmin)
                  ElevatedButton(
                    onPressed: () {
                      // Assign admin privileges to the account
                      _assignAdminPrivileges(accountId);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Assign as Admin'),
                  ),
                ElevatedButton(
                  onPressed: () {
// Delete the account
                    _deleteAccount(accountId, imageUrl);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete Account'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _assignAdminPrivileges(String accountId) async {
    // Update the account document in Firestore to set isAdmin as true
    await FirebaseFirestore.instance
        .collection('users')
        .doc(accountId)
        .update({'isAdmin': true});
  }

  Future<void> _deleteAccount(String accountId, String? imageUrl) async {
    // Delete the account document from Firestore

    await FirebaseFirestore.instance
        .collection('users')
        .doc(accountId)
        .delete();

    // Delete the user from Firebase Authentication
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
    }

    // Delete the profile picture from Firebase Storage
    if (imageUrl != null) {
      final storageRef =
          firebase_storage.FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 3,
        title: const Text(
          "Manage Accounts",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              hexStringtoColor("535353"),
              hexStringtoColor("373737"),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: ('Search by name...'),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white70,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Show Admins Only',
                  style: TextStyle(color: Color(0xFF9B9B9B)),
                ),
                Checkbox(
                  value: _isAdminFilter,
                  onChanged: (value) {
                    setState(() {
                      _isAdminFilter = value ?? false;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _accountsStream,
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final accounts = snapshot.data!.docs;

                  List<DocumentSnapshot<Map<String, dynamic>>>
                      filteredAccounts = accounts;

                  if (_searchController.text.isNotEmpty) {
                    filteredAccounts = accounts.where((account) {
                      final username = account['username'] as String?;
                      return username
                              ?.toLowerCase()
                              .contains(_searchController.text.toLowerCase()) ??
                          false;
                    }).toList();
                  }

                  if (_isAdminFilter) {
                    filteredAccounts = filteredAccounts.where((account) {
                      final isAdmin = account['isAdmin'] as bool? ?? false;
                      return isAdmin;
                    }).toList();
                  }

                  return ListView.builder(
                    itemCount: filteredAccounts.length,
                    itemBuilder: (BuildContext context, int index) {
                      final account = filteredAccounts[index].data();
                      final accountId = filteredAccounts[index].id;
                      final imageUrl = account!['imageUrl'] as String?;
                      final email = account['email'] as String?;
                      final username = account['username'] as String?;
                      final isAdmin = account['isAdmin'] as bool? ?? false;

                      return Card(
                        child: ListTile(
                          onTap: () {
                            _showAccountOptionsDialog(
                                accountId, isAdmin, imageUrl);
                          },
                          leading: imageUrl != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(imageUrl),
                                )
                              : const SizedBox(),
                          title: Text(username ?? ''),
                          subtitle: Text(email ?? ''),
                          trailing: isAdmin ? const Text('Admin') : null,
                        ),
                      );
                    },
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
