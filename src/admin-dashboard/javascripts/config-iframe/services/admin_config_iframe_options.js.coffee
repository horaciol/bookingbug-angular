'use strict'

###
* @ngdoc service
* @name BBAdminDashboard.config-iframe.services.service:AdminConfigIframeOptions
*
* @description
* Returns a set of admin calendar configuration options
###

###
* @ngdoc service
* @name BBAdminDashboard.config-iframe.services.service:AdminConfigIframeOptionsProvider
*
* @description
* Provider
*
* @example
  <example>
  angular.module('ExampleModule').config ['AdminConfigIframeOptionsProvider', (AdminConfigIframeOptionsProvider) ->
    AdminConfigIframeOptionsProvider.setOption('option', 'value')
  ]
  </example>
###
angular.module('BBAdminDashboard.config-iframe.services').provider 'AdminConfigIframeOptions', [ ->
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