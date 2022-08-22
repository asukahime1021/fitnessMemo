import 'dart:ffi';

import 'package:fitness_memo/constant/constant.dart';
import 'package:flutter/material.dart';

Widget InsertElement(List<Widget> widgets) {
  return Row(children: widgets);
}

DateTime? localDate(DateTime? date) {
  if (date == null) {
    return null;
  }
  if (date.isUtc) {
    return date.toLocal().subtract(const Duration(hours: 9));
  }
  return date;
}