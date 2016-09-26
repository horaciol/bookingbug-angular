# Change Log
All notable changes to this project will be documented in this file using [CHANGELOG](http://keepachangelog.com/en/0.3.0/) convention.

## [Unreleased]
### Changed

- SDK has been refactored so bbLocale service is the only one place to call setter moment.locale 

- SDK build process does not flatten template files anymore in order to avoid naming conflicts.
  Bespoke projects that refer|override any of the following templates should be updated so they have proper directory structure.  
  ADMIN
  templates/login/admin_login.html
  templates/login/admin_pick_company.html  
  EVENT
  templates/event-chain-table/event_chain_table_main.html
  templates/event-chain-table/event_group_table_main.html  
  QUEUE
  templates/public/queuer_position.html  
  SETTINGS
  templates/admin-table/admin_form.html
  templates/admin-table/admin_table_main.html  
  Before change $templateCache would register 'login/admin_login.html' template as 'admin_login.html'.
  After change $templateCache registers 'login/admin_login.html' template as 'login/admin_login.html'.
- Month picker now works with angular carousel (removed angular slick from month picker)


<a name="2.0.0-alpha"></a>
# 2.0.0-alpha (2015-11-21)
### Changed
- **Resource:** Change resource form being wait_for_service by default, you now need to add a wait-for-service=true to the directive
- **Models** Moved Member and Admin injector to their specific bower deps and changed them all to inject directly at run time
- **Models** Removed functions from being copied from BaseResource objects - which helps simplify all Models
- **Models ** change getxxxPromise to just $getxxx as the promise version

## [1.4.10] - 2016-07-19
###Added
- Added helper methods to bbBasketList for displaying total price and tickety qty for grouped BasketItem objects that have events assoicated to them
- Added capability to edit BasketItem objects with events assoicated to them

### Changed
- Fixed issue where `current_item` was incorrectly set as the first item in the basket item rather than the most recently added one when updating the basket
- Fixed issue where selecting more tickets for the same event would make already entered ticket details available for edit again
- BREAKING: Updated `EventTicket` model with improved `getRange` method that takes account of tickets the user has selected when determing the valid number of tickets. Templates will need to be updated to pass the event to `getRange` method:

```
    <select ng-if="!selected_tickets" ng-model="ticket.qty" ng-options="n as n for n in ticket.getRange(event)">
      <option value="">-</option>
    </select>
```

## [1.4.0] - 2016-07-11
###Added
- New `Summary/Confirmation` step introduced in the default booking routing between the old 'summary' now 'booking questions' step and 'checkout' step
- Introduced capability to accept waitlist bookings in bbMemberUpcomingBookings

### Changed
- BREAKING: `src/core/javascripts/models/basket_item.js.coffee` renamed `getName` method to `getAttendeeName`. `getName` now returns the name of the service/event name associated with the basket_iten
- Updated `src/core/javascripts/models/basket.js.coffee` `readyToCheckout` method to check whether each individual basket item is ready
- bbMemberUpcomingBookings and bbMemberPastBookings now expect notLoaded and setLoaded to be passed in:

```
    <div bb-member-past-bookings member="client" not-loaded="notLoaded" set-loaded="setLoaded"></div>
```

- bbMemberUpcomingBookings and bbMemberPastBookings now use bbMemberBooking to render booking details and assoicated actions
- BREAKING: Scoped methods `edit`, and `cancel` in bbMemberUpcomingBookings and bbMemberPastBookings are now exposed by the controller which bbMemberBooking requires. These actions can now be called via the scoped `actions` variable. See `_member_booking.html` for an example.

## [1.3.1] - 2016-07-07
### Changed
- BREAKING: Fixed issue in bbMemberLogin where form controller shared scope with login model. Templates where bbMemberLogin is invoked need to be updated to use the login object:

```
    <input type="password" name="password" id="password" required ng-model="login.password" class="form-control" />
```

## [1.3.0] - 2016-07-07
### Added
- Introduced `use_local_timezone` option which instructs the widget to display times in users local time zone using `moment.tz.guess()`
- Introduced bbTimeZone for displaying time zone information
- Added `show_time_zone` option to the `datetime` filter to show the time zone abbreviation

### Changed
- Updated `datetime` filter to use display time zone to format time
- Updated accordion range group to respect display mode (local time zone vs default company time zone
* Updated bbTimes directive and bbTimeRanges directive to use time slot datetime if available

### Removed
- Removed duplicate code from bbTimeRanges that sets the loc and "coffied" all the operators for consistency
