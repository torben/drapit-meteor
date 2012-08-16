class Model
  collection: null

  constructor: (object) ->
    @collection = eval(@className().toLowerCase().pluralize())
    for o of object
      eval("this.#{o}=object[o]") if @attr_accessible.indexOf(o) >= 0

    if @has_many? && @_id?
      for h in @has_many
        #that = @
        eval("this.#{h} = #{h.singularize().capitalize()}.all({#{@className().toLowerCase()}_id: this._id})")
        #eval("this.#{h}.build = function(options) { that.build(options) }")

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
      obj = collection.find(_id: id).fetch()[0]
      return null if obj.length == 0
      return new @(obj)
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
      try
        delete obj._id
        obj = eval("#{this.className()}.find_by_id(this.collection.insert(obj))")
        @constructor(obj)
        return @
      catch e
        return null
    else
      @collection.update(@_id, obj)
      obj = eval("#{this.className()}.find_by_id(this._id)")
      @constructor(obj)
      return @
