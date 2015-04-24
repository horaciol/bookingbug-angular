
angular.module('BB.Directives').directive 'bbMonthPicker', ($rootScope, FormDataStoreService) ->
  restrict: 'AE'
  replace: true
  scope : true
  link : (scope, el, attrs) ->

    scope.picker_settings = scope.$eval(attrs.bbMonthPicker) or {}
    scope.watch_val = attrs.dayData

    scope.$watch scope.watch_val, (newval, oldval) ->
      scope.processDates(newval) if newval

  controller : ($scope,  $rootScope,  $q) ->

    $scope.processDates = (dates) ->
      datehash = {}
      for date in dates
        datehash[date.date.format("DDMMYY")] = date
        $scope.first_available_day = date.date if !$scope.first_available_day and date.spaces > 0

      # start at current month or the first month that has availability?
      if $scope.picker_settings.start_at_first_available_day
        cur_month = $scope.first_available_day.clone().startOf('month')
      else
        cur_month = dates[0].date.clone().startOf('month')

      date = cur_month.startOf('week')
      last_date = _.last dates
      diff = last_date.date.diff(date, 'months') + 1
      # use picker settings or diff between first and last date to determine number of months to display
      num_months = if $scope.picker_settings and $scope.picker_settings.months then $scope.picker_settings.months else diff

      months = []
      for m in [1..diff]
        date = cur_month.clone().startOf('week')
        month = {weeks: []}
        for w in [1..6]
          week = {days: []}
          for d in [1..7]
            week.days.push({date: date.clone(), data: datehash[date.format("DDMMYY")] })

            if date.isSame(date.clone().startOf('month'),'day') and !month.start_date
              month.start_date = date.clone()

            date.add(1, 'day')
            
          month.weeks.push(week)

        months.push(month)
        cur_month.add(1, 'month')

      $scope.months = months

      if $scope.selected_date?
        $scope.selectMonthNumber($scope.selected_date.month())
      $scope.selected_month = $scope.selected_month or $scope.months[0]


    $scope.selectMonth = (month) ->
      $scope.selected_month = month

      # select the first day in the month that has some events, but only if we're in summary mode
      if $scope.mode is 0
        for week in month.weeks
          for day in week.days
            if (day.data && day.data.spaces > 0) and (day.date.isSame(month.start_date, 'day') or day.date.isAfter(month.start_date, 'day')) 
              $scope.showDate(day.date) 
              return


    $scope.selectMonthNumber = (month) ->
      return if $scope.selected_month && $scope.selected_month.start_date.month() == month

      for m in $scope.months
        $scope.selectMonth(m) if m.start_date.month() == month
      true


    $scope.add = (value) ->
      for month, index in $scope.months
        if $scope.selected_month is month and $scope.months[index + value]
          $scope.selectMonth($scope.months[index + value])
          return true
      return false


    $scope.subtract = (value) ->
      $scope.add(-value)


    $scope.setMonth = (index) ->
      $scope.selectMonth($scope.months[index]) if $scope.months[index]


angular.module('BB.Directives').directive 'bbSlick', ($rootScope, FormDataStoreService) ->
  restrict: 'A'
  replace: false
  scope : false
  require : '^bbMonthPicker'
  link : (scope, element, attrs) ->

    slider = $(element)

    slider.on 'afterChange', (event, slick, currentSlide, nextSlide) ->
      scope.setMonth(currentSlide)
      scope.$apply()