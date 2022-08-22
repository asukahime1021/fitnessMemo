import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

part 'db.g.dart';

class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get contents => text()();
}

@DriftDatabase(tables:[Events])
class Database extends _$Database {
  Database():super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Event>> get allEvents => select(events).get();

  Future<int> addEvent(String contents, String date) {
    return into(events)
      .insert(
        EventsCompanion(
          contents: Value(contents),
          date: Value(date)
        )
      );
  }

  Future<int> deleteEvent(int id) {
    return (delete(events)..where((tbl) => tbl.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbDirectory = await getApplicationDocumentsDirectory();
    final dbFile = File(join(dbDirectory.path, 'fitness_memo.sqlite'));
    return NativeDatabase(dbFile);
  });
}
