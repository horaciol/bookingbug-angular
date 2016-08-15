###*
* @ngdoc service
* @name BBAdminDashboard.AdminSsoLogin
*
* @description
* Responsible for loging in the admin user via the sso token
*
* @property {string} sso_token The sso_token to be used
* @property {function} callback (optional) funtion to be called after the successfull login, receives UserAdmin (BaseResource) obj as input
###
angular.module('BBAdminDashboard').factory 'AdminSsoLogin', [
  'halClient', 'AdminSsoLoginUrl',
  (halClient, AdminSsoLoginUrl) ->
    return (sso_token, callback)->
      data = {
        token: sso_token
      }
      halClient.$post(AdminSsoLoginUrl, {}, data).then (login) ->
        params = {auth_token: login.auth_token}
        login.$get('administrator', params).then (admin) ->
          if typeof callback == 'function'
            callback admin
]
