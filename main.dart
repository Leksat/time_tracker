
library time_tracker;

import 'dart:html';
import 'dart:isolate';
import 'dart:json';
import 'package:uuid/uuid.dart';
import 'package:web_components/watcher.dart' as watchers;

part 'task.dart';
part 'time_tracker.dart';

/**
 * Used as global entry point of the program.
 */
TimeTracker timeTracker = new TimeTracker();

void main() {}
