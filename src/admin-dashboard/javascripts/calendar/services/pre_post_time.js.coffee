
angular.module('BBAdminDashboard.calendar.services').factory "PrePostTime", ['$compile', ($compile) ->

  apply: (event, elements, view, scope) ->
    for e in elements
      element = angular.element(e)
      totalDuration = event.duration + event.pre_time + event.post_time
      if event.pre_time
        switch view.name
          when "agendaWeek", "agendaDay"
            preHeight = event.pre_time*(element.height() + 2)/totalDuration
            pre = $compile("<div class='pre' style='height:#{preHeight}px'></div>")(scope)
            element.prepend(pre)
          when "timelineDay"
            contentDiv = element.children()[0]
            preWidth = event.pre_time*(element.width() + 2)/totalDuration
            pre = $compile("<div class='pre' style='width:#{preWidth}px'></div>")(scope)
            element.prepend(pre)
            angular.element(contentDiv).css("padding-left", "#{preWidth}px")
      if event.post_time
        switch view.name
          when "agendaWeek", "agendaDay"
            postHeight = event.post_time*(element.height() + 2)/totalDuration
            post = $compile("<div class='post' style='height:#{postHeight}px'></div>")(scope)
            element.append(post)
          when "timelineDay"
            postWidth = event.post_time*(element.width() + 2)/totalDuration
            post = $compile("<div class='post' style='width:#{postWidth}px'></div>")(scope)
            element.append(post)
]
