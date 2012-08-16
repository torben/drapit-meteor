class Model
  collection: null

  constructor: (object) ->
    @collection = eval(@className().toLowerCase().pluralize())
    for o of object
      eval("this.#{o}=object[o]") if @attr_accessible.indexOf(o) >= 0

    if @has_many? && @_id?
      for h in @has_many
        eval("this.#{h} = #{h.singularize().capitalize()}.all({#{@className().toLowerCase()}_id: this._id})")

  @className: ->
    i = new @
    funcNameRegex = /function (.{1,})\(/
    results = (funcNameRegex).exec((i).constructor.toString())
    return if results && results.length > 1 then results[1] else ""
  className: ->
    funcNameRegex = /function (.{1,})\(/
    results = (funcNameRegex).exec((@).constructor.toString())
    return if results && results.length > 1 then results[1] else ""


  @find_by_id: (id) ->
    try
      collection = eval(@.className().toLowerCase().pluralize())
      new @(collection.find(_id: id).fetch()[0])
    catch e
      null

  @all: (options = {}) ->
    collection = eval(@.className().toLowerCase().pluralize())
    arr = []
    for obj in collection.find(options).fetch()
      arr.push(new @(obj))
    arr

  isNew: ->
    !@_id?

  save: ->
    obj = {}
    for o in @attr_accessible
      obj[o] = eval("this.#{o}")

    if @isNew()
      @collection.insert(obj)
    else
      @collection.update(@_id, obj)