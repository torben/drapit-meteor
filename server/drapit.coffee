#Images = new Meteor.Collection("images")
#Pages  = new Meteor.Collection("pages")
#Contents  = new Meteor.Collection("contents")
pages = new Pages #Meteor.Collection("pages")
images = new Images #new Meteor.Collection("images")
contents = new Contents # Meteor.Collection("contents")

collections = [
  pages, images, contents
]

user_id = null
subdomain = null

if Meteor.is_server
  Meteor.startup ->
    _.each(collections, (collection) ->
      ###
      _.each(['insert', 'update', 'remove'], (method) ->
        if user_id == null
          Meteor.default_server.method_handlers['/' + collection + '/' + method] = () ->
          
      )
      ###
      
      collection.allow
        insert: (userId, doc) ->
          return if user_id == null
          doc.user_id = user_id
          doc.nickname = subdomain if collection == "pages"
          doc.created_at = new Date().getTime()

          true

        update: (userId, docs, fields, modifier) ->
          return if user_id == null #|| typeof selector != "string" #TODO: sicher machen

          #modifier.user_id = user_id
          #modifier.nickname = subdomain if collection == "pages"


          return true
          _.all docs, (doc) ->
            return doc.user_id == user_id #  TODO: should be userId


        remove: (userId, docs) ->
          return if user_id == null || typeof selector != "string"

          true

        fetch: ['owner']

    )

  Meteor.publish "images", (uid) ->
    #console.log "uid: #{uid}"
    images.find(user_id: uid)

  Meteor.publish "pages", (nickname) ->
    #console.log "called"
    #console.log "nickname: #{nickname}"
    pages.find(nickname: nickname)

  Meteor.publish "contents", (uid) ->
    #console.log "uid: #{uid}"
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

