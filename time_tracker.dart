
library time_tracker;

import 'dart:html';
import 'dart:isolate';
import 'dart:json';

part 'task.dart';
part 'tracker.dart';

void main() {
  new Tracker();
}
