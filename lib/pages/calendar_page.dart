import 'package:fitness_memo/constant/constant.dart';
import 'package:fitness_memo/object/common.dart';
import 'package:fitness_memo/object/state.dart';
import 'package:fitness_memo/pages/insert_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState {

  CalendarFormat _calendarFormat = CalendarFormat.month;
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      var map = <DateTime, List<String>>{};
      var events = await database!.allEvents;
      for (var e in events) {
        var date = DateTime.parse(e.date);
        var value = map[date];
        value ??= [];
        value.add("${e.contents}:${e.id}");
        map[date] = value;
      }
      
      ref.watch(eventListProvider.notifier).addAll(map);
    });
  }

  ///
  /// process when a day selected.
  ///
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(selectedDay, ref.read(selectedDayProvider))) {
      setSelectedDay(selectedDay);
      setFocusedDay(focusedDay);
    }
  }

  ///
  /// change Focused Day
  ///
  void setFocusedDay(DateTime focusedDay) {
    ref.watch(focusedDayProvider.state).state = focusedDay;
  }

  ///
  /// change Selected Day
  ///
  void setSelectedDay(DateTime selectedDay) {
    ref.read(selectedDayProvider.state).state = localDate(selectedDay);
  }

  ///
  /// change CalendarFormat
  ///
  void setCalendarFormat(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _events = ref.watch(eventListProvider);
    List<String> _getEventForDay(DateTime? day) {
      return _events[localDate(day)] ?? [];
    }

    ListView _eventView() => ListView(
      shrinkWrap: true,
      children: _getEventForDay(ref.watch(selectedDayProvider))
        .map((e) => ListTile(
          title: Text(e.split(':')[0]),
          onLongPress: () {
            showDialog(
              context: context, 
              builder: (_) => AlertDialog(
                content: const Text("削除しますか？"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("キャンセル"), 
                    onPressed: () {
                      Navigator.pop(context);
                    },),
                  TextButton(
                    child: const Text("OK"), 
                    onPressed: () async {
                      await database!.deleteEvent(int.parse(e.split(':')[1]));
                      var map = ref.read(eventListProvider);
                      var date = ref.read(selectedDayProvider);
                      var list = map[date!];
                      map[date] = [
                        for (var e2 in list!)
                          if (e2 != e) e2
                      ];
                      ref.read(eventListProvider.notifier).removeEvent(ref.read(selectedDayProvider)!, e);
                      Navigator.pop(context);
                    },)
                ]
              )
            );
          },))
        .toList(),
    );

    Widget _mainPage() => Column(
      children: [
        TableCalendar(
          focusedDay: ref.watch(focusedDayProvider), 
          firstDay: firstDay, 
          lastDay: lastDay,
          eventLoader: _getEventForDay,
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) => setCalendarFormat(format),
          selectedDayPredicate: (day) => isSameDay(ref.watch(selectedDayProvider), day),
          onDaySelected: (selectedDay, focusedDay) => onDaySelected(selectedDay, focusedDay),
        ),
        // Column内ではListViewの大きさが定まらないため、要素が増えるとoverflowする
        // Flexibleにすることで大きさが柔軟になり、残りの高さでスクロールする
        Flexible(
          child: _eventView()
        )
      ]
    );

    return Scaffold(
      appBar: AppBar(
        title: titleAppBar
      ),
      body: Container(
        child: _mainPage()
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const InsertPage()));
        }),
    );
  }
}