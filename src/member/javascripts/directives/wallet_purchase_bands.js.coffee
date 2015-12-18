angular.module("BB.Directives").directive "bbWalletPurchaseBands", ($rootScope) ->
  scope: true
  restrict: "AE"
  templateUrl: "wallet_purchase_bands.html"
  controller: "Wallet"
  require: '^?bbWallet'
  link: (scope, attr, elem, ctrl) ->

    $rootScope.connection_started.then () ->
      if ctrl
        deregisterWatch = scope.$watch 'wallet', () ->
          if scope.wallet
            scope.getWalletPurchaseBandsForWallet(scope.wallet)
            deregisterWatch()
      else 
        scope.getWalletForMember(scope.member).then () ->
          scope.getWalletPurchaseBandsForWallet(scope.wallet)
