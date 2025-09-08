import 'package:hive_ce/hive.dart';
import 'package:pomoslice/data/task.dart';

@GenerateAdapters([AdapterSpec<Task>()])
part 'hive_adapters.g.dart';