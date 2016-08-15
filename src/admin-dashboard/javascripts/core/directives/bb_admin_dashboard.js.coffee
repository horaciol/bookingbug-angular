angular.module('BBAdminDashboard').directive 'bbAdminDashboard', () ->
  restrict: 'AE'
  template: '<div ui-view></div>'
  controller: ['$scope', '$rootScope', '$element', '$window', '$compile', '$localStorage', 'AdminLoginService', '$state', 'AlertService', 'AdminCoreOptions',
    ($scope, $rootScope, $element, $window, $compile, $localStorage, AdminLoginService, $state, AlertService, AdminCoreOptions)->
      $scope.page = {
        hideSideMenuControl    : AdminCoreOptions.deactivate_sidenav,
        hideBoxedLayoutControl : AdminCoreOptions.deactivate_boxed_layout,
        sideMenuOn             : (AdminCoreOptions.sidenav_start_open && !AdminCoreOptions.deactivate_sidenav),
        boxed                  : AdminCoreOptions.boxed_layout_start,
      }

      $scope.openSideMenu = ()->
        $scope.page.sideMenuOn = true

      $scope.closeSideMenu = ()->
        $scope.page.sideMenuOn = false

      $scope.toggleSideMenu = ()->
        $scope.page.sideMenuOn = !$scope.page.sideMenuOn


      api_url = $localStorage.getItem("api_url")
      if !$scope.bb.api_url && api_url
        $scope.bb.api_url = api_url

      $rootScope.bb = $scope.bb

      $compile("<span bb-display-mode></span>") $scope, (cloned, scope) =>
        $($element).append(cloned)

      $scope.$on '$stateChangeSuccess', (event, toState, toParams, fromState, fromParams) ->
        $scope.isLoading = false

      $scope.$on '$stateChangeError', (event, toState, toParams, fromState, fromParams, error) ->
        $scope.isLoading = false

      $scope.$on '$stateChangeNotFound', (event, toState, toParams, fromState, fromParams) ->
        $scope.isLoading = false

      $scope.logout = () ->
        $scope.isLoading = true
        AdminLoginService.logout()

      $scope.closeAlert = (alert) ->
        AlertService.closeAlert(alert)
  ]
