import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const _people = 'people';
  static const _groups = 'groups';
  static const _history = 'history';
  static const _settings = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox<Map>(_people),
      Hive.openBox<Map>(_groups),
      Hive.openBox<Map>(_history),
      Hive.openBox(_settings),
    ]);
  }

  static Box<Map> get peopleBox => Hive.box<Map>(_people);
  static Box<Map> get groupsBox => Hive.box<Map>(_groups);
  static Box<Map> get historyBox => Hive.box<Map>(_history);
  static Box get settingsBox => Hive.box(_settings);
}
