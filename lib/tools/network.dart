import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

Widget getImage(String? url) {
  return url == null
      ? Container()
      : FadeInImage.assetNetwork(
      fit: BoxFit.cover,
      placeholder: "assets/images/loading.gif",
      image: url);
}

//라운드 처리 이미지
Widget getRoundImage(String? url, {double radius = 25}) {
  return url == null
      ? ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(color: Colors.grey.shade500))
      : ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: FadeInImage.assetNetwork(
        fit: BoxFit.cover,
        placeholder: "assets/images/loading.gif",
        image: url),
  );
}