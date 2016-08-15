'use strict'

###*
 * @ngdoc directive
 * @name BBAdminDashboard.directive:adminSideNav
 * @scope
 * @restrict A
 *
 * @description
 * Ensures iframe size is based on iframe content and that the iframe src is whitelisted
 *
 * @param {string}  path         A string that contains the iframe url
 * @param {string}  apiUrl       A string that contains the ApiUrl
 * @param {object}  extraParams  An object that contains extra params for the url (optional)
###
angular.module('BBAdminDashboard').directive 'adminSideNav', [() ->
  {
    restrict: 'A'
    scope: false
    templateUrl: 'core/admin-side-nav.html'
    controller: ['$scope', 'SideNavigationPartials', ($scope, SideNavigationPartials) ->
      $scope.navigation = SideNavigationPartials.getOrderedPartialTemplates()
    ]
    link: (scope, element, attrs) ->

  }
]
