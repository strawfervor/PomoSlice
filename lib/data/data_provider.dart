import 'package:tostore/tostore.dart';
import 'dart:async';

//creating new object of this class:
//final dataProvider = DataProvider(); crete object
//await dataProvider.initializeDb(); initialize db

class DataProvider {
  DataProvider();

  final db = ToStore();

  Future<void> initializeDb() async {
    await db.initialize();
  }

  Future<void> updateTask(String taskName, int taskTime) async {
    db
        .upsert('task', {'taskName': taskName, 'taskTime': taskTime, 'streak' : 0})
        .where('taskName', '=', taskName);
  }
}
