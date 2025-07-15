import 'package:get/get.dart';

import '../controllers/create_house_controller.dart';

class CreateHouseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateHouseController>(
      () => CreateHouseController(),
    );
  }
}
