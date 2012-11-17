
part of time_tracker;

// TODO: use one button for Start/Stop.

/**
 * Task.
 */
class Task {
  String uuid;
  String name;
  int seconds;
  String get time {
    return _formatTimeString(seconds);
  }
  void set time(time) {
    seconds = _parseTimeString(time);
  }
  Timer timer;
  bool working = false;

  /**
   * Constructor.
   */
  Task(this.uuid, [this.name = '', this.seconds = 0]) {}
  
  /**
   * Starts time tracking.
   */
  void start([Event e]) {
    if (!working) {
      // TODO: disable time input.
      var started = new Date.now().subtract(new Duration(seconds: seconds));
      timer = new Timer.repeating(1000, (timer) {
        seconds = (new Date.now()).difference(started).inSeconds;
        watchers.dispatch();
      });
      working = true;
      timeTracker.activeTasks++;
    }
  }
  
  /**
   * Stops time tracking.
   */
  void stop([Event e]) {
    if (working) {
      timer.cancel();
      // TODO: enable time input. 
      working = false;
      timeTracker.activeTasks--;
    }
  }
  
  /**
   * Removes task.
   */
  void delete([Event e]) {
    stop();
    timeTracker.tasks.remove(uuid);
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
