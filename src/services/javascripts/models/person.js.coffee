'use strict'

###**
* @ngdoc service
* @name BB.Models:AdminPerson
*
* @description
* Representation of an Person Object
*
* @property {integer} id Person id
* @property {string} name Person name
* @property {boolean} deleted Verify if person is deleted or not
* @property {boolean} disabled Verify if person is disabled or not
* @property {integer} order The person order
####

angular.module('BB.Models').factory "AdminPersonModel", ($q,
  AdminPersonService, BBModel, BaseModel, PersonModel) ->

  class Admin_Person extends PersonModel

    constructor: (data) ->
      super(data)

    ###**
    * @ngdoc method
    * @name setAttendance
    * @methodOf BB.Models:AdminPerson
    * @param {string} status The status of attendance
    * @param {string} duration The estimated duration
    * @description
    * Set attendance in according of the status parameter
    *
    * @returns {Promise} Returns a promise that rezolve the attendance
    ###
    setAttendance: (status, duration) ->
      defer = $q.defer()
      @$put('attendance', {}, {status: status, estimated_duration: duration}).then  (p) =>
        @updateModel(p)
        defer.resolve(@)
      , (err) =>
        defer.reject(err)
      defer.promise

    ###**
    * @ngdoc method
    * @name finishServing
    * @methodOf BB.Models:AdminPerson
    * @description
    * Finish serving
    *
    * @returns {Promise} Returns a promise that rezolve the finish serving
    ###
    finishServing: () ->
      defer = $q.defer()
      if @$has('finish_serving')
        @$flush('self')
        @$post('finish_serving').then (q) =>
          @$get('self').then (p) => @updateModel(p)
          @serving = null
          defer.resolve(q)
        , (err) =>
          defer.reject(err)
      else
        defer.reject('finish_serving link not available')
      defer.promise

    ###**
    * @ngdoc method
    * @name isAvailable
    * @methodOf BB.Models:AdminPerson
    * @param {date=} start The start date format of the availability schedule
    * @param {date=} end The end date format of the availability schedule
    * @description
    * Look up a schedule for a time range to see if this available.
    *
    * @returns {string} Returns yes if schedule is available or not.
    ###
    # look up a schedule for a time range to see if this available
    # currently just checks the date - but chould really check the time too
    isAvailable: (start, end) ->
      str = start.format("YYYY-MM-DD") + "-" + end.format("YYYY-MM-DD")
      @availability ||= {}

      return @availability[str] == "Yes" if @availability[str]
      @availability[str] = "-"

      if @$has('schedule')
        @$get('schedule', {start_date: start.format("YYYY-MM-DD"), end_date: end.format("YYYY-MM-DD")}).then (sched) =>
          @availability[str] = "No"
          if sched && sched.dates && sched.dates[start.format("YYYY-MM-DD")] && sched.dates[start.format("YYYY-MM-DD")] != "None"
            @availability[str] = "Yes"
      else
        @availability[str] = "Yes"

      return @availability[str] == "Yes"

    ###**
    * @ngdoc method
    * @name startServing
    * @methodOf BB.Models:AdminPerson
    * @param {string=} queuer The queuer of the company.
    * @description
    * Start serving in according of the queuer parameter
    *
    * @returns {Promise} Returns a promise that rezolve the start serving link
    ###
    startServing: (queuer) ->
      defer = $q.defer()
      if @$has('start_serving')
        @$flush('self')
        params =
          queuer_id: if queuer then queuer.id else null
        @$post('start_serving', params).then (q) =>
          @$get('self').then (p) => @updateModel(p)
          @serving = q
          defer.resolve(q)
        , (err) =>
          defer.reject(err)
      else
        defer.reject('start_serving link not available')
      defer.promise

    ###**
    * @ngdoc method
    * @name getQueuers
    * @methodOf BB.Models:AdminPerson
    * @description
    * Get the queuers
    *
    * @returns {Promise} Returns a promise that rezolve the queuer links
    ###
    getQueuers: () ->
      defer = $q.defer()
      if @$has('queuers')
        @$flush('queuers')
        @$get('queuers').then (collection) =>
          collection.$get('queuers').then (queuers) =>
            models = (new BBModel.Admin.Queuer(q) for q in queuers)
            @queuers = models
            defer.resolve(models)
          , (err) =>
            defer.reject(err)
        , (err) =>
          defer.reject(err)
      else
        defer.reject('queuers link not available')
      defer.promise

    ###**
    * @ngdoc method
    * @name getPostData
    * @methodOf BB.Models:AdminPerson
    * @description
    * Get post data
    *
    * @returns {array} Returns data
    ###
    getPostData: () ->
      data = {}
      data.id = @id
      data.name = @name
      data.extra = @extra
      data.description = @description
      data

    ###**
    * @ngdoc method
    * @name update
    * @methodOf BB.Models:AdminPerson
    * @param {object} data The company data
    * @description
    * Update the data in according of the data parameter
    *
    * @returns {array} Returns the updated array
    ###
    $update: (data) ->
      data ||= @getPostData()
      @$put('self', {}, data).then (res) =>
        @constructor(res)

    @$query: (params) ->
      AdminPersonService.query(params)

    @$block: (company, person, data) ->
      AdminPersonService.block(company, person, data)

    @$signup: (user, data) ->
      AdminPersonService.signup(user, data)

    $refetch: () ->
      defer = $q.defer()
      @$flush('self')
      @$get('self').then (res) =>
        @constructor(res)
        defer.resolve(@)
      , (err) ->
        defer.reject(err)
      defer.promise