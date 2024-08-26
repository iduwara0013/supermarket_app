import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(BeveragePage());
}

class BeveragePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Green Mart',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          leading: Icon(Icons.menu, color: Colors.white),
          title: Text('Green Mart', style: TextStyle(color: Colors.white)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Text('Rs.900.00', style: TextStyle(color: Colors.white)),
              ),
            ),
            IconButton(
              icon: Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        body: BeverageScreen(),
      ),
    );
  }
}

class BeverageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'What are you looking for',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),

        // Categories
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryButton(text: 'All', selected: true),
              CategoryButton(text: 'Juice'),
              CategoryButton(text: 'Malt'),
              CategoryButton(text: 'Tea'),
            ],
          ),
        ),

        // Product List
        Expanded(
          child: ListView(
            children: [
              ProductItem(
                imageUrl: 'assets/EGB.jpg',
                name: 'Elephant House Carbonated Soft Drink Egb 1.5L',
                price: 'Rs 380.00',
              ),
              ProductItem(
                imageUrl: 'assets/nestermalt.jpg',
                name: 'Nestomalt Actigen Super Pack Pouch 400g',
                price: 'Rs 770.00',
              ),
              ProductItem(
                imageUrl: 'assets/nestermalt.jpg',
                name: 'Harischandra Coffee 100g',
                price: 'Rs 400.00',
              ),
            ],
          ),
        ),

        // Deals Banner
        Container(
          color: Colors.yellow,
          padding: EdgeInsets.all(16.0),
          width: double.infinity,
          child: Text(
            '15% Deals\nNow Rs 320.00, was Rs.400.00',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String text;
  final bool selected;

  CategoryButton({required this.text, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: selected ? Colors.white : Colors.black, backgroundColor: selected ? Colors.green : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Colors.green),
        ),
      ),
      onPressed: () {},
      child: Text(text),
    );
  }
}

class ProductItem extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String price;

  ProductItem({
    required this.imageUrl,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Image.asset(imageUrl, width: 100, height: 150), // Use Image.asset for local images
          SizedBox(width: 16),
          Expanded(
            child: Text(name),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(FontAwesomeIcons.minusCircle, color: Colors.green),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.plusCircle, color: Colors.green),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
