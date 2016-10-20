angular.module('ngStorage', [])
.factory('$fakeStorage', [
  '$cookies',
  function($cookies){
    function FakeStorage() {};
    FakeStorage.prototype.setItem = function (key, value) {
      $cookies.put(key, value);
    };
    FakeStorage.prototype.getItem = function (key) {
      return typeof $cookies.get(key) == 'undefined' ? null : $cookies.get(key);
    }
    FakeStorage.prototype.removeItem = function (key) {
      if ($cookies.get(key)){
        $cookies.remove(key);
      }
    };
    FakeStorage.prototype.clear = function(){
      for (var key in $cookies.getAll()) {
        $cookies.remove(key);
      }
    };
    FakeStorage.prototype.key = function(index){
      return Object.keys($cookies.getAll())[index];
    };
    return new FakeStorage();
  }
])
.factory('$localStorage', [
  '$window', '$fakeStorage',
  function($window, $fakeStorage) {
    function isStorageSupported(storageName) 
    {
      var testKey = 'test',
        storage = $window[storageName];
      try
      {
        storage.setItem(testKey, '1');
        storage.removeItem(testKey);
        return true;
      } 
      catch (error) 
      {
        return false;
      }
    }
    var storage = isStorageSupported('localStorage') ? $window.localStorage : $fakeStorage;
    return {
      setItem: function(key, value) {
        storage.setItem(key, value);
      },
      getItem: function(key, defaultValue) {
        return storage.getItem(key) || defaultValue;
      },
      setObject: function(key, value) {
        storage.setItem(key, JSON.stringify(value));
      },
      getObject: function(key) {
        return JSON.parse(storage.getItem(key) || '{}');
      },
      removeItem: function(key){
        storage.removeItem(key);
      },
      clear: function() {
        storage.clear();
      },
      key: function(index){
        storage.key(index);
      }
    }
  }
])
.factory('$sessionStorage', [
  '$window', '$fakeStorage',
  function($window, $fakeStorage) {
    function isStorageSupported(storageName) 
    {
      var testKey = 'test',
        storage = $window[storageName];
      try
      {
        storage.setItem(testKey, '1');
        storage.removeItem(testKey);
        return true;
      } 
      catch (error) 
      {
        return false;
      }
    }
    var storage = isStorageSupported('sessionStorage') ? $window.sessionStorage : $fakeStorage;
    return {
      setItem: function(key, value) {
        storage.setItem(key, value);
      },
      getItem: function(key, defaultValue) {
        return storage.getItem(key) || defaultValue;
      },
      setObject: function(key, value) {
        storage.setItem(key, JSON.stringify(value));
      },
      getObject: function(key) {
        return JSON.parse(storage.getItem(key) || '{}');
      },
      removeItem: function(key){
        storage.removeItem(key);
      },
      clear: function() {
        storage.clear();
      },
      key: function(index){
        storage.key(index);
      }
    }
  }
]);