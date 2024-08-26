import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: ShoppingCartPage(),
  ));
}

class ShoppingCartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Shopping Cart', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Information
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Magic Bubbles, Easy Wash Detergent Powder 2kg',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Rs 380.00',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Product Price, Quantity Buttons, and Remove Button
            Row(
              children: [
                Text(
                  'Rs 380.00',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  '1 Item',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Spacer(),
                IconButton(
                  icon: Icon(FontAwesomeIcons.plusCircle, color: Colors.green),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(FontAwesomeIcons.minusCircle, color: Colors.green),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {},
                ),
              ],
            ),
            Divider(thickness: 1, color: Colors.black),

            // Pricing Details
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sub Total(Rs)', style: TextStyle(fontSize: 16)),
                Text('Rs 380.00', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery Charge', style: TextStyle(fontSize: 16)),
                Text('0.00', style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Rs 380.00', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
