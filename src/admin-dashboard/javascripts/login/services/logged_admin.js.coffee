'use strict'

###
* @ngdoc service
* @name BBAdminDashboard.login.services.service:SideNavigationPartials
*
* @description
* This service contains the logged in user's information
*
###
angular.module('BBAdminDashboard.login.services').factory 'LoggedAdmin', [
  'AdminLoginOptions', '$q',
  (AdminLoginOptions, $q) ->
    loggedAdmin =
      user               : null
      adminAccountsArray : null
      departmentsArray   : null
      currentCompany     : null

    {
      setUser: (user) ->
        loggedAdmin.user = user
        return
      getUser: () ->
        loggedAdmin.user
      setCurrentCompany: (company) ->
        loggedAdmin.currentCompany = company
        # if current company changes departments have to be refetched
        loggedAdmin.departmentsArray = null
        return
      getCurrentCompany: () ->
        deferred = $q.defer()

        if loggedAdmin.currentCompany?
          deferred.resolve(loggedAdmin.currentCompany)
          return deferred.promise

        if !loggedAdmin.user?
          deferred.reject(new Error('LOGGED_ADMIN.ERROR_NO_USER_PROVIDED'))
          return deferred.promise

        if loggedAdmin.user.$has('company')
          loggedAdmin.user.getCompanyPromise().then (company) ->
            loggedAdmin.currentCompany = company
            deferred.resolve(loggedAdmin.currentCompany)
          , (err)->
            deferred.reject(new Error('LOGGED_ADMIN.ERROR_ISSUE_WITH_COMPANY'))

        return deferred.promise

      getAdminAccounts: () ->
        deferred = $q.defer()

        if loggedAdmin.adminAccountsArray?
          deferred.resolve(loggedAdmin.adminAccountsArray)
          return deferred.promise

        if !loggedAdmin.user?
          deferred.reject(new Error('LOGGED_ADMIN.ERROR_NO_USER_PROVIDED'))
          return deferred.promise

        if loggedAdmin.user.$has('administrators')
          loggedAdmin.user.getAdministratorsPromise().then (adminAccounts) ->
            loggedAdmin.adminAccountsArray = administrators
            deferred.resolve(loggedAdmin.adminAccountsArray)
          , (err) ->
            deferred.reject(new Error('LOGGED_ADMIN.ERROR_COULD_NOT_GET_ADMINS'))
        else
          loggedAdmin.adminAccountsArray = []
          deferred.resolve(loggedAdmin.adminAccountsArray)

        return deferred.promise

      getDepartments: () ->
        deferred = $q.defer()

        if loggedAdmin.departmentsArray?
          deferred.resolve(loggedAdmin.departmentsArray)
          return deferred.promise

        if !loggedAdmin.user?
          deferred.reject(new Error('LOGGED_ADMIN.ERROR_NO_USER_PROVIDED'))
          return deferred.promise

        @getCurrentCompany().then (company)->
          if company.companies && company.companies.length > 0
            loggedAdmin.departmentsArray = company.companies
            deferred.resolve(loggedAdmin.departmentsArray)
          else
            loggedAdmin.departmentsArray = []
            deferred.resolve(loggedAdmin.departmentsArray)
        , (err) ->
          deferred.reject(err)

        return deferred.promise
    }
]