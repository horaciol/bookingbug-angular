'use strict'

###*
* @ngdoc service
* @name BBAdminDashboard.SideNavigationPartials
*
* @description
* This service assembles the navigation partials for the side-navigation
*
###
angular.module('BBAdminDashboard').factory 'SideNavigationPartials', [
  'AdminCoreOptions',
  (AdminCoreOptions) ->
    templatesArray = []

    {
      addPartialTemplate: (identifier, partial)->
        if !_.find(templatesArray, (item)-> item.module == identifier )
          templatesArray.push {
            module     : identifier,
            navPartial : partial
          }

        return

      getPartialTemplates: ()->
        templatesArray

      getOrderedPartialTemplates: (flat = false)->
        orderedList     = []
        flatOrderedList = []

        angular.forEach(AdminCoreOptions.side_navigation, (group, index)->
          if angular.isArray(group.items) && group.items.length
            newGroup = {
              group_name: group.group_name
              items: []
            }

            angular.forEach(group.items, (item, index)->
              existing = _.find(templatesArray, (template)-> template.module == item )

              if existing
                flatOrderedList.push existing
                newGroup.items.push existing
            )

            orderedList.push newGroup
        )

        orphanItems = []

        angular.forEach(templatesArray, (partial, index)->
          existing = _.find(flatOrderedList, (item)-> item.module == partial.module )

          if !existing
            flatOrderedList.push partial
            orphanItems.push partial
        )

        if orphanItems.length
          orderedList.push {
            group_name: '&nbsp;'
            items: orphanItems
          }

        if flat
          flatOrderedList
        else
          orderedList
    }
]
