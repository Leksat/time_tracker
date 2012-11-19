
part of time_tracker;

/**
 * Time tracker.
 */
class TimeTracker {
  String wrapperClass = 'idle';
  List<Task> tasks = new List();
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
  String _url = window.location.toString();

  /**
   * Constructor.
   */
  TimeTracker() {
    // Load saved data from storage.
    var data = _loadFromStorage();
    if (data.isEmpty) {
      createNewTask();
    } else {
      data.forEach((values) {
        tasks.add(new Task.fromMap(values));
      });
    }
    // Initialize autosave.
    new Timer.repeating(1000, (timer) => this._saveToStorage());
  }
  
  /**
   * Creates new task.
   */
  void createNewTask([Event e]) {
    tasks.add(new Task());
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
    var data = [];
    tasks.forEach((task) {
      data.add(task.toMap());
    });
    window.localStorage[_url] = JSON.stringify(data);
  }

  /**
   * Loads saved tasks from storage.
   */
  List<Map> _loadFromStorage() {
    if (window.localStorage.containsKey(_url)) {
      try {
        var data = JSON.parse(window.localStorage[_url]);
        if (data is List) {
          // Check that nested values are maps.
          data.filter((value) => value is Map);
          return data;
        }
      } on Exception catch (e) {} 
    }
    return [];
  }
}
