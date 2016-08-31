angular.module("BB.Directives").directive "bbWalletPayment", ($sce, $rootScope,
  $window, $location, SettingsService, AlertService, LoadingService) ->

  restrict: 'A'
  controller: 'Wallet'
  scope: true
  replace: true
  require: '^?bbWallet'
  link: (scope, element, attrs, ctrl) ->

    loader = LoadingService.$loader(scope)

    one_pound = 100
    scope.wallet_payment_options = scope.$eval(attrs.bbWalletPayment) or {}
    scope.member = scope.$eval(attrs.member)
    scope.member ||= $rootScope.member if $rootScope.member
    scope.member ||= scope.wallet_payment_options.member if scope.wallet_payment_options.member
    scope.amount_increment = scope.wallet_payment_options.amount_increment or one_pound

    getHost = (url) ->
      a = document.createElement('a')
      a.href = url
      a['protocol'] + '//' +a['host']


    sendLoadEvent = (element, origin, scope) ->
      referrer = $location.protocol() + "://" + $location.host()
      if $location.port()
        referrer += ":" + $location.port()

      custom_stylesheet = if scope.wallet_payment_options.custom_stylesheet then scope.wallet_payment_options.custom_stylesheet else null
      custom_partial_url = if scope.bb and scope.bb.custom_partial_url then scope.bb.custom_partial_url else null

      payload = JSON.stringify({
        'type': 'load',
        'message': referrer,
        'custom_partial_url': custom_partial_url,
        'custom_stylesheet' : custom_stylesheet,
        'scroll_offset'     : SettingsService.getScrollOffset()
      })
      element.find('iframe')[0].contentWindow.postMessage(payload, origin)


    calculateAmount = () ->
      # if this is a basket topup, use either the amount due or the min topup amount, whichever is greatest

      if scope.wallet_payment_options.basket_topup

        amount_due = scope.bb.basket.dueTotal() - scope.wallet.amount

        if amount_due > scope.wallet.min_amount
          scope.amount = Math.ceil(amount_due / scope.amount_increment ) * scope.amount_increment
        else
          scope.amount = scope.wallet.min_amount

        scope.min_amount = scope.amount

      else if scope.wallet.min_amount
        scope.amount     = if scope.wallet_payment_options.amount and scope.wallet_payment_options.amount > scope.wallet.min_amount then scope.wallet_payment_options.amount else scope.wallet.min_amount
        scope.min_amount = scope.wallet.min_amount
      else
        scope.min_amount = 0
        scope.amount = scope.wallet_payment_options.amount if scope.wallet_payment_options.amount


    # wait for wallet to be loaded by bbWallet or by self
    $rootScope.connection_started.then () ->
      if ctrl
        deregisterWatch = scope.$watch 'wallet', () ->
          if scope.wallet
            calculateAmount()
            deregisterWatch()
      else
        scope.getWalletForMember(scope.member).then () ->
          calculateAmount()


    # listen to when the wallet is updated
    scope.$on 'wallet:updated', (event, wallet, band = null) ->

      # load iframe using payment link
      if wallet.$has('new_payment')
        loader.notLoaded()
        if band
          scope.amount = band.actual_amount
        scope.wallet_payment_url = $sce.trustAsResourceUrl(wallet.$href("new_payment"))
        scope.show_payment_iframe = true
        element.find('iframe').bind 'load', (event) =>
          url = scope.wallet_payment_url if scope.wallet_payment_url
          origin = getHost(url)
          sendLoadEvent(element, origin, scope)
          scope.$apply ->
            loader.setLoaded()


    # register iframe message listener
    $window.addEventListener 'message', (event) =>
      if angular.isObject(event.data)
        data = event.data
      else if not event.data.match(/iFrameSizer/)
        data = JSON.parse event.data
      scope.$apply =>
        if data
          switch data.type
            when "submitting"
              loader.notLoaded()
            when "error"
              $rootScope.$broadcast "wallet:topup_failed"
              loader.notLoaded()
              # reload the payment iframe
              document.getElementsByTagName("iframe")[0].src += ''
              AlertService.raise('PAYMENT_FAILED')
            when "payment_complete", "wallet_payment_complete", "basket_wallet_payment_complete"
              scope.show_payment_iframe = false
              if scope.wallet_payment_options.basket_topup
                scope.basketWalletPaymentDone()
              else
                scope.walletPaymentDone()
    , false

