'use strict'

###
* @ngdoc service
* @name BBAdminDashboard.reset-password.service:ResetPasswordService
*
* @description
* This service enables the user to send a request to reset he's password
###

angular.module('BBAdminDashboard.reset-password').factory 'ResetPasswordService', [
  '$q', '$window', '$http',
  ($q, $window, $http) ->

    postRequest: (email, base_url) ->
      deferred = $q.defer()

      url = base_url + "/api/v1/login/admin/reset_password_email"

      path = $window.location.pathname + '#/reset-password'

      body = {"email": email, "path": path}

      $http.post(url, body).then (response) =>
        deferred.resolve(response)
      , (err) =>
        deferred.reject(err)
      deferred.promise
]
