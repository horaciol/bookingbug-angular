'use strict'

###
* @ngdoc service
* @name BBAdminDashboard.members-iframe.services.service:AdminMembersIframeOptions
*
* @description
* Returns a set of General configuration options
###

###
* @ngdoc service
* @name BBAdminDashboard.members-iframe.services.service:AdminMembersIframeOptionsProvider
*
* @description
* Provider
*
* @example
  <example>
  angular.module('ExampleModule').config ['AdminMembersIframeOptionsProvider', (AdminMembersIframeOptionsProvider) ->
    AdminMembersIframeOptionsProvider.setOption('option', 'value')
  ]
  </example>
###
angular.module('BBAdminDashboard.members-iframe.services').provider 'AdminMembersIframeOptions', [ ->
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