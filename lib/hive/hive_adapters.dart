import 'package:hive_ce/hive.dart';
import 'package:pomoslice/data/task.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<Task>(),
])

class HiveAdapters {}