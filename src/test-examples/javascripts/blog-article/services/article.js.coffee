factory = () ->

  model = ->
    @id = null
    @title = 'default title'
    @content = 'default content'

    @getTitle = getTitle
    @setTitle = setTitle

    return

  getTitle = () ->
    return @title

  setTitle = (title) ->
    @title = title
    return

  return model #because factory by default returns constructor function

angular
.module('bbTe.blogArticle')
.factory('bbTeBlogArticle', factory)
