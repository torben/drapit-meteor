class Contents extends Collections
  constructor: (user_id) ->
    super(user_id, "contents")

  all: (page_id) ->
    arr = []
    for cnt in @find(page_id: page_id).fetch()
      arr.push(new Content(cnt, @))
    arr