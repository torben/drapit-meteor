if Meteor.is_client
  Template.panel.images = ->
    return [] if Session.get("user_id") == null || isNaN(Session.get("user_id")) || Session.get("panel") == null

    @uuid = Meteor.uuid() unless !@uuid
    Meteor.defer ->
      #$('.color-picker').ColorPicker({flat: true})
      $('#color-selector').ColorPicker
      	color: '#0000ff'
      	onShow: (colpkr) ->
      		$(colpkr).fadeIn(500)
      		return false
      	onHide: (colpkr) ->
      		$(colpkr).fadeOut(500)
      		content = Contents.find(user_id: Session.get("user_id")).fetch()[0]

      		content.css["background-color"] = $("##{Session.get("panel")}").css('backgroundColor')
      		
      		contents.update(content._id, content)
      		return false
      	onChange: (hsb, hex, rgb) ->
      		$("##{Session.get("panel")}").css('backgroundColor', '#' + hex)

    if Session.get("panelType") == "content"
      contents.find(user_id: user_id, _id: Session.get("panel")).fetch()
    else
      images.find_by_id(Session.get("panel"))

  Template.panel.events =
    'click table': (e) ->
      e.stopPropagation()
      return false

    'change input': (e) ->
      target = e.currentTarget
      @css[target.name] = target.value
      images.update(@._id, @)

  Template.panel_info.hasBackground = ->
    Session.get("panelType") == "content"