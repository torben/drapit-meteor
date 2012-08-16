#Images = new Meteor.Collection("images")
#Pages  = new Meteor.Collection("pages")
#Contents  = new Meteor.Collection("contents")
pages = new Pages(user_id) #Meteor.Collection("pages")
images = new Images(user_id) #new Meteor.Collection("images")
contents = new Contents(user_id) # Meteor.Collection("contents")

user_id = null

if Meteor.is_server
  Meteor.startup ->
    _.each(['images', 'pages', 'contents'], (collection) ->
      ###
      _.each(['insert', 'update', 'remove'], (method) ->
        if user_id == null
          Meteor.default_server.method_handlers['/' + collection + '/' + method] = () ->
          
      )
      ###
      
      # INSERT
      origInsert = Meteor.default_server.method_handlers["/#{collection}/insert"]
      Meteor.default_server.method_handlers["/#{collection}/insert"] = (doc, callback) ->
        return if user_id == null

        doc.user_id = user_id
        origInsert.call(@, doc, callback)

      # UPDATE
      origUpdate = Meteor.default_server.method_handlers["/#{collection}/update"]
      Meteor.default_server.method_handlers["/#{collection}/update"] = (selector, modifier, options, callback) ->
        return if user_id == null || typeof selector != "string"

        modifier.user_id = user_id
        origUpdate.call(@, selector, modifier, options, callback)

      # REMOVE
      origRemove = Meteor.default_server.method_handlers["/#{collection}/remove"]
      Meteor.default_server.method_handlers["/#{collection}/remove"] = (selector, callback) ->
        return if user_id == null || typeof selector != "string"

        origRemove.call(@, selector, callback)
    )

  Meteor.publish "images", (uid) ->
    images.find(user_id: uid)

  Meteor.publish "pages", (uid) ->
    pages.find(user_id: uid)

  Meteor.publish "contents", (uid) ->
    contents.find(user_id: uid)

  Meteor.methods
    me: (_user_id, api_key) ->
      result = Meteor.http.call("GET", "http://pixoona-api.dev/users/#{_user_id}?app_token=test&user_key=#{api_key}")
      if result.statusCode == 200 && result.data.id == _user_id
        user_id = _user_id
        return true

      return false