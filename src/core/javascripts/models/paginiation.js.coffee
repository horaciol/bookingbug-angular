###**
* @ngdoc service
* @name BB.Models:Service
*
* @description
* Representation of an Pagination Object
*
* @property {integer} current_page The current page
* @property {integer} page_size The number of items to show on each page
* @property {integer} request_page_size The request page size. Defaults to page_size when not provided. This value must be a multiple of the page_size.
* @property {integer} max_size Limit number for pagination size
* @property {integer} num_pages The total number of pages
* @property {integer} num_items The total number of items paginated
* @property {integer} items The items to be paginated
* @property {String} summary Summary of current page, i.e. 1 - 10 of 16
* @example
*  <example module="BB">
*    <file name="index.html">
*   <div bb-api-url='https://uk.bookingbug.com'>
*   <div bb-widget='{company_id:21}'>
*     <div bb-pagination-example>
*        <ul>
*          <li ng-repeat="item in pagination.items | startFrom: (pagination.current_page - 1) * pagination.page_size | limitTo: pagination.page_size | orderBy: sort_by track by $index">
*        </ul>
*     </div>
*     </div>
*     </div>
*   </file>
*   <file name="script.js">
*  angular.module('BB').directive('bbPaginationExample', function() {
*    return {
*      restrict: 'AE',
*      controller: function(BBModel, DataService) {
*       $scope.pagination = new BBModel.Pagination({
*         page_size: 10,
*         max_size: 5,
*         request_page_size: 10
*       });
*       $scope.getData = function(params, options) {
*         if (options == null) {
*           options = {};
*         }
*          $scope.params = {
*            per_page: $scope.pagination.request_page_size,
*           page: params.page || 1
*         };
*         return DataService.query($scope.params).then(function(result) {
*            if (options.add) {
*              return $scope.pagination.add(params.page, result.items);
*           } else {
*             return $scope.pagination.initialise(result.items, result.total_entries);
*           }
*         });
*       };
*        return $scope.pageChanged = function() {
*         var items_present, page_to_load, ref;
*         ref = $scope.pagination.update(), items_present = ref[0], page_to_load = ref[1];
*         if (!items_present) {
*            $scope.params.page = page_to_load;
*            return $scope.getData($scope.params, {
*              add: true
*           });
*         }
*       };
*     }
*   };
* });
*       </file>
*  </example>
*
###
angular.module('BB.Models').factory "PaginationModel", () ->

  class Pagination

    ###**
    * @ngdoc method
    * @name constructor
    * @methodOf BB.Models:Service
    * @description
    * Constructor method
    *
    * @param {object} Options hash used to set page_size and max_size
    ###
    constructor: (options) ->
      @current_page = 1
      @page_size = options.page_size or 10
      @request_page_size = options.request_page_size or @page_size
      @max_size = options.max_size or 5
      @num_pages = null
      @num_items = null
      @items = []


    ###**
    * @ngdoc method
    * @name initialise
    * @methodOf BB.Models:Service
    * @description
    * Initiailises the pagination instance when first page has been retrieved
    *
    * @param {array} The first page of items returned by the API
    * @param {integer} The total number of items
    ###
    initialise: (items, total_items) ->
      @current_page = 1
      @items = items or []
      @num_items = total_items or 0
      @update()


    ###**
    * @ngdoc method
    * @name update
    * @methodOf BB.Models:Service
    * @description
    * Updates the pagination summary when the page changes
    *
    * @returns {boolean} Flag to indicate if items in current page are present
    * @returns {integer} The page to load based on
    ###
    update: () ->
      start = ((@current_page - 1) * @page_size) + 1
      end   = @current_page * @page_size
      end = if @num_items < end then @num_items else end

      loadedItems = @max_size * @page_size * (Math.floor(@num_items / (@max_size * @page_size)))

      total = if start < loadedItems then loadedItems + "+" else @num_items

      @summary = "#{start} - #{end} of #{total}"

      page_to_load = Math.ceil((@current_page * @page_size) / @request_page_size)

      return [@items[start-1]?, page_to_load]


    ###**
    * @ngdoc method
    * @name add
    * @methodOf BB.Models:Service
    * @description
    * Appends additional items (from subsequent data requests) to items array
    *
    * @param {integer} The page number of the data request
    * @param {array} The new items
    *
    ###
    add: (request_page, new_items) ->
      start = (request_page - 1) * @request_page_size
      for item, index in new_items
        @items[start + index] = item

