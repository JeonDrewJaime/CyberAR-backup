import 'package:flutter/material.dart';

void runAfterBuild(void Function() action) {
  WidgetsBinding.instance.addPostFrameCallback((_) => action());
}
