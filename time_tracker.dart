
part of time_tracker;

/**
 * Time tracker.
 */
class TimeTracker {
  String wrapperClass = 'idle';
  Map<String, Task> tasks = new Map();
  int _activeTasks = 0;
  int get activeTasks {
    return _activeTasks;
  }
  void set activeTasks(count) {
    _activeTasks = count;
    if (_activeTasks > 0) {
      wrapperClass = 'working';
    } else {
      wrapperClass = 'idle';
    }
  }
  Uuid _uuid = new Uuid();

  /**
   * Constructor.
   */
  TimeTracker() {
    // Load saved data from storage.
    var data = _loadFromStorage();
    if (data.isEmpty) {
      createNewTask();
    } else {
      data.forEach((uuid, values) {
        tasks[uuid] = new Task(uuid, values['name'], values['seconds']);
      });
    }
    // Initialize autosave.
    new Timer.repeating(1000, (timer) => this._saveToStorage());
  }
  
  /**
   * Creates new task.
   */
  void createNewTask([Event e]) {
    var uuid = _uuid.v1();
    tasks[uuid] = new Task(uuid);
  }
  
  /**
   * Deletes all tasks.
   */
  void deleteAllTasks([Event e]) {
    tasks.clear();
    createNewTask();
  }

  /**
   * Saves all tasks to storage.
   */
  void _saveToStorage() {
    var data = {};
    tasks.forEach((uuid, task) {
      data[uuid] = {
        'name': task.name,
        'seconds': task.seconds,
      };
    });
    window.localStorage['time_tracker'] = JSON.stringify(data);
  }

  /**
   * Loads saved tasks from storage.
   */
  Map<String, Map> _loadFromStorage() {
    if (window.localStorage.containsKey('time_tracker')) {
      try {
        Map data = JSON.parse(window.localStorage['time_tracker']);
        // Check that data has correct format.
        data.keys.forEach((key) {
          if (key is! String || data[key] is! Map
              || !data[key].containsKey('name')
              || !data[key].containsKey('seconds')) {
            data.remove(key);
          }
        });
        return data;
      } on Exception catch (e) {} 
    }
    return {};
  }
}
