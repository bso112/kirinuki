
import 'package:get/get.dart';
import 'package:kirinuki/presentation/start_page/start_page_controller.dart';
import 'package:kirinuki/tools/media_util.dart';

class StartPageBinding implements Bindings{
  @override
  void dependencies() {
    Get.put(StartPageController());
    Get.put(MediaUtil());
  }

}