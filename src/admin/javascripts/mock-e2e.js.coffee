'use strict'

angular.module('BBAdminMockE2E', ['BBAdmin', 'ngMockE2E'])

angular.module('BBAdminMockE2E').run ($httpBackend) ->

  $httpBackend.whenPOST('http://www.bookingbug.com/api/v1/login/admin/123').respond (method, url, data) ->
    console.log 'login post'
    login =
      email: "tennis@example.com"
      auth_token: "PO_MZmDtEhU1BK6tkMNPjg"
      company_id: 123
      path: "http://www.bookingbug.com/api/v1"
      role: "owner"
      _embedded:
        members: [],
        administrators:[
          role: "owner"
          name: "Tom's Tennis"
          company_id: 123
          _links:
             self:
               href: "http://www.bookingbug.com/api/v1/admin/123/administrator/29774"
             company:
               href: "http://www.bookingbug.com/api/v1/admin/123/company"
             login:
               href: "http://www.bookingbug.com/api/v1/login/admin/123"
        ]
       _links:
         self:
           href: "http://www.bookingbug.com/api/v1/login/123"
         administrator:
           href: "http://www.bookingbug.com/api/v1/admin/123/administrator/29774"
           templated: true
    return [200, login, {}]

   company =
     id: 123
     name: "Tom's Tennis"
     currency_code: 'GBP'
     country_code: 'gb'
     timezone: 'Europe/London'
     _links:
       self:
         href: 'http://www.bookingbug.com/api/v1/company/123'
       new_person:
         href: 'http://www.bookingbug.com/api/v1/admin/123/people/new{?signup}'
         templated: true
       administrators:
         href: 'http://www.bookingbug.com/api/v1/admin/123/administrators'
       new_administrator:
         href: 'http://www.bookingbug.com/api/v1/admin/123/administrators/new'
       services:
         href: 'http://www.bookingbug.com/api/v1/admin/123/services'
       new_service:
         href: 'http://www.bookingbug.com/api/v1/admin/123/services/new'
   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/admin/123/company').respond(company)

   people =
     total_entries: 3
     _embedded:
       people: [
         {
           id: 1
           name: "John"
           type: "person"
           deleted: false
           disabled: false
           company_id: 123
           mobile: ""
           _links:
             self:
               href: "http://www.bookingbug.com/api/v1/admin/123/people/1"
             items:
               href: "http://www.bookingbug.com/api/v1/123/items?person_id=1"
           _embedded: {}
         }
         {
           id: 2
           name: "Mary"
           type: "person"
           email: "mary@example.com"
           deleted: false
           disabled: false
           company_id: 123
           mobile: ""
           _links:
             self:
               href: "http://www.bookingbug.com/api/v1/admin/123/people/2"
             items:
               href: "http://www.bookingbug.com/api/v1/123/items?person_id=2"
           _embedded: {}
         }
         {
           id: 3
           name: "Bob"
           type: "person"
           email: "bob@example.com"
           deleted: false
           disabled: false
           company_id: 123
           mobile: ""
           _links:
             self:
               href: "http://www.bookingbug.com/api/v1/admin/123/people/3"
             items:
               href: "http://www.bookingbug.com/api/v1/123/items?person_id=3"
           _embedded: {}
         }
       ]
     _links:
       self:
         href: "http://www.bookingbug.com/api/v1/admin/123/people"
       new:
         href: "http://www.bookingbug.com/api/v1/admin/123/people/new{?signup}"
         templated: true
   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/admin/123/people').respond(people)

   person_schema =
     form: [
       {'key':'name', type:'text', feedback:false},
       {'key':'email', type:'email', feedback:false},
       {key:'phone', type:'text', feedback:false},
       {type:'submit', title:'Save'}
     ]
     schema:
       properties:
         email:
           title: 'Email *'
           type: 'String'
         name:
           title: 'Name *'
           type: 'String'
         phone:
           title: 'Phone'
           type: 'String'
       required: ['name', 'email']
       title: 'Person'
       type: 'object'
   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/admin/123/people/new').respond () ->
     [200, person_schema, {}]

   $httpBackend.whenPOST('http://www.bookingbug.com/api/v1/admin/123/people').respond (method, url, data) ->
     console.log 'post person'
     console.log method
     console.log url
     console.log data
     [200, people.concat([data]), {}]

