
part of time_tracker;

/**
 * Task.
 */
class Task {
  int seconds;
  String name;
  DivElement taskDiv;
  InputElement nameInput;
  InputElement timeInput;
  DivElement tasksDiv;
  Tracker tracker;
  Timer timer;
  bool working = false;

  Task(this.tracker, [this.name = '', this.seconds = 0]) {
    // copy task from template
    taskDiv = document.query('#task-template').clone(true);
    taskDiv.attributes.remove('id');
    
    // init inputs
    nameInput = taskDiv.query('.name');
    timeInput = taskDiv.query('.time');
    nameInput.value = name;
    timeInput.value = formatTimeString(seconds);
    
    // attach to dom
    tracker.tasksDiv.elements.add(taskDiv);
    
    // attach event handlers
    nameInput.on.keyUp.add((Event event) {
      name = (event.srcElement as InputElement).value;
    });
    timeInput.on.keyUp.add((Event event) {
      InputElement timeInput = event.srcElement;
      var s = parseTimeString(timeInput.value);
      if (s != -1) {
        seconds = s;
        timeInput.classes.remove('error');
      } else {
        timeInput.classes.add('error');
      }
    });
    taskDiv.query('.start').on.click.add((event) => this.start());
    taskDiv.query('.stop').on.click.add((event) => this.stop());
    taskDiv.query('.delete').on.click.add((Event event) {
      if (window.confirm('Do you really want to remove this task?')) {
        this.remove();
        tracker.tasks.removeRange(tracker.tasks.indexOf(this), 1);
      }
    });
  }
  
  void remove() {
    stop();
    taskDiv.remove();
  }
  
  void start() {
    if (!working) {
      timeInput.disabled = true;
      var started = new Date.now().subtract(new Duration(seconds: seconds));
      timer = new Timer.repeating(1000, (timer) {
        seconds = (new Date.now()).difference(started).inSeconds;
        timeInput.value = formatTimeString(seconds);
      });
      working = true;
      tracker.setState(true);
    }
  }
  
  void stop() {
    if (working) {
      timer.cancel();
      timeInput.disabled = false;
      working = false;
      tracker.setState(false);
    }
  }
  
  String formatTimeString(int seconds) {
    var h = seconds ~/ (60*60);
    var m = (seconds - h*60*60) ~/ 60;
    var s = seconds % 60;
    s = (s >= 10) ? s : '0${s}';
    m = (m >= 10) ? m : '0${m}';
    return '${h}:${m}:${s}';
  }
  
  int parseTimeString(String time) {
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
