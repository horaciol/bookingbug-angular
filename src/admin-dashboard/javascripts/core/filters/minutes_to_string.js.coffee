###*
@ngdoc filter
@name BBAdminDashboard.filter:minutesToString
@description
Converts a number to the desired format (default is hour minute(HH:mm))
###
angular.module('BBAdminDashboard').filter 'minutesToString', ->
  (minutes, format = 'HH:mm') ->
    return moment(moment.duration(minutes, 'minutes')._data).format(format)
