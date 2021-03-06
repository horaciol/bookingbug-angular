'use strict'

angular.module('BBQueue', [
  'BB',
  'BBAdmin.Services',
  'BBAdmin.Directives',
  'BBQueue.Services',
  'BBQueue.Directives',
  'BBQueue.Controllers',
  'trNgGrid',
  'ngDragDrop',
  'pusher-angular'
])

angular.module('BBQueue.Directives', [
  'timer'
])

angular.module('BBQueue.Controllers', [])

angular.module('BBQueue.Services', [
  'ngResource',
  'ngSanitize'
])

angular.module('BBQueueMockE2E', ['BBQueue', 'BBAdminMockE2E'])



