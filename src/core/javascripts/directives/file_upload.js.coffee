'use strict'

###**
* @ngdoc directive
* @name BB.Directives:bbFileUpload
* @restrict AE
* @scope true
*
* @description
* File upload
*
* @example
  <example>
    <div
      bb-file-upload
      item="item"
      max-size="100KB"
      accept="application/pdf,application/msword,image/*">
    </div>
  </example>
###

angular.module('BB.Directives').directive 'bbFileUpload', () ->
  restrict: 'A'
  replace: false
  scope: {
    accept: '@',
    maxSize: '@',
    item: '='
  }
  controller : 'FileUpload',
  templateUrl: 'file_upload.html'

angular.module('BB.Controllers').controller 'FileUpload', ($scope, Upload) ->

  $scope.controller = "public.controllers.FileUpload"

  ###**
  * @ngdoc method
  * @name uploadFile
  * @methodOf BB.Directives:bbItemDetails
  * @description
  * Upload a file
  * For more information see https://github.com/danialfarid/ng-file-upload
  * To use this module:
  *
  * @param {object} item basket item
  * @param {object} file uploaded file
  * @param {number} existing attachment id
  * @param {array} errFiles errors array
  ###
  $scope.uploadFile = (item, file, err_files, existing) ->
    $scope.err_file = err_files and err_files[0]
    $scope.show_error = false

    if file
      $scope.my_file = file
      if existing  then att_id = existing else att_id = null

      method = "POST"
      method = "PUT" if att_id
      url = item.$href('add_attachment')

      onSuccess = (response) ->
        file.result = response.data
        item.attachment = response.data
        item.attachment_id = response.data.id
        file.progress = 100

      onError = (response) ->
        $scope.show_error = true
        file.progress = 100

      onProgress = (evt) ->
        file.progress = Math.min(100, parseInt(99.0 * evt.loaded / evt.total))

      file.upload = Upload.upload(
        url: url,
        method: method
        data: {attachment_id: att_id},
        file: file
      )

      file.upload.then onSuccess, onError, onProgress

