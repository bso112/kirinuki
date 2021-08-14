
import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:kirinuki/presentation/EditPageController.dart';

class EditPageBinding implements Bindings{
  @override
  void dependencies() {
    Get.put(EditPageController());
  }

}