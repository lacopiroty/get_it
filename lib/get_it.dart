library get_it;

typedef FactoryFunc<T> = T Function();

/// Very simple and easy to use service locator
/// You register your object creation or an instance of an object with [register], [registerSingleton] or [registerLazySingleton]
/// And retrieve the desired object using [get]
class GetIt {
  static Map<Type, _ServiceFactory> _factories = new Map<Type, _ServiceFactory>();
  
  /// By default it's not allowed to register a type a second time. 
  /// If you really need to you can disable the asserts by setting[allowReassignment]= true
  static bool allowReassignment = false;

  /// retrives or creates an instance of a registered type [T] depending on the registration function used for this type.
  static T get<T>() {
    var object = _factories[T];
    if (object == null) {
      throw new Exception("Object of type ${T.toString()} is not registered inside GetIt");
    }
    return object.getObject<T>();
  }

  /// registers a type so that a new instance will be created on each call of [get] on that type
  /// [T] type to register
  /// [fun] factory funtion for this type
  static void register<T>(FactoryFunc<T> func) {
    assert(!_factories.containsKey(T),"Type ${T.toString()} is already registered");
    _factories[T] = new _ServiceFactory(_ServiceFactoryType.alwaysNew, creationFunction: func);
  }

  /// registers a type as Singleton by passing a factory function that will be called on the first call of [get] on that type
  /// [T] type to register
  /// [fun] factory funtion for this type
  static void registerLazySingleton<T>(FactoryFunc<T> func) {
    assert(!_factories.containsKey(T),"Type ${T.toString()} is already registered");
    _factories[T] = new _ServiceFactory(_ServiceFactoryType.lazy, creationFunction: func);
  }

  /// registers a type as Singleton by passing an instance that will be returned on each call of [get] on that type
  /// [T] type to register
  /// [fun] factory funtion for this type
  static void registerSingleton<T>(T instance) {
    assert(!_factories.containsKey(T),"Type ${T.toString()} is already registered");
   _factories[T] = new _ServiceFactory(_ServiceFactoryType.constant, instance: instance);
  }

  /// Clears all registered types. Typically only used for Unit Tests
  static void reset()
  {
    _factories.clear();
  }
}

enum _ServiceFactoryType { alwaysNew, constant, lazy }

class _ServiceFactory {
  _ServiceFactoryType type;
  FactoryFunc creationFunction;
  Object instance;

  _ServiceFactory(this.type,{this.creationFunction, this.instance});


  T getObject<T>() {
    try {
      switch (type) {
        case _ServiceFactoryType.alwaysNew:
          return creationFunction() as T;
          break;
        case _ServiceFactoryType.constant:
          return instance as T;
          break;
        case _ServiceFactoryType.lazy:
          if (instance == null) {
            instance = creationFunction();
          }
          return instance as T;
          break;
      }
    } catch (e, s) {
      print("Error while creating ${T.toString()}");
      print('Stack trace:\n $s');
      rethrow;
    }
    return null; // should never get here but to make the analyzer happy
  }
}
