'use strict'

###
* @ngdoc service
* @name BBAdminDashboard.check-in.services.service:AdminCheckInOptions
*
* @description
* Returns a set of admin calendar configuration options
###

###
* @ngdoc service
* @name BBAdminDashboard.check-in.services.service:AdminCheckInOptionsProvider
*
* @description
* Provider
*
* @example
  <example>
  angular.module('ExampleModule').config ['AdminCheckInOptionsProvider', (AdminCheckInOptionsProvider) ->
    AdminCheckInOptionsProvider.setOption('option', 'value')
  ]
  </example>
###
angular.module('BBAdminDashboard.check-in.services').provider 'AdminCheckInOptions', [ ->
  # This list of options is meant to grow
  options = {
    use_default_states : true
    show_in_navigation : true
    parent_state       : 'root'
  }

  @setOption = (option, value) ->
    if options.hasOwnProperty(option)
      options[option] = value
    return

  @getOption = (option) ->
    if options.hasOwnProperty(option)
      return options[option]
    return
  @$get =  ->
    options

  return
]