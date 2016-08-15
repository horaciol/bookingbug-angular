'use strict'

###
* @ngdoc service
* @name BBAdminDashboard.calendar.services.service:TitleAssembler
*
* @description
* Assembles a string based on a pattern and an object provided according to the following rules
* ex: '{service_name} - {client_name} - {created_at|date:shortTime}'
* everything outside  {} will remain as is, inside the {} the first param (required) is the property name
* second after the '|' (optional) is the filter and third after the ':' (optional) are the options for filter
* if the requested property is not part of the given object it will be skipped
###
angular.module('BBAdminDashboard.calendar.services').factory 'TitleAssembler', [
  () ->
    expression = new RegExp("\\{([a-zA-z_-]+)\\|?([a-zA-z_-]+)?:?([a-zA-z0-9{}_-]+)?\\}", "g")

    {
      getTitle: (object, pattern)->
        # Return null if either the object or the pattern hasnt been passed in
        if !object? || !pattern?
          return null

        patternMatches = pattern.match expression
        # No pattern matches means there is nothing to replace in the pattern
        # hence simply return the pattern
        if !patternMatches? || patternMatches.length == 0
          return pattern

        label = pattern

        for match,index in patternMatches
          parts = match.split(expression)
          # Remove unnecessary empty properties of the array (first/last)
          parts.splice(0,1)
          parts.pop()

          # If requested property exists replace the placeholder with value otherwise with ''
          if object.hasOwnProperty parts[0]
            replaceWith = object[parts[0]]
            # if a filter is requested as part of the expression and filter exists
            if parts[1]? and $filter(parts[1])?
              # If filter has options as part of the expression use them
              if parts[2]?
                replaceWith = $filter(parts[1])(replaceWith, $scope.$eval(parts[2]))
              else
                replaceWith = $filter(parts[1])(replaceWith)

            label = label.replace(match, replaceWith)
          else
            label = label.replace(match, '')

        label
    }
]
