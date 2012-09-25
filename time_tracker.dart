
#import('dart:html');
#import('dart:isolate');
#import('dart:json');

void main() {
  new TimeTracker();
}

/**
 * Time tracker.
 */
class TimeTracker {
  List<Task> tasks = [];
  Timer autoSave;
  DivElement tasksDiv = document.query('#tasks');
  Element body = document.query('body');
  int activeTasks = 0;

  TimeTracker() {
    // load from storage
    var data = _load();
    
    if (data.isEmpty()) {
      tasks.add(new Task(this));
    } else {
      data.forEach((name, seconds) {
        tasks.add(new Task(this, name, seconds));
      });
    }
    
    // attach event handlers
    document.query('#new-task').on.click.add((Event event) {
      tasks.add(new Task(this));
    });
    document.query('#clear-all').on.click.add((Event event) {
      if (window.confirm('Do you really want to clear all tasks?')) {
        tasks.forEach((task) {
          task.remove();
        });
        tasks.clear();
        tasks.add(new Task(this));
      }
    });
    
    // init autosave
    autoSave = new Timer.repeating(1000, (timer) => this.saveAll());
  }
  
  saveAll() {
    var data = {};
    tasks.forEach((task) {
      if (data.containsKey(task.name)) {
        data[task.name] += task.seconds;
      } else {
        data[task.name] = task.seconds;
      }
    });
    _save(data);
  }
  
  void _save(Map<String, int> data) {
    window.localStorage['time_tracker'] = JSON.stringify(data);
  }

  Map<String, int> _load() {
    if (window.localStorage.containsKey('time_tracker')) {
      try {
        Map data = JSON.parse(window.localStorage['time_tracker']);
        data.getKeys().forEach((key) {
          if (key is! String || data[key] is! int) {
            data.remove(key);
          }
        });
        return data;
      } on Exception catch (e) {} 
    }
    return {};
  }
  
  void setState(active) {
    if (active) {
      activeTasks++;
    } else {
      activeTasks--;
    }
    if (activeTasks > 0) {
      body.classes.add('working');
      body.classes.remove('idle');
    } else {
      body.classes.add('idle');
      body.classes.remove('working');
    }
  }
}

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
  TimeTracker timeTracker;
  Timer timer;
  bool working = false;

  Task(this.timeTracker, [this.name = '', this.seconds = 0]) {
    // copy task from template
    taskDiv = document.query('#task-template').clone(true);
    taskDiv.attributes.remove('id');
    
    // init inputs
    nameInput = taskDiv.query('.name');
    timeInput = taskDiv.query('.time');
    nameInput.value = name;
    timeInput.value = formatTimeString(seconds);
    
    // attach to dom
    timeTracker.tasksDiv.elements.add(taskDiv);
    
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
        timeTracker.tasks.removeRange(timeTracker.tasks.indexOf(this), 1);
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
      timeTracker.setState(true);
    }
  }
  
  void stop() {
    if (working) {
      timer.cancel();
      timeInput.disabled = false;
      working = false;
      timeTracker.setState(false);
    }
  }
  
  String formatTimeString(int seconds) {
    var h = (seconds / (60*60)).toInt();
    var m = ((seconds - h*60*60) / 60).toInt();
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
    if (h.isNaN() || h <0) {
      return -1;
    }
    var m = int.parse(parts[1]);
    if (m.isNaN() || m < 0 || m > 60) {
      return -1;
    }
    var s = int.parse(parts[2]);
    if (s.isNaN() || s < 0 || s > 60) {
      return -1;
    }
    return h*60*60 + m*60 + s;
  }
}
