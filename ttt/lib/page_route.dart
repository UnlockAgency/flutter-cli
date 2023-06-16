import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

class BaseRoute<T> extends Route<T> {
  BaseRoute({
    required this.page,
  });

  final Widget page;

  get builder {
    if (Platform.isAndroid) {
      return MaterialPageRoute(builder: (context) => page);
    } else {
      return CupertinoPageRoute(builder: (context) => page);
    }
  }
}
