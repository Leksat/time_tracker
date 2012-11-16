
part of time_tracker;

/**
 * Time tracker.
 */
class Tracker {
  List<Task> tasks = [];
  Timer autoSave;
  DivElement tasksDiv = document.query('#tasks');
  Element body = document.query('body');
  int activeTasks = 0;

  Tracker() {
    // load from storage
    var data = _load();
    
    if (data.isEmpty) {
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
        data.keys.forEach((key) {
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

