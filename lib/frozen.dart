import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(FrozonPage());
}

class FrozonPage extends StatelessWidget {
  const FrozonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Green Mart',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FrozenFoodPage(),
    );
  }
}

class FrozenFoodPage extends StatelessWidget {
  const FrozenFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        leading: const Icon(Icons.menu, color: Colors.white),
        title: const Text('Green Mart', style: TextStyle(color: Colors.white)),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Center(
              child: Text('RS.900.00', style: TextStyle(color: Colors.white)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search bar
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'What are you looking for',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),

            // Categories section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CategoryButton(text: 'All', selected: true),
                  CategoryButton(text: 'Desert'),
                  CategoryButton(text: 'Cheese'),
                  CategoryButton(text: 'Ice Cube'),
                ],
              ),
            ),

            // Products list
            Expanded(
              child: ListView(
                children: [
                  ProductItem(
                    imageUrl: 'assets/wonder_vanilla_shock-rote.png',
                    name: 'Sample Product 1',
                    price: 'Rs 50.00/item',
                  ),
                  ProductItem(
                    imageUrl: 'assets/KEELLS-KREST-CHUNKY-CHICKEN-SAUSAGES.jpg',
                    name: 'Krest Sausages Nai Miris 200g',
                    price: 'Rs 535.00 / Unit',
                  ),
                  
                  ProductItem(
                    imageUrl: 'assets/Elephant House Vanilla Ice Cream.jpg',
                    name: 'Elephant House Ice Cream Vanilla 2L',
                    price: 'Rs 1,030.00',
                  ),
                ],
              ),
            ),
            Container(
                    color: Colors.yellow,
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    child: const Text(
                      '15% Deals\nNow Rs 495.00, was Rs.535.00',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String text;
  final bool selected;

  const CategoryButton({super.key, required this.text, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: selected ? Colors.white : Colors.black,
        backgroundColor: selected ? Colors.green : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: Colors.green),
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

  const ProductItem({super.key, 
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
          const SizedBox(width: 16),
          Expanded(
            child: Text(name),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(price, style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.minusCircle, color: Colors.green),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.plusCircle, color: Colors.green),
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
