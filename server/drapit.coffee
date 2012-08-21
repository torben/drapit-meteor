#Images = new Meteor.Collection("images")
#Pages  = new Meteor.Collection("pages")
#Contents  = new Meteor.Collection("contents")
pages = new Pages #Meteor.Collection("pages")
images = new Images #new Meteor.Collection("images")
contents = new Contents # Meteor.Collection("contents")

user_id = null
subdomain = null

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
        doc.nickname = subdomain if collection == "pages"
        doc.created_at = new Date().getTime()
        origInsert.call(@, doc, callback)

      # UPDATE
      origUpdate = Meteor.default_server.method_handlers["/#{collection}/update"]
      Meteor.default_server.method_handlers["/#{collection}/update"] = (selector, modifier, options, callback) ->
        return if user_id == null || typeof selector != "string"
        console.log "update: #{collection} #{selector}"

        modifier.user_id = user_id
        modifier.nickname = subdomain if collection == "pages"
        origUpdate.call(@, selector, modifier, options, callback)

      # REMOVE
      origRemove = Meteor.default_server.method_handlers["/#{collection}/remove"]
      Meteor.default_server.method_handlers["/#{collection}/remove"] = (selector, callback) ->
        return if user_id == null || typeof selector != "string"

        origRemove.call(@, selector, callback)
    )

  Meteor.publish "images", (uid) ->
    images.find(user_id: uid)

  Meteor.publish "pages", (nickname) ->
    pages.find(nickname: nickname)

  Meteor.publish "contents", (uid) ->
    contents.find(user_id: uid)

  Meteor.methods
    me: (_user_id, api_key) ->
      result = Meteor.http.call("GET", "http://pixoona-api.dev/users/me?app_token=test&user_key=#{api_key}")
      if result.statusCode == 200 && result.data.id == _user_id
        user_id = _user_id
        subdomain = result.data.nickname
        return true

      return false

    nickname: (_nickname) ->
      true

    uploadImage: (file) ->
      console.log file
      Meteor.http.call "POST", "http://barbra-streisand.dev", {data: form}, (error, result) ->
        console.log result.statusCode
        #if result.statusCode === 200
        #  # jeah?

