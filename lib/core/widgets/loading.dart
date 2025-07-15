import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Lottie.asset("assets/gifs/loading.json")));
  }
}