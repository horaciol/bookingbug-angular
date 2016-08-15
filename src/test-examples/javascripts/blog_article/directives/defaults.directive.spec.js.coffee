'use strict';

describe 'bbTe.blogArticle, bbTeBaDefaults directive', () ->
  $compile = null
  $httpBackend = null
  $rootScope = null

  compiled = null

  directiveTemplatePath = '/templates/blog-article/defaults.html';
  directiveHtmlAttribute = '<span bb-te-ba-defaults></span>'
  directiveHtmlElement = '<bb-te-ba-defaults></bb-te-ba-defaults>'
  directiveHtmlClass = '<span class="bb-te-ba-defaults"></span>'
  directiveHtmlComment = '<!-- directive: bb-te-ba-defaults  -->'

  htmlScopeTest = '<div class="app-level"><span bb-te-ba-defaults></span></div>'

  beforeEachFn = () ->
    module('bbTe.blogArticle')

    inject ($injector) ->
      $compile = $injector.get '$compile'
      $httpBackend = $injector.get '$httpBackend'
      $rootScope = $injector.get('$rootScope')
      return

    $httpBackend.whenGET(directiveTemplatePath).respond(200, '<span>some content!</span>')

    return

  afterEachFn = () ->
    $httpBackend.verifyNoOutstandingExpectation();
    $httpBackend.verifyNoOutstandingRequest()

  beforeEach beforeEachFn
  afterEach afterEachFn

  describe '"restrict" property', ->
    it 'can be declared as an attribute by default', () ->
      compiled = $compile(directiveHtmlAttribute)($rootScope);

      expect ->
        $httpBackend.flush()
      .not.toThrow()

      expect(compiled.html()).toContain('some content!');
      return

    it 'can be declared as an element by default', () ->
      compiled = $compile(directiveHtmlElement)($rootScope);

      expect ->
        $httpBackend.flush()
      .not.toThrow()
      return

    it 'cannot be declared using a class', () ->
      compiled = $compile(directiveHtmlClass)($rootScope);

      expect ->
        $httpBackend.flush()
      .toThrow()
      return

    it 'cannot be declared using a comment', () ->
      compiled = $compile(directiveHtmlComment)($rootScope);

      expect ->
        $httpBackend.flush()
      .toThrow()
      return

    return

  describe '"scope" property is set by default to false which means surrounding scope', ->

    surroundingScope = null
    directiveScope = null

    beforeEachLvl2 = ->
      $rootScope.appLevelParam = 'anything'
      compiled = $compile(htmlScopeTest)($rootScope);
      $httpBackend.flush()

      surroundingScope = compiled.scope()
      directiveScope = compiled.find('span').scope()

    beforeEach  beforeEachLvl2

    it 'changes on parent scope are visible in directive', ->

      surroundingScope.appLevelParam = 'aaa'

      expect surroundingScope.appLevelParam
      .toBe directiveScope.appLevelParam

      return

    it 'directive.scope() returns surrounding scope so any changes on directive scope are actually changes on surrounding scope', ->

      directiveScope.appLevelParam = 'aaa'

      expect surroundingScope.appLevelParam
      .toBe directiveScope.appLevelParam

      return

    it 'does not create child scope or isolated scope', ->

      directive = compiled.find('span')

      expect directive.hasClass('ng-scope')
      .toBe false

      expect directive.isolateScope()
      .toBeUndefined()

      expect directive.hasClass('ng-scope-isolated')
      .toBe false

      return
    return

    describe ''

  return


