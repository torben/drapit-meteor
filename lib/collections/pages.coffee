class Pages extends Collections
  constructor: (user_id) ->
    super(user_id, "pages")

  all: ->
    arr = []
    for pge in @find().fetch()
      arr.push(new Page(pge, @))
    arr