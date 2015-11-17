'use strict'


###**
* @ngdoc service
* @name BB.Models:AdminAdministrator
*
* @description
* Representation of an Administrator Object
####


angular.module('BB.Models').factory "Admin.AdministratorModel", ($q, BBModel, BaseModel) ->

  class Admin_Administrator extends BaseModel

    constructor: (data) ->
      super(data)

