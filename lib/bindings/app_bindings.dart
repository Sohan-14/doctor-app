import 'package:doctor_app/controllers/auth_controller.dart';
import 'package:get/get.dart';

class AppBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}