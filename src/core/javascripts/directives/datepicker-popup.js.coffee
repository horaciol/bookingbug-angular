'use strict'


# replaces the date parse method for the angular-ui datepicker popup. the picker
# defaults to US style dates when typing a date into the picker input, so
# 05/09/2014 is translated as 9th May rather than the 5th September
angular.module('BB.Directives').directive 'bbDatepickerPopup', ($parse, $document, $timeout, $bbug)->
  ie8orLess = false
  # stop user typing in input field if using ie8 or less as the date gets a
  # little delyaed and outputs wrong date
  try
    ie8orLess = window.parseInt(/MSIE\s*(\d)/.exec(window.navigator.userAgent)[1])
  catch e
    ie8orLess = false

  restrict: 'A'
  #  set low priority as we want to make sure the 'datepickerPopup' directive
  #  runs first
  priority: -1
  require : 'ngModel'

  # this is the original effort at trying to allow the user to type the date in
  # to the input field. it works ok but there are a few bugs relative to setting
  # the ngmodel value and it then it dissapears during the digest loop
  link : (scope, element, attrs, ngModel) ->
    origDateParser = null
    data = element.controller('ngModel')
    if attrs.uibDatepickerPopup?
      format =
        date_us: "MM/dd/yyyy"
        date_uk: "dd/MM/yyyy"
      if scope.bb.company.country_code == "us"
        attrs.uibDatepickerPopup = format.date_us
      else
        attrs.uibDatepickerPopup = format.date_uk

    dateFormat = if attrs.bbDatepickerPopup then attrs.bbDatepickerPopup else 'DD/MM/YYYY'
    yearNow = moment(new Date()).year()
    getter = $parse attrs.ngModel
    timeRangeScope = scope

    # the date picker is sometimes in a nested controller so we need to find the
    # timerange scope as the 'selected_date' property is assigned directly to
    # the scope, which causes inheritance issues.
    getTimeRangeScope = (scope) ->
      if scope
        if scope.controller and scope.controller.indexOf('TimeRangeList') > 0
          timeRangeScope = scope
        else
          getTimeRangeScope scope.$parent
    getTimeRangeScope(scope)


    if ie8orLess
      $bbug(element).on 'keydown keyup keypress', (ev) ->
        ev.preventDefault()
        ev.stopPropagation()

    if ie8orLess or scope.display.xs
      $bbug(element).attr 'readonly', 'true'

    # the date picker doesn't support the typing in of dates very well, or
    # hiding the popup after typing a date.
    $bbug(element).on 'keydown', (e) ->
      if e.keyCode is 13
        replacementDateParser($bbug(e.target).val(), true)
        # hide popup
        $document.trigger('click')
        $bbug(element).blur()

    $bbug(element).on 'click', (e) ->
      e.preventDefault()
      e.stopPropagation()
      $timeout ->
        scope.opened = true
      ,

    # completely disable focus for the input, but only if input is readonly
    $bbug(element).on 'focus', () ->
      if($(@).attr("readonly"))
        @blur()

    # call the function which handles the date change
    # on-date-change="selectedDateChanged()"
    callDateHandler = (date) ->
      # something somewhere is removing the date value from the scope after the
      # date is set. so we watch digest and set it back if it gets removed.
      watch = scope.$watch getter, (newVal, oldVal) ->
        if !newVal
          getter.assign(timeRangeScope, date)

      # and then remove watcher after the digest has finished
      $timeout watch, 0

      isDate = _.isDate date
      if isDate
        getter.assign(timeRangeScope, date)
        ngModel.$setValidity('date', true)
        scope.$eval(attrs.onDateChange)

      return isDate


    replacementDateParser = (viewValue, returnKey) ->
      # if date user has selected a date from popup then update the picker
      if callDateHandler(viewValue)
        return viewValue

      if ie8orLess
        return viewValue

      mDate = moment(viewValue, dateFormat)

      if !mDate.isValid()
        mDate = moment(new Date())

      # the year date has to be in the four 'YYYY' format
      if /\/YY$/.test(dateFormat)
        dateFormat += 'YY'

      if mDate.year() is 0
        mDate.year(yearNow)

      # convert date to american format as that's what the picker works with.
      viewValue = mDate.format('MM/DD/YYYY')

      # test year format is not /0201, /0202 etc
      viewValue = viewValue.replace(/\/00/, '/20')
      if /\/02\d{2}$/.test(viewValue)
        return

      # user has typed in a date and pressed the return key. as the picker
      # doesn't support this kind of functionality we have to implement it.
      if returnKey
        if mDate.year().toString().length is 2
          mDate.year(mDate.year() + 2000)
        callDateHandler(mDate._d)
      else
        origDateParser.call(this, viewValue)

    # wait until the data object for the popup element has been initialised by
    # angular-ui and then override the $parser with our parse function
    # f = ->
    #   if _.isFunction data.$parsers[0]
    #     origDateParser = data.$parsers[0]
    #     data.$parsers[0] = replacementDateParser
    #     return
    #   else
    #     setTimeout f, 10
    # f()
