###*
* @ngdoc service
* @name BBAdminDashboard.BusyService
*
* @description
###
angular.module('BBAdminDashboard').factory "BusyService", [
  '$q', '$log', '$rootScope', 'AlertService', 'ErrorService',
  ($q, $log, $rootScope, AlertService, ErrorService) ->

    notLoaded: (cscope) ->
      cscope.$emit 'show:loader', cscope
      cscope.isLoaded = false
      # then look through all the scopes for the 'loading' scope, which is the
      # scope which has a 'scopeLoaded' property and set it to false, which makes
      # the ladoing gif show;
      while cscope
        if cscope.hasOwnProperty('scopeLoaded')
          cscope.scopeLoaded = false
        cscope = cscope.$parent
      return


    setLoaded: (cscope) ->
      cscope.$emit 'hide:loader', cscope
      # set the scope loaded to true...
      cscope.isLoaded = true
      # then walk up the scope chain looking for the 'loading' scope...
      loadingFinished = true;

      while cscope
        if cscope.hasOwnProperty('scopeLoaded')
          # then check all the scope objects looking to see if any scopes are
          # still loading
          if $scope.areScopesLoaded(cscope)
            cscope.scopeLoaded = true
          else
            loadingFinished = false
        cscope = cscope.$parent

      if loadingFinished
        $rootScope.$broadcast 'loading:finished'


    setPageLoaded: (scope) ->
      null


    setLoadedAndShowError: (scope, err, error_string) ->
      $log.warn(err, error_string)
      @setLoaded(scope)
      if err.status is 409
        AlertService.danger(ErrorService.getError('ITEM_NO_LONGER_AVAILABLE'))
      else if err.data and err.data.error is "Number of Bookings exceeds the maximum"
        AlertService.danger(ErrorService.getError('MAXIMUM_TICKETS'))
      else
        AlertService.danger(ErrorService.getError('GENERIC'))


    # go around schild scopes - return false if *any* child scope is marked as
    # isLoaded = false
    areScopesLoaded: (cscope) ->
      if cscope.hasOwnProperty('isLoaded') && !cscope.isLoaded
        false
      else
        child = cscope.$$childHead
        while (child)
          return false if !$scope.areScopesLoaded(child)
          child = child.$$nextSibling
        true
]
