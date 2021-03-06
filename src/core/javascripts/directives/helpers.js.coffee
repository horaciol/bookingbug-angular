app = angular.module 'BB.Directives'



app.directive 'ngConfirmClick', () ->
  link: (scope, element, attr) ->
    msg = attr.ngConfirmClick || "Are you sure?"
    clickAction = attr.ngConfirmedClick
    element.bind 'click', (event) =>
      if window.confirm(msg)
        scope.$eval(clickAction)



app.directive 'ngValidInclude', ($compile) ->
    link: (scope, element, attr) ->
      scope[attr.watchValue].then (logged) =>
        element.attr('ng-include', attr.ngValidInclude)
        element.attr('ng-valid-include',null)
        $compile(element)(scope)



app.directive 'ngDelayed',  ($compile) ->
    link: (scope, element, attr) ->
      scope[attr.ngDelayedWatch].then (logged) =>
        element.attr(attr.ngDelayed, attr.ngDelayedValue)
        element.attr('ng-delayed-value',null)
        element.attr('ng-delayed-watch',null)
        element.attr('ng-delayed',null)
        $compile(element)(scope)
        if attr.ngDelayedReady
          scope[attr.ngDelayedReady].resolve(true)



app.directive 'ngInitial', ->
    restrict: 'A',
    controller: [
      '$scope', '$element', '$attrs', '$parse', ($scope, $element, $attrs, $parse) ->
        val = $attrs.ngInitial || $attrs.value
        getter = $parse($attrs.ngModel)
        setter = getter.assign
        if val == "true"
          val = true
        else if val == "false"
          val = false
        setter($scope, val)
    ]



app.directive 'bbPrintPage', ($window, $timeout) ->
  restrict: 'A',
  link:(scope, element, attr) ->
    if attr.bbPrintPage
      scope.$watch attr.bbPrintPage, (newVal, oldVal) =>
        $timeout(->
          $window.print()
        3000)



app.directive 'bbInclude', ($compile, $rootScope) ->
  link: (scope, element, attr) ->
    track_page = if attr.bbTrackPage? then true else false
    scope.$watch 'bb.path_setup', (newval, oldval) =>
      if newval
        element.attr('ng-include', "'" + scope.getPartial(attr.bbInclude) + "'")
        element.attr('bb-include',null)
        $compile(element)(scope)
        $rootScope.$broadcast "page:loaded", attr.bbInclude if track_page



# Form directive to allow users to specify if they want the form to raise alerts when
# there is invalid input.
app.directive 'bbRaiseAlertWhenInvalid', ($compile) ->
  require: '^form'
  link: (scope, element, attr, ctrl) ->
    ctrl.raise_alerts = true

    options = scope.$eval attr.bbRaiseAlertWhenInvalid
    ctrl.alert = options.alert if options and options.alert



app.directive 'bbHeader', ($compile) ->
    link: (scope, element, attr) ->
      scope.bb.waitForRoutes()
      scope.$watch 'bb.path_setup', (newval, oldval) =>
        if newval
          element.attr('ng-include', "'" + scope.getPartial(attr.bbHeader) + "'")
          element.attr('bb-header',null)
          $compile(element)(scope)



app.directive 'bbDate', () ->
  restrict: 'AE'
  scope: true
  link : (scope, element, attrs) ->

    track_service = attrs.bbTrackService?

    # set the date, first test if bbDate has been set, otherwise use the current item's
    # date. If neither are set, set the date as today
    if attrs.bbDate
     date = moment( scope.$eval( attrs.bbDate ) )
    else if scope.bb && scope.bb.current_item && scope.bb.current_item.date
      date = scope.bb.current_item.date.date
    else
      date = moment()

    # if we've been instructed to track the service, set the min/max date
     if track_service && scope.bb.current_item && scope.bb.current_item.service
      scope.min_date = scope.bb.current_item.service.min_advance_datetime
      scope.max_date = scope.bb.current_item.service.max_advance_datetime

    # broadcast a dateChanged event to ensure listeners are updated
    scope.$broadcast('dateChanged', moment(date))

    # bb_date
    scope.bb_date = {

      date: date
      js_date: date.toDate()

      addDays: (type, amount) ->
        @date = moment(@date).add(amount, type)
        @js_date = @date.toDate()
        scope.$broadcast('dateChanged', moment(@date))

      subtractDays: (type, amount) ->
        @addDays(type, -amount)

      setDate: (date) ->
        @date    = date
        @js_date = date.toDate()
        scope.$broadcast('dateChanged', moment(@date))
    }

    # watch the current_item for updates
    scope.$on "currentItemUpdate", (event) ->

      # set the min/max date if a service has been set
      if scope.bb.current_item.service && track_service
        scope.min_date = scope.bb.current_item.service.min_advance_datetime
        scope.max_date = scope.bb.current_item.service.max_advance_datetime

        # if the bb_date is before/after the min/max date, move it to the min/max date
        scope.bb_date.setDate(scope.min_date.clone()) if scope.bb_date.date.isBefore(scope.min_date, 'day')
        scope.bb_date.setDate(scope.max_date.clone()) if scope.bb_date.date.isAfter(scope.max_date, 'day')

    # if the js_date has changed, update the moment date representation
    # and broadcast an update
    scope.$watch 'bb_date.js_date', (newval, oldval) ->
      ndate = moment(newval)
      if !scope.bb_date.date.isSame(ndate)
        scope.bb_date.date = ndate
        scope.$broadcast('dateChanged', moment(ndate)) if moment(ndate).isValid()



app.directive 'bbDebounce', ($timeout) ->
  restrict: 'A',
  link: (scope, element, attrs) ->
    delay = 400
    delay = attrs.bbDebounce if attrs.bbDebounce

    element.bind 'click', () =>
      $timeout () =>
        element.attr('disabled', true)
      , 0
      $timeout () =>
        element.attr('disabled', false)
      , delay



# bbLocalNumber
# Adds a formatter that prepends the model value with an appropriate prefix. This is useful for
# nicely formatting numbers where the prefix has been stripped, i.e. '7875123456'
# Adds a parser to store the user entered value which is then used in the formatter
app.directive 'bbLocalNumber', ($filter) ->
  restrict: 'A',
  scope: {},
  require: 'ngModel',
  link: (scope, element, attrs, ctrl) ->

    scope.userinput_mobile = null

    storeNumber = (value) ->
      if value
        scope.userinput_mobile = value
      return value

    prettyifyNumber = (value) ->
      if scope.userinput_mobile
        value = scope.userinput_mobile
      else
        return $filter('local_phone_number')(value)

    ctrl.$parsers.push(storeNumber)
    ctrl.$formatters.push(prettyifyNumber)


# bbPadWithZeros
# Adds a formatter that prepends the model value with the specified number of zeros
app.directive 'bbPadWithZeros', () ->
  restrict: 'A',
  require: 'ngModel',
  link: (scope, element, attrs, ctrl) ->

    options  = scope.$eval(attrs.bbPadWithZeros) or {}
    how_many = options.how_many or 2

    padNumber = (value) ->
      value = String(value)
      if value and value.length < how_many
        padding = ""
        for index in [1..how_many-value.length]
          padding += "0"
         value = padding.concat(value)
      return value

    ctrl.$formatters.push(padNumber)


# bbFormResettable
# Adds field clearing behaviour to forms.
app.directive 'bbFormResettable', ($parse) ->
  restrict: 'A'
  controller: ($scope, $element, $attrs) ->
    $scope.inputs = []

    $scope.resetForm = (options) ->
      $scope[$attrs.name].submitted = false if options and options.clear_submitted
      for input in $scope.inputs
        input.getter.assign($scope, null)
        input.controller.$setPristine()

    registerInput: (input, ctrl) ->
      getter = $parse input
      $scope.inputs.push({getter: getter, controller: ctrl})



# bbResettable
# Registers inputs with the bbFormResettable controller allowing them to be cleared
app.directive 'bbResettable', () ->
  restrict: 'A',
  require: ['ngModel', '^bbFormResettable'],
  link: (scope, element, attrs, ctrls) ->
    ngModelCtrl        = ctrls[0]
    formResettableCtrl = ctrls[1]
    formResettableCtrl.registerInput(attrs.ngModel, ngModelCtrl)



# bbDateSplit
app.directive 'bbDateSplit', ($parse) ->
  restrict: 'A'
  require: ['ngModel']
  link: (scope, element, attrs, ctrls) ->

    ngModel = ctrls[0]

    question = scope.$eval attrs.bbDateSplit

    question.date = {
      day:   null
      month: null
      year:  null
      date:  null

      joinDate:  ->
        if @day && @month && @year
          date_string = @day + '/' + @month + '/' + @year
          @date = moment(date_string, "DD/MM/YYYY")
          date_string = @date.toISODate()

          ngModel.$setViewValue(date_string)
          ngModel.$render()

      splitDate: (date) ->
        if date && date.isValid()
          @day   = date.date()
          @month = date.month() + 1
          @year  = date.year()
          @date  = date
    }

    # split the date if it's already set
    question.date.splitDate(moment(question.answer)) if question.answer
    question.date.splitDate(moment(ngModel.$viewValue)) if ngModel.$viewValue

    # watch self to split date when it changes
    # scope.$watch attrs.ngModel, (newval) ->
    #   if newval
    #     new_date = moment(newval)
    #     if !new_date.isSame(question.date)
    #        question.date.splitDate(new_date)


# bbCommPref
app.directive 'bbCommPref', () ->
  restrict: 'A'
  require: ['ngModel']
  link: (scope, element, attrs, ctrls) ->

    ng_model_ctrl = ctrls[0]

    # get the default communication preference
    comm_pref = scope.$eval(attrs.bbCommPref) or false

    # check if it's already been set
    if scope.bb.current_item.settings.send_email_followup? and scope.bb.current_item.settings.send_sms_followup?
      comm_pref = scope.bb.current_item.settings.send_email_followup
    else
      # set to the default
      scope.bb.current_item.settings.send_email_followup = comm_pref
      scope.bb.current_item.settings.send_sms_followup   = comm_pref

    # update the model
    ng_model_ctrl.$setViewValue(comm_pref)

    # register a parser to handle model changes
    parser = (value) ->
      scope.bb.current_item.settings.send_email_followup = value
      scope.bb.current_item.settings.send_sms_followup   = value
      value

    ng_model_ctrl.$parsers.push parser


# bbCountTicketTypes
# returns the number of tickets selected, grouped by name
app.directive 'bbCountTicketTypes', ($rootScope) ->
  restrict: 'A'
  scope: false
  link: (scope, element, attrs) ->


    $rootScope.connection_started.then () ->
      countTicketTypes()


    scope.$on "basket:updated", (event, basket) ->
      countTicketTypes()


    countTicketTypes = (items) ->

      items = scope.bb.basket.timeItems()

      counts = []
      for item in items
        if item.tickets
          if counts[item.tickets.name] then counts[item.tickets.name] += item.tickets.qty else counts[item.tickets.name] = item.tickets.qty
          item.number = counts[item.tickets.name]
      scope.counts = counts


# bbCapitaliseFirstLetter
app.directive 'bbCapitaliseFirstLetter', () ->
  restrict: 'A'
  require: ['ngModel']
  link: (scope, element, attrs, ctrls) ->
    ngModel = ctrls[0]

    scope.$watch attrs.ngModel, (newval, oldval) ->
      if newval
        string = scope.$eval attrs.ngModel
        string = string.charAt(0).toUpperCase() + string.slice(1)
        ngModel.$setViewValue(string)
        ngModel.$render()
        return



app.directive 'bbApiUrl', ($rootScope, $compile, $sniffer, $timeout, $window, $location) ->
  restrict: 'A'
  scope:
    'apiUrl': '@bbApiUrl'
  compile: (tElem, tAttrs) ->
    pre: (scope, element, attrs) ->
      $rootScope.bb ||= {}
      $rootScope.bb.api_url = scope.apiUrl
      url = document.createElement('a')
      url.href = scope.apiUrl

      if ($sniffer.msie and $sniffer.msie <= 9) or ($sniffer.webkit and $sniffer.webkit < 537)
        unless url.host == '' || url.host == $location.host() || url.host == "#{$location.host()}:#{$location.port()}"
          if url.protocol[url.protocol.length - 1] == ':'
            src = "#{url.protocol}//#{url.host}/ClientProxy.html"
          else
            src = "#{url.protocol}://#{url.host}/ClientProxy.html"
          $rootScope.iframe_proxy_ready = false

          $compile("<iframe id='ieapiframefix' name='" + url.hostname + "' src='#{src}' style='visibility:false;display:none;'></iframe>") scope, (cloned, scope) =>
            cloned.bind "load", ->
              $rootScope.iframe_proxy_ready = true
              $rootScope.$broadcast('iframe_proxy_ready', {iframe_proxy_ready: true})
            element.append(cloned)


app.directive 'bbPriceFilter', (PathSvc) ->
  restrict: 'AE'
  replace: true
  scope: false
  require: '^?bbServices'
  templateUrl : (element, attrs) ->
    PathSvc.directivePartial "_price_filter"
  controller : ($scope, $attrs) ->
    $scope.$watch 'items', (new_val, old_val) ->
      setPricefilter new_val if new_val

    setPricefilter = (items) ->
      $scope.price_array = _.uniq _.map items, (item) ->
        return item.price / 100 or 0
      $scope.price_array.sort (a, b) ->
        return a - b
      suitable_max()

    suitable_max = () ->
      top_number = _.last($scope.price_array)
      max_number = switch
        when top_number < 1 then 0
        when top_number < 11 then 10
        when top_number < 51 then 50
        when top_number < 101 then 100
        when top_number < 1000 then ( Math.ceil( top_number / 100 ) ) * 100
      min_number = 0
      $scope.price_options = {
        min: min_number
        max: max_number
      }
      $scope.filters.price = {min: min_number, max: max_number}

    $scope.$watch 'filters.price.min', (new_val, old_val) ->
      $scope.filterChanged() if new_val != old_val

    $scope.$watch 'filters.price.max', (new_val, old_val) ->
      $scope.filterChanged() if new_val != old_val


angular.module('BB.Directives').directive 'bbBookingExport', () ->
  restrict: 'AE'
  scope: {
    booking: '=bbBookingExport'
  }
  templateUrl: '_popout_export_booking.html'
  link: (scope, el, attrs) ->
    scope.$watch 'booking', (new_val, old_val) ->
      setHTML() if new_val
    setHTML = () ->
      scope.content = 
        "<div class='text-center'><a href='#{scope.booking.webcalLink()}'><img src='images/outlook.png' alt='outlook calendar icon' height='30' width='30' /><div class='clearfix'></div><span>Outlook</span></a></div><p></p>" +
        "<div class='text-center'><a href='#{scope.booking.gcalLink()}'><img src='images/google.png' alt='google calendar icon' height='30' width='30' /><div class='clearfix'></div><span>Google</span></a></div><p></p>" +
        "<div class='text-center'><a href='#{scope.booking.icalLink()}'><img src='images/ical.png' alt='ical calendar icon' height='30' width='30' /><div class='clearfix'></div><span>iCal</span></a></div>"

angular.module('BB.Directives').directive 'bbDynamicFooter', ($timeout, $bbug) ->
  (scope, el, attrs) ->

    scope.$on "page:loaded", ->
      $bbug('.content').css('height', 'auto')

    scope.$watch -> $bbug('.content')[0].scrollHeight,
    (new_val, old_val) ->
      if new_val != old_val
        scope.setContentHeight()

    scope.setContentHeight = ->
      $bbug('.content').css('height', 'auto')
      content_height = $bbug('.content')[0].scrollHeight
      min_content_height = $bbug(window).innerHeight() - $bbug('.content').offset().top - $bbug('.footer').height()
      if content_height < min_content_height
        $bbug('.content').css('height', min_content_height + 'px')

    $bbug(window).on 'resize', ->
      scope.setContentHeight()

###**
* @ngdoc directive
* @name BB.Directives:bbBlurOnReturn
* @restrict A
* @scope true
*
* @description
* Removes focus from an input[type=text] element when return key is pressed
* @example
* <input type='text' bb-blur-on-return></div>
####
angular.module('BB.Directives').directive('bbBlurOnReturn', ($timeout) ->
  restrict: 'A'
  require: 'ngModel'
  link: (scope, el, attrs) ->
    el.keydown((e) ->
      key = e.which or e.keyCode
      if key == 13 or key == '13'
        $timeout( () ->
          e.target.blur() if e.target
        , 10
        )
    )
)
