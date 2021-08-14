
import 'package:get/get.dart';
import 'package:kirinuki/binding/editpage_binding.dart';
import 'package:kirinuki/presentation/EditPage.dart';
import 'package:kirinuki/presentation/start_page/start_page.dart';
import 'package:kirinuki/presentation/webview/youtube_download_page.dart';

class AppPages{
  static final pages = [
    GetPage(name: Routes.START, page:()=>StartPage()),
    GetPage(name: Routes.DOWNLOAD, page: ()=>YoutubeDownloadPage()),
    GetPage(name: Routes.EDIT, page: ()=>EditPage(), binding: EditPageBinding())
  ];
}

abstract class Routes{
  static const START = '/';
  static const DOWNLOAD = '/download';
  static const EDIT = '/edit';
}