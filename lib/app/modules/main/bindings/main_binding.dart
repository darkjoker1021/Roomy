import 'package:roomy/app/modules/account/controllers/account_controller.dart';
import 'package:get/get.dart';
import 'package:roomy/app/modules/add/controllers/add_controller.dart';
import 'package:roomy/app/modules/shopping/controllers/shopping_controller.dart';
import 'package:roomy/app/modules/tasks/controllers/tasks_controller.dart';

import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(
      () => MainController(),
    );
    Get.lazyPut<TasksController>(
      () => TasksController(),
    );
    Get.lazyPut<ShoppingController>(
      () => ShoppingController(),
    );
    Get.lazyPut<AddController>(
      () => AddController(),
    );
    Get.lazyPut<AccountController>(
      () => AccountController(),
    );
  }
}
