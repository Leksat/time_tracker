
#import('dart:html');
#import('dart:isolate');

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

  TimeTracker() {
    // load from storage
    if (window.localStorage.isEmpty()) {
      tasks.add(new Task(this));
    } else {
      window.localStorage.forEach((name, seconds) {
        tasks.add(new Task(this, name, int.parse(seconds)));
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

  updateState(active) {
    if (active) {
      autoSave = new Timer(10000, (timer) => this.saveAll());
    } else if (autoSave is Timer) {
      autoSave.cancel();
    }
  }
  
  saveAll() {
    window.localStorage.clear();
    tasks.forEach((task) {
      if (window.localStorage.containsKey(task.name)) {
        window.localStorage[task.name] = (int.parse(window.localStorage[task.name]) + task.seconds).toString();
      } else {
        window.localStorage[task.name] = task.seconds.toString();
      }
    });
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
    taskDiv.query('.start').on.click.add((Event event) {
      timeInput.disabled = true;
      var started = new Date.now().subtract(new Duration(seconds: seconds));
      timer = new Timer.repeating(1000, (timer) {
        seconds = (new Date.now()).difference(started).inSeconds;
        timeInput.value = formatTimeString(seconds);
      });
    });
    taskDiv.query('.stop').on.click.add((Event event) {
      timer.cancel();
      timeInput.disabled = false;
    });
    taskDiv.query('.delete').on.click.add((Event event) {
      if (window.confirm('Do you really want to remove this task?')) {
        this.remove();
        timeTracker.tasks.removeRange(timeTracker.tasks.indexOf(this), 1);
      }
    });
  }
  
  void remove() {
    taskDiv.remove();
    if (timer is Timer) {
      timer.cancel();
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
