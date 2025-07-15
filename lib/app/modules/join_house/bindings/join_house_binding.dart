import 'package:get/get.dart';

import '../controllers/join_house_controller.dart';

class JoinHouseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JoinHouseController>(
      () => JoinHouseController(),
    );
  }
}
