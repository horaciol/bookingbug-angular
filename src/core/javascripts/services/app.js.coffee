'use strict'

angular.module('BB.Services').factory 'AppService', ($uibModalStack) ->

	booking_move = null

	isModalOpen: ->
		!!$uibModalStack.getTop()
