import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

/// 로그인 관련 Toast 메시지 출력
void showLoginToast(String msg) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
  );
}

/// 게시물 업로드 관련 Toast 메시지 출력
void showUploadToast(String msg, {Color bgColor = Colors.black, Color textColor = Colors.white}) {
  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: bgColor,
    textColor: textColor,
    fontSize: 16.0,
  );
}
