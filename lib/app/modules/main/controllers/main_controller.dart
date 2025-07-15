import 'package:get/get.dart';

class MainController extends GetxController {
  var selectedIndex = 0.obs;

  void setIndex(int i) => selectedIndex.value = i;
}