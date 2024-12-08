import 'package:flutter/material.dart';

class ItemDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> itemDetails;

  const ItemDetailsWidget({Key? key, required this.itemDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final item = itemDetails['itemDetails'];
    final restaurant = itemDetails['restaurantDetails'];

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item['name'],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.teal
              ),
            ),
            SizedBox(height: 10),
            Text('Restaurant: ${restaurant['name']}'),
            Text('Address: ${restaurant['address']}'),
            SizedBox(height: 10),
            Text('Description: ${item['description']}'),
            SizedBox(height: 10),
            Text('Type: ${item['type']}'),
            Text('Discount: ${item['discount'] ?? 'No discount'}'),
            SizedBox(height: 10),
            Text('Prices:'),
            if (item['prices'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Small: ${item['prices']['Small'] ?? 'N/A'}'),
                  Text('Medium: ${item['prices']['Medium'] ?? 'N/A'}'),
                  Text('Large: ${item['prices']['Large'] ?? 'N/A'}'),
                ],
              )
          ],
        ),
      ),
    );
  }
}