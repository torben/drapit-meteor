class Images extends Collections
  constructor: (user_id) ->
    super(user_id, "images")

  all: (page_id) ->
    arr = []
    for img in @find(page_id: page_id).fetch()
      arr.push(new Image(img, @))
    arr