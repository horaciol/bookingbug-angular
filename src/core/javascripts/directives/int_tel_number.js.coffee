app = angular.module 'BB.Directives'

# International Telephone Input directive
# http://www.tooorangey.co.uk/posts/that-international-telephone-input-umbraco-7-property-editor/
# https://github.com/Bluefieldscom/intl-tel-input
app.directive "bbIntTelNumber", ($parse) ->
  restrict: "A"
  require: "ngModel"

  link: (scope, element, attrs, ctrl) ->

    options = scope.$eval attrs.intTelNumber

    # apply plugin
    element.intlTelInput options

    convertNumber = (value) ->

      str = ""
      if scope.$eval(attrs.ngModel + '_prefix')?
        str += ("+" + scope.$eval(attrs.ngModel + '_prefix') + " ")
      if scope.$eval(attrs.ngModel)?
        str += scope.$eval(attrs.ngModel)
      if str[0] == "+"
        element.intlTelInput("setNumber", "+#{scope.$eval(attrs.ngModel + '_prefix')} #{scope.$eval(attrs.ngModel)}")
        ctrl.$setValidity "pattern", true
      str


    parse = (value) ->
      prefix = element.intlTelInput("getSelectedCountryData").dialCode
      getter = $parse(attrs.ngModel + '_prefix')
      getter.assign(scope, prefix)
      value

    ctrl.$formatters.push format
    ctrl.$parsers.push parse