'use strict'

queueapp = angular.module('BBQueue', [
  'BB',
  'BBAdmin.Services',
  'BBQueue.Directives',
  'BBQueue.Controllers'
])

angular.module('BBQueue.Directives', [])

angular.module('BBQueue.Controllers', [])



queueapp.run ($rootScope, $log, DebugUtilsService, FormDataStoreService, $bbug, $document, $sessionStorage, AppConfig, AdminLoginService) ->

  # AdminLoginService.checkLogin()
  # if $rootScope.user && $rootScope.user.company_id
  #   $rootScope.bb ||= {}
  #   $rootScope.bb.company_id = $rootScope.user.company_id

angular.module('BBQueueMockE2E', ['BBQueue', 'BBAdminMockE2E'])