'use strict';

###
* @ngdoc controller
* @name BBAdminDashboard.logout.controllers.controller:resetPasswordPageCtrl
#
* @description
* Controller for the logout page
###
angular.module('BBAdminDashboard.reset-password.controllers')
.controller 'resetPasswordPageCtrl', (AdminSsoLogin, BBModel, $scope, $state, $sessionStorage, ResetPasswordSchemaFormService, schemaForm) ->
  # BBModel.Admin.Login.$logout().then ()->
  #   $sessionStorage.removeItem("user")
  #   $sessionStorage.removeItem("auth_token")

  #   AdminSsoLogin.ssoToken = null
  #   AdminSsoLogin.companyId = null

  #   $state.go 'login', {}, {reload: true}

  #   return

  ResetPasswordSchemaFormService.getSchemaForm().then (response) ->
    console.log "response.data.schema :", response.data.schema
    console.log "response.data.form :", response.data.form

    $scope.schema = response.data.schema

    $scope.form = response.data.form

    $scope.model = {}
  , (err) ->
    console.log "Error: ", err

  $scope.submitSchemaForm = (model) ->
    ResetPasswordSchemaFormService.postSchemaForm(model.password).then (response) ->
      console.log "response from POST :", response
    , (err) ->
      console.log "Error: ", err

  return
