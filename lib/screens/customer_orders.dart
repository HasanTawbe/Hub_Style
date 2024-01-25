import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/color_utils.dart';

class CustomerOrders extends StatefulWidget {
  const CustomerOrders({Key? key}) : super(key: key);

  @override
  State<CustomerOrders> createState() => _CustomerOrdersState();
}

class _CustomerOrdersState extends State<CustomerOrders> {
  List<Map<String, dynamic>> orders = [];
  String filterStatus = '';

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('orders').get();
    orders = querySnapshot.docs.map((doc) => doc.data()).toList();
    setState(() {});
  }

  void filterOrders(String status) {
    setState(() {
      filterStatus = status;
    });
  }

  void updateOrderStatus(int index) {
    setState(() {
      orders[index]['status'] = 'Delivered';
    });
  }

  List<Map<String, dynamic>> getFilteredOrders() {
    if (filterStatus.isEmpty) {
      return orders;
    } else {
      return orders.where((order) {
        final status = order['status'] as String? ?? '';
        return status.toLowerCase() == filterStatus.toLowerCase() ||
            filterStatus.toLowerCase() == 'on progress' && status.isEmpty;
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Customers Orders",
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => filterOrders('On Progress'),
                  child: const Text('On Progress'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => filterOrders('Delivered'),
                  child: const Text('Delivered'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: getFilteredOrders().length,
                itemBuilder: (context, index) {
                  final order = getFilteredOrders()[index];
                  final address = order['Address'] as String?;
                  final phoneNumber = order['PhoneNumber'] as String?;
                  final username = order['Username'] as String?;
                  final date = order['date'] as Timestamp?;
                  final items = order['items'] as List<dynamic>? ?? [];
                  final total = order['total'] as double?;
                  final status = order['status'] as String? ?? 'On Progress';

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Username: $username'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address: $address'),
                          Text('Phone Number: $phoneNumber'),
                          Text('Date: ${date?.toDate().toString()}'),
                          Text('Total: ${total.toString()}'),
                          const SizedBox(height: 8),
                          const Text('Items:'),
                          for (var item in items)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: ${item['name']}'),
                                Text('Quantity: ${item['quantity']}'),
                                Text('Size: ${item['size']}'),
                                const SizedBox(height: 8),
                              ],
                            ),
                          const SizedBox(height: 8),
                          Text('Status: $status'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {},
                      ),
                      onTap: () {
                        if (status == 'On Progress') {
                          updateOrderStatus(index);
                        }
                      },
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
