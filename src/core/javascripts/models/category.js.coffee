'use strict';

###**
* @ngdoc service
* @name BB.Models:Category
*
* @description
* Representation of an Category Object
####

angular.module('BB.Models').factory "CategoryModel", ($q, BBModel, BaseModel, CategoryService) ->

  class Category extends BaseModel

    ###**
    * @ngdoc method
    * @name $query
    * @methodOf BB.Models:Category
    * @description
    * Static function that loads an array of categories from a company object.
    *
    * @param {object} company Company object
    *
    * @returns {promise} A returned promise
    ###
  	 @$query: (company) ->
       CategoryService.query(company)
