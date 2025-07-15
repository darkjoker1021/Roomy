import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/shopping_controller.dart';

class ShoppingView extends GetView<ShoppingController> {
  const ShoppingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShoppingView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'ShoppingView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