# Services

    services =
     total_entries: 3
     _embedded:
       services: [
         {
           id: 1
           name: "Data analysis"
           type: "service"
           deleted: false
           disabled: false
           company_id: 123
           _links:
             self:
               href: "http://www.bookingbug.com/api/v1/admin/123/services/1"
             edit:
               href: 'http://www.bookingbug.com/api/v1/admin/123/services/1/edit'
               templated: true
             items:
               href: "http://www.bookingbug.com/api/v1/123/items?service_id=1"
           _embedded: {}
         }
         {
           id: 2
           name: "Personal consultation"
           type: "service"
           deleted: false
           disabled: false
           company_id: 123
           _links:
             self:
               href: "http://www.bookingbug.com/api/v1/admin/123/services/2"
             edit:
               href: 'http://www.bookingbug.com/api/v1/admin/123/services/2/edit'
               templated: true
             items:
               href: "http://www.bookingbug.com/api/v1/123/items?service_id=2"
           _embedded: {}
         }
         {
           id: 3
           name: "Marketing strategy"
           type: "service"
           deleted: false
           disabled: false
           company_id: 123
           _links:
             self:
               href: "http://www.bookingbug.com/api/v1/admin/123/services/3"
             edit:
               href: 'http://www.bookingbug.com/api/v1/admin/123/services/3/edit'
               templated: true
             items:
               href: "http://www.bookingbug.com/api/v1/123/items?service_id=3"
           _embedded: {}
         }
       ]
     _links:
       self:
         href: "http://www.bookingbug.com/api/v1/admin/123/services"
       new:
         href: "http://www.bookingbug.com/api/v1/admin/123/services/new{?signup}"
         templated: true
   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/admin/123/services').respond(services)

   service_schema =
     form: [
       {'key':'name', type:'text', feedback:false},
       {type:'submit', title:'Save'}
     ]
     schema:
       properties:
         name:
           title: 'Name *'
           type: 'String'
       required: ['name']
       title: 'Service'
       type: 'object'
   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/admin/123/services/new').respond () ->
     [200, service_schema, {}]


   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/admin/123/services/1/edit').respond () ->
     [200, service_schema, {}]
   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/admin/123/services/2/edit').respond () ->
     [200, service_schema, {}]
   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/admin/123/services/3/edit').respond () ->
     [200, service_schema, {}]

   $httpBackend.whenPOST('http://www.bookingbug.com/api/v1/admin/123/services').respond (method, url, data) ->
     console.log 'post service'
     console.log method
     console.log url
     console.log data
     [200, services.concat([data]), {}]

# Administrators

   administrators =
     _embedded:
       administrators: [{
         name: "Dave"
         email: "dave@example.com"
         role: 'admin'
         company_id: 123
         company_name: "Tom's Tennis"
         _links:
           self:
             href: 'http://www.bookingbug.com/api/v1/admin/123/administrators/1'
           edit:
             href: 'http://www.bookingbug.com/api/v1/admin/123/administrators/1/edit'
           company:
             href: 'http://www.bookingbug.com/api/v1/admin/123/company'
           login:
             href: 'http://www.bookingbug.com/api/v1/login/admin/123'
       },{
         name: "Sue"
         email: "sue@example.com"
         role: 'owner'
         company_id: 123
         company_name: "Tom's Tennis"
         _links:
           self:
             href: 'http://www.bookingbug.com/api/v1/admin/123/administrators/2'
           edit:
             href: 'http://www.bookingbug.com/api/v1/admin/123/administrators/2/edit'
           company:
             href: 'http://www.bookingbug.com/api/v1/admin/123/company'
           login:
             href: 'http://www.bookingbug.com/api/v1/login/admin/123'
       }]
     _links:
       self:
         href: 'http://www.bookingbug.com/api/v1/admin/123/administrators'
       new:
         href: 'http://www.bookingbug.com/api/v1/admin/123/administrators/new'
         templated: true
   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/admin/123/administrators').respond(administrators)

   admin_schema =
     form: [{
       key: 'name'
       type: 'text'
       feedback: false
     },{
       key: 'email'
       type: 'text'
       feedback: false
     },{
       key: 'role'
       type: 'select'
       feedback: false
       titleMap:
         owner: 'Owner'
         admin: 'Admin'
         user: 'User'
     },{
       type: 'submit'
       title: 'Save'
     }]
     schema:
       properties:
         name:
           title: 'Name *'
           type: 'string'
         email:
           title: 'Email *'
           type: 'string'
         role:
           title: 'Role'
           type: 'string'
           enum: ['owner','admin','user','callcenter']
       required: ['name', 'email']
       title: 'Administrator'
       type: 'object'
   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/admin/123/administrators/new').respond () ->
     [200, admin_schema, {}]

   admin_schema =
     form: [{
       key: 'name'
       type: 'text'
       feedback: false
     },{
       key: 'role'
       type: 'select'
       feedback: false
       titleMap:
         owner: 'Owner'
         admin: 'Admin'
         user: 'User'
     },{
       type: 'submit'
       title: 'Save'
     }]
     schema:
       properties:
         name:
           title: 'Name *'
           type: 'string'
         role:
           title: 'Role'
           type: 'string'
           enum: ['owner','admin','user','callcenter']
       title: 'Administrator'
       type: 'object'
   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/admin/123/administrators/1/edit').respond () ->
     [200, admin_schema, {}]



  # Member

  $httpBackend.whenPOST('http://www.bookingbug.com/api/v1/login/member/123').respond (method, url, data) ->
    login =
      email: "smith@example.com"
      auth_token: "TO_4ZrDtEhU1BK6tkMNPj0"
      company_id: 123
      path: "http://www.bookingbug.com/api/v1"
      role: "member"
      _embedded:
        members: [
          first_name: "John"
          last_name: "Smith"
          email: "smith@example.com"
          client_type: "Member"
          address1: "Some street"
          address3: "Some town"
          id: 123456
          company_id: 123
          _links:
            self:
              href: "http://www.bookingbug.com/api/v1/123/members/123456{?embed}"
              templated: true
            bookings:
              href: "http://www.bookingbug.com/api/v1/123/members/123456/bookings{?start_date,end_date,include_cancelled,page,per_page}"
              templated: true
            company:
              href: "http://www.bookingbug.com/api/v1/company/123"
              templated: true
            edit_member:
              href: "http://www.bookingbug.com/api/v1/123/members/123456/edit"
              templated: true
            pre_paid_bookings:
              href: "http://www.bookingbug.com/api/v1/123/members/123456/pre_paid_bookings{?start_date,end_date,page,per_page}"
              templated: true
        ],
        administrators:[]
       _links:
         self:
           href: "http://www.bookingbug.com/api/v1/login/123"
         member:
           href: "http://www.bookingbug.com/api/v1/123/members/123456{?embed}"
           templated: true
    return [200, login, {}]

   member_schema =
     form: [
       {key:'first_name', type:'text', feedback:false},
       {key:'last_name', type:'text', feedback:false},
       {key:'email', type:'email', feedback:false},
       {key:'address1', type:'text', feedback:false},
       {key:'address2', type:'text', feedback:false},
       {key:'address3', type:'text', feedback:false},
       {key:'address4', type:'text', feedback:false},
       {key:'postcode', type:'text', feedback:false},
       {type:'submit', title:'Save'}
     ]
     schema:
       properties:
         first_name:
           title: 'First Name'
           type: 'string'
         last_name:
           title: 'Last Name'
           type: 'string'
         email:
           title: 'Email'
           type: 'string'
         address1:
           title: 'Address'
           type: 'string'
         address2:
           title: ' '
           type: 'string'
         address3:
           title: 'Town'
           type: 'string'
         address4:
           title: 'County'
           type: 'string'
         postcode:
           title: 'Post Code'
           type: 'string'
       title: 'Member'
       type: 'object'
   $httpBackend.whenGET('http://www.bookingbug.com/api/v1/123/members/123456/edit').respond () ->
     [200, member_schema, {}]

   member_bookings =
     _embedded:
       bookings: [{
         _embedded:
           answers: [{
             admin_only: false
             company_id: 123
             id: 6700607
             outcome: false
             price: 0
             question_id: 20478
             question_text: "Gender"
             value: "M"
           }]
         _links:
           company:
             href: "http://www.bookingbug.com/api/v1/company/123"
           edit_booking:
            href: "http://www.bookingbug.com/api/v1/123/members/123456/bookings/4553463/edit"
           member:
             href: "http://www.bookingbug.com/api/v1/123/members/123456{?embed}"
             templated: true
           person:
             href: "http://www.bookingbug.com/api/v1/123/people/74"
             templated: true
           self:
             href: "http://www.bookingbug.com/api/v1/123/members/123456/bookings?start_date=2014-11-21&page=1&per_page=30"
           service:
             href: "http://www.bookingbug.com/api/v1/123/services/30063"
             templated: true
         attended: true
         category_name: "Private Lessons"
         company_id: 123
         datetime: "2014-11-21T12:00:00+00:00"
         describe: "Fri 21st Nov 12:00pm"
         duration: 3600
         end_datetime: "2014-11-21T13:00:00+00:00"
         event_id: 325562
         full_describe: "Tennis Lesson"
         id: 4553463
         min_cancellation_time: "2014-11-20T12:00:00+00:00"
         on_waitlist: false
         paid: 0
         person_name: "Bob"
         price: 1
         purchase_id: 3844035
         purchase_ref: "j7PuYsmbexmFXS12Mzg0NDAzNQ%3D%3D"
         quantity: 1
         service_name: "Tennis Lesson"
         time_zone: ""
       }]
     _links:
       self:
         href: "http://www.bookingbug.com/api/v1/123/members/123456/bookings?start_date=2014-11-21&page=1&per_page=30"
     total_entries: 1
   $httpBackend.whenGET("http://www.bookingbug.com/api/v1/123/members/123456/bookings?start_date=#{moment().format("YYYY-MM-DD")}").respond () ->
     [200, member_bookings, {}]


