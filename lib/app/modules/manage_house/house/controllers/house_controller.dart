import 'package:get/get.dart';
import 'package:roomy/app/routes/app_pages.dart';

class HouseController extends GetxController {
  var selectedOption = ''.obs;

  void selectJoinHouse() {
    selectedOption.value = 'join';
  }

  void selectCreateHouse() {
    selectedOption.value = 'create';
  }

  void proceedToJoinHouse() {
    Get.toNamed(Routes.JOIN_HOUSE);
  }

  void proceedToCreateHouse() {
    Get.toNamed(Routes.LOGIN, arguments: {'action': 'create'});
  }
}