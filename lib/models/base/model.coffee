class Model
  collection: null

  constructor: (object, collection) ->
    @collection = collection
    for o of object
      eval("this.#{o}=object[o]") if @attr_accessible.indexOf(o) >= 0

    if @has_many? && @_id?
      for h in @has_many
        eval("this.#{h} = #{h}.all(this._id)")

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