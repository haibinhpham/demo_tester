import 'package:flutter/material.dart';
import '../../model/item.dart';

class ItemDetailScreen extends StatefulWidget {
  const ItemDetailScreen({super.key, required this.item});
  final Item item;

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  void initState() {
    super.initState();
    updateItem();
  }

  Future<String> updateItem() async {
    //get provider

    //get connection
    return 'Hallo';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
          'item name: ${widget.item.item_name}, quantity: ${widget.item.quantity}'),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
