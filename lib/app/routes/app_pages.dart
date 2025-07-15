import 'package:get/get.dart';

import '../modules/account/bindings/account_binding.dart';
import '../modules/account/views/account_view.dart';
import '../modules/create_house/bindings/create_house_binding.dart';
import '../modules/create_house/views/create_house_view.dart';
import '../modules/house/bindings/house_binding.dart';
import '../modules/house/views/house_view.dart';
import '../modules/join_house/bindings/join_house_binding.dart';
import '../modules/join_house/views/join_house_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/manage_account/bindings/manage_account_binding.dart';
import '../modules/manage_account/views/manage_account_view.dart';
import '../modules/shopping/bindings/shopping_binding.dart';
import '../modules/shopping/views/shopping_view.dart';
import '../modules/tasks/bindings/home_binding.dart';
import '../modules/tasks/views/tasks_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      name: _Paths.HOUSE,
      page: () => const HouseView(),
      binding: HouseBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
        name: _Paths.MAIN,
        page: () => const MainView(),
        binding: MainBinding(),
        children: [
          GetPage(
            name: _Paths.TASKS,
            page: () => const TasksView(),
            binding: TasksBinding(),
          ),
          GetPage(
            name: _Paths.SHOPPING,
            page: () => const ShoppingView(),
            binding: ShoppingBinding(),
          ),
          GetPage(
            name: _Paths.HOUSE,
            page: () => const HouseView(),
            binding: HouseBinding(),
          ),
          GetPage(
            name: _Paths.ACCOUNT,
            page: () => const AccountView(),
            binding: AccountBinding(),
          ),
        ]),
    GetPage(
      name: _Paths.MANAGE_ACCOUNT,
      page: () => const ManageAccountView(),
      binding: ManageAccountBinding(),
    ),
    GetPage(
      name: _Paths.HOUSE,
      page: () => const HouseView(),
      binding: HouseBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_HOUSE,
      page: () => const CreateHouseView(),
      binding: CreateHouseBinding(),
    ),
    GetPage(
      name: _Paths.JOIN_HOUSE,
      page: () => const JoinHouseView(),
      binding: JoinHouseBinding(),
    ),
  ];
}
