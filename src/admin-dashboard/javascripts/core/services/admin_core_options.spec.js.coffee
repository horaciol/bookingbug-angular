'use strict';

describe 'BBAdminDashboard, AdminCoreOptions provider', () ->
  AdminCoreOptionsProviderObj = null
  AdminCoreOptions = null

  beforeEachFn = () ->
    module 'BBAdminDashboard'

    module (AdminCoreOptionsProvider) ->
      AdminCoreOptionsProviderObj = AdminCoreOptionsProvider
      return

    inject ($injector) ->
      AdminCoreOptions = $injector.get 'AdminCoreOptions'
      return

    return

  beforeEach beforeEachFn

  it 'has predefined options', ->
    options = AdminCoreOptionsProviderObj.$get()

    expect options.default_state
    .toBeDefined()
    expect options.default_language
    .toBeDefined()
    expect options.use_browser_language
    .toBeDefined()
    expect options.available_languages
    .toBeDefined()
    expect options.deactivate_sidenav
    .toBeDefined()
    expect options.deactivate_boxed_layout
    .toBeDefined()
    expect options.sidenav_start_open
    .toBeDefined()
    expect options.boxed_layout_start
    .toBeDefined()
    expect options.available_language_associations
    .toBeDefined()
    expect options.side_navigation
    .toBeDefined()

    return


  it 'allows to override predefined options', ->
    testOptionKey = 'default_state'
    testOptionOldValue = 'calendar'
    testOptionNewValue = 'some_value'

    expect AdminCoreOptionsProviderObj.getOption testOptionKey
    .toBe testOptionOldValue

    AdminCoreOptionsProviderObj.setOption testOptionKey, testOptionNewValue

    expect AdminCoreOptionsProviderObj.getOption testOptionKey
    .toBe testOptionNewValue

    return

  it 'doesn\'t allow to create new options', ->
    newOptionKey = 'some_new_option'
    newOptionValue = 'some_new_option_value'

    AdminCoreOptionsProviderObj.setOption newOptionKey, newOptionValue

    expect AdminCoreOptionsProviderObj.getOption newOptionKey
    .toBeUndefined()

    return

  it 'provider @get returns object with available options', ->
    expect AdminCoreOptions
    .toBe AdminCoreOptionsProviderObj.$get()

    return

  return
