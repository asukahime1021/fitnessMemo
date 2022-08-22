import 'package:fitness_memo/constant/constant.dart';
import 'package:fitness_memo/object/db.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

var selectedDayProvider = StateProvider<DateTime?>((ref) => null);
var focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
Database? database;

class EventListProviderNotifier extends StateNotifier<Map<DateTime, List<String>>> {
  EventListProviderNotifier(): super(defaultMap());
  
  void addAll(Map<DateTime, List<String>> map) {
    state = defaultMap()..addAll(map);
  }

  void addEvent(DateTime key, String element) {
    var map = defaultMap()..addAll(state);
    if (map[key] == null) {
      map[key] = <String>[];
    }
    map[key]!.add(element);
    state = map;
  }

  void removeEvent(DateTime key, String element) {
    var map = defaultMap()..addAll(state);
    map[key] = [
      for (var e in map[key]!)
        if (e != element) e
    ];
    state = map;
  }
}
var eventListProvider = StateNotifierProvider<EventListProviderNotifier, Map<DateTime, List<String>>>(
  (ref) => EventListProviderNotifier()
);

