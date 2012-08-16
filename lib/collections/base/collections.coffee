class Collections extends Meteor.Collection
  constructor: (user_id, collection) ->
    @user_id = user_id
    super(collection)