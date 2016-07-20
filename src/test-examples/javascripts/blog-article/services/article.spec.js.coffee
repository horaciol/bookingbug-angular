'use strict';

describe 'bbTe.blogArticle, bbTeBlogArticle factory', () ->
  bbTeBlogArticle = null

  beforeEachFn = () ->
    module('bbTe.blogArticle')

    inject ($injector) ->
      bbTeBlogArticle = $injector.get 'bbTeBlogArticle'
      return
    return

  beforeEach beforeEachFn

  it 'can create new articles and change their names', ->
    ar1 = new bbTeBlogArticle()
    ar1.setTitle 'ar1 title'

    ar2 = new bbTeBlogArticle()

    expect ar1.getTitle()
    .toBe 'ar1 title'

    expect ar2.getTitle()
    .toBe 'default title'

    return

  return
