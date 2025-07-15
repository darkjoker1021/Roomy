import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset("assets/gifs/loading.gif", width: 150, height: 150)));
  }
}