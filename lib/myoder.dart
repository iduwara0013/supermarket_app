import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Green Market'),
        backgroundColor: Color(0xFF0CE319),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Color(0xFF0CE319),
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.add, color: Colors.black),
                ),
                SizedBox(width: 10),
                Text(
                  'lavdew@gmail.com',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            child: Row(
              children: [
                Expanded(
                  child: Image.network(
                    'https://via.placeholder.com/150', // Placeholder image URL
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MARKET PROMOTION',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '30% DISCOUNT',
                          style: TextStyle(
                            fontSize: 24,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'My orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OrderStatusWidget(
                  icon: Icons.payment,
                  label: 'To pay',
                ),
                OrderStatusWidget(
                  icon: Icons.delivery_dining,
                  label: 'To Recieve',
                ),
                OrderStatusWidget(
                  icon: Icons.rate_review,
                  label: 'To Review',
                ),
                OrderStatusWidget(
                  icon: Icons.cancel,
                  label: 'To Cancel',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderStatusWidget extends StatelessWidget {
  final IconData icon;
  final String label;

  OrderStatusWidget({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 40),
        SizedBox(height: 8),
        Text(label),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomeScreen(),
  ));
}
