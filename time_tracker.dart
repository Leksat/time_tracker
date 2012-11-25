
part of time_tracker;

/**
 * Time tracker.
 */
class TimeTracker {
  final int dataSchemaVersion = 1;
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
    // Restore window size. Position also could be restored, but it works
    // unexpected on multi-monitors.
    window.resizeTo(data['window']['width'], data['window']['height']);
    // Restore tasks.
    if (data['tasks'].isEmpty) {
      createNewTask();
    } else {
      data['tasks'].forEach((values) {
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
    var _tasks = [];
    tasks.forEach((task) {
      _tasks.add(task.toMap());
    });
    window.localStorage[_url] = JSON.stringify({
      'dataSchemaVersion': dataSchemaVersion,
      'tasks': _tasks,
      'window': _getWindowParams()
    });
  }

  /**
   * Loads saved tasks from storage.
   */
  Map _loadFromStorage() {
    if (window.localStorage.containsKey(_url)) {
      try {
        var data = JSON.parse(window.localStorage[_url]);
        if (data is Map && data.containsKey('dataSchemaVersion')) {
          if (data['dataSchemaVersion'] == dataSchemaVersion) {
            return data;
          } else {
            // There could be data updates.
          }
        }
      } on Exception catch (e) {} 
    }
    // Defaults.
    return {
      'tasks': [],
      'window': _getWindowParams()
    };
  }
  
  /**
   * Returns window parameters.
   */
  Map _getWindowParams() {
    return {
      'width': window.innerWidth,
      'height': window.innerHeight
    };
  }
}
