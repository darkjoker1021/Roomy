import 'package:get/get.dart';

import '../controllers/manage_account_controller.dart';

class ManageAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageAccountController>(
      () => ManageAccountController(),
    );
  }
}
