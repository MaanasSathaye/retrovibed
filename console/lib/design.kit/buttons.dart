import 'package:flutter/material.dart';

abstract class buttons {
  static IconButton refresh({required VoidCallback? onPressed}) {
    return IconButton(onPressed: onPressed, icon: Icon(Icons.refresh));
  }

  static IconButton settings({required VoidCallback? onPressed}) {
    return IconButton(onPressed: onPressed, icon: Icon(Icons.tune));
  }

  static IconButton link({required VoidCallback? onPressed}) {
    return IconButton(onPressed: onPressed, icon: Icon(Icons.link));
  }

  static IconButton remove({required VoidCallback? onPressed}) {
    return IconButton(onPressed: onPressed, icon: Icon(Icons.remove));
  }
}
