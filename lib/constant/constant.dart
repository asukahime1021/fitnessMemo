import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

final firstDay = DateTime(2022, 8, 1, 0, 0);
final lastDay = DateTime(2030, 12, 31, 0, 0);
const titleAppBar = Text("Fitness Memo");
const insertAppBar = Text("トレーニング登録");
final datePattern = RegExp(r'^[0-9]{8}$');
LinkedHashMap<DateTime, List<String>> defaultMap() => LinkedHashMap<DateTime, List<String>>(
  equals: isSameDay,
  hashCode: (DateTime day) => day.day * 1000000 + day.month * 10000 * day.year
);
