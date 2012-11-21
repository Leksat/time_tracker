
part of time_tracker;

/**
 * Task.
 */
class Task {
  String name = '';
  int seconds = 0;
  String get time {
    return _formatTimeString(seconds);
  }
  void set time(time) {
    var _seconds = _parseTimeString(time);
    if (_seconds != -1) {
      seconds = _seconds;
    }
  }
  Timer _timer;
  bool working = false;
  String toggleStateLabel = 'Start';

  /**
   * Constructor.
   */
  Task() {}
  
  /**
   * From string constructor.
   */
  Task.fromMap(Map values) {
    if (values.containsKey('name') && values['name'] is String) {
      name = values['name'];
    }
    if (values.containsKey('seconds') && values['seconds'] is int) {
      seconds = values['seconds'];
    } 
  }
  
  /**
   * Returns a map with "primary" properties values.
   */
  Map toMap() {
    return {
      'name': name,
      'seconds' : seconds
    };
  }
  
  /**
   * Starts time tracking.
   */
  void toggleState([Event e]) {
    if (!working) {
      var started = new Date.now().subtract(new Duration(seconds: seconds));
      _timer = new Timer.repeating(1000, (timer) {
        seconds = (new Date.now()).difference(started).inSeconds;
        watchers.dispatch();
      });
      working = true;
      toggleStateLabel = 'Stop';
      timeTracker.activeTasks++;
    } else {
      _timer.cancel();
      working = false;
      toggleStateLabel = 'Start';
      timeTracker.activeTasks--;
    }
  }
  
  /**
   * Removes task.
   */
  void delete([Event e]) {
    if (working) {
      toggleState();
    }
    timeTracker.tasks.removeAt(timeTracker.tasks.indexOf(this));
  }
  
  /**
   * Returns time string in "H:MM:SS" format.
   */
  String _formatTimeString(int seconds) {
    var h = seconds ~/ (60*60);
    var m = (seconds - h*60*60) ~/ 60;
    var s = seconds % 60;
    s = (s >= 10) ? s : '0${s}';
    m = (m >= 10) ? m : '0${m}';
    return '${h}:${m}:${s}';
  }

  /**
   * Returns seconds count parsing them from time string in "H:MM:SS" format.
   */
  int _parseTimeString(String time) {
    var parts = time.split(':');
    if (parts.length != 3) {
      return -1;
    }
    var h = int.parse(parts[0]);
    if (h.isNaN || h <0) {
      return -1;
    }
    var m = int.parse(parts[1]);
    if (m.isNaN || m < 0 || m > 60) {
      return -1;
    }
    var s = int.parse(parts[2]);
    if (s.isNaN || s < 0 || s > 60) {
      return -1;
    }
    return h*60*60 + m*60 + s;
  }
}
