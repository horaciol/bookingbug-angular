

###**
* @ngdoc service
* @name BB.Services:Loading
*
* @description
* Representation of an Loading Object
###


angular.module('BB.Services').factory 'LoadingService',  ($q, $window, $log, $rootScope, AlertService) ->

  # create a trackable loader - this in theory allows multiple trackable loading objects in a scope - meaning we're not tied to a per-scope faction
  # currently it's still just using the scope to store the status, but we're encapsulating it away so that we can change it later
  $loader: (scope) ->
    lservice = @
    item = {
      scope: scope,
      setLoaded: ->
        lservice.setLoaded(scope)
      setLoadedAndShowError: (err, error_string) ->
        lservice.setLoadedAndShowError(scope, err, error_string)
      notLoaded: ->
        lservice.notLoaded(scope)
        return @  # return self, so you can create at set not loaded in a single line
    }
    return item

  ###**
  * @ngdoc method
  * @name setLoaded
  * @methodOf BB.Services:Loading
  * @param {array} cscope The cscope 
  * @description
  * Set loaded in according of the cscope parameter
  *
  * @returns {Promise} Returned a promise
  ###
  # called from the scopes
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
        if @areScopesLoaded(cscope)
          cscope.scopeLoaded = true
        else
          loadingFinished = false
      cscope = cscope.$parent

    if loadingFinished
      $rootScope.$broadcast 'loading:finished'
    return

  ###**
  * @ngdoc method
  * @name setLoadedAndShowError
  * @methodOf BB.Services:Loading
  * @param {object} scope The scope
  * @param {object} err The error message
  * @param {string} error_string  The error string
  * @description
  * Set set loaded and show error in according of the scope, err and error_string parameters
  *
  * @returns {Promise} Returned a promise
  ###
  setLoadedAndShowError: (scope, err, error_string) ->
    $log.warn(err, error_string)
    scope.setLoaded(scope)
    if err.status is 409
      AlertService.danger(ErrorService.getError('ITEM_NO_LONGER_AVAILABLE'))
    else if err.data and err.data.error is "Number of Bookings exceeds the maximum"
      AlertService.danger(ErrorService.getError('MAXIMUM_TICKETS'))
    else
      AlertService.danger(ErrorService.getError('GENERIC'))

  ###**
  * @ngdoc method
  * @name areScopesLoaded
  * @methodOf BB.Services:Loading
  * @param {array} cscope The cscope 
  * @description
  * Verify if the scope are loaded or not, in according of the cscope parameter
  *
  * @returns {boolean} Returns false of true
  ###
  # go around schild scopes - return false if *any* child scope is marked as
  # isLoaded = false
  areScopesLoaded: (cscope) ->
    if cscope.hasOwnProperty('isLoaded') && !cscope.isLoaded
      false
    else
      child = cscope.$$childHead
      while (child)
        return false if !@areScopesLoaded(child)
        child = child.$$nextSibling
      true

  ###**
  * @ngdoc method
  * @name notLoaded
  * @methodOf BB.Services:Loading
  * @param {array} cscope The cscope 
  * @description
  * Set scope not loaded
  *
  * @returns {object} Returns the scope not loaded
  ###
  #set scope not loaded...
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


