import 'package:flutter/material.dart';

abstract class buttons {
  static IconButton refresh({required void Function()? onPressed}) {
    return IconButton(onPressed: onPressed, icon: Icon(Icons.refresh));
  }

  static IconButton settings({required void Function()? onPressed}) {
    return IconButton(onPressed: onPressed, icon: Icon(Icons.tune));
  }
}