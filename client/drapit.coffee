pages = new Pages()
images = new Images()
contents = new Contents()

user_id = 18

blockUI = ->
  $.blockUI
    overlayCSS: { backgroundColor: '#fff', opacity: 0.95 }
    message: '<img src="/assets/ajax-loader-green.gif" />'
    baseZ: 99997
    css: {
      border: ''
      background: ''
    }

inTools = ->
  $(".colorpicker").is(":visible") || (Session.get("editmode")? && Session.get("editmode") != null)

setNickname = ->
  if document.location.subdomain() != ""
    Session.set("nickname", document.location.subdomain())
    Meteor.call "nickname", document.location.subdomain(), (e, s) ->
      Session.set("nickname", "") unless s

checkLogin = ->
  ###
  $.getJSON "http://barbra-streisand.dev/me?sensible=true&callback=?", (data) ->
    Meteor.call "me", data.id, data.api_key, (e, s) ->
      if s
        Session.set("user_id", user_id)
      else
        Session.set("user_id", null)
  ###
  Meteor.call "me", user_id, "2f3c6a919580a8d1862d6006874f1a32", (e, s) ->
    if s
      Session.set("user_id", user_id)
    else
      Session.set("user_id", null)


if Meteor.is_client
  setNickname()
  checkLogin()

  Meteor.autosubscribe ->
    Meteor.subscribe("images", user_id)
    Meteor.subscribe("contents", user_id)
    Meteor.subscribe("pages", Session.get("nickname"))

  jQuery ->
    $("body").click ->
      window.drapitInterface.unsetActiveImage() unless inTools()

  Meteor.startup ->
    Session.set("activePage", "")
    window.drapitInterface = new DrapitInterface()
    window.uploadObserver = new FileUploadObserver()

  Template.upload.pages = ->
    return if isNaN(Session.get("user_id"))

    Page.all()

  Template.upload.loading = ->
    Session.get("nickname") != "" && Page.all().length == 0

  Template.image.style = ->
    image = @
    str = ""
    for c of @css
      key = c
      value = switch c
        when "left", "top", "width", "height"
          "#{@css[c]}px"
        when "transform"
          #TODO: auf Bild auslagern
          key = "-webkit-transform"
          "rotate(#{@css[c]}deg)"
        else ""

      str += "#{key}: #{value};" if key != ""
    str

  Template.content.style = ->
    str = ""
    for c of @css
      key = c
      value = switch c
        when "left", "top", "width", "height"
          "#{@css[c]}px"
        when "transform"
          key = "-webkit-transform"
          "rotate(#{@css[c]}deg)"
        else
          @css[c]
      str += "#{key}: #{value};"
    str

  Template.image.selected = ->
    if Session.equals("selected_element", @._id) then "selected" else ""

  Template.content.selected = ->
    if Session.equals("selected_element", @._id) then "selected" else ""

  Template.content.events =
    'blur textarea': (e) ->
      drapitInterface.storeText($(e.currentTarget).val())
      target = $("##{Session.get("editmode")}")
      $(target).find("textarea").toggleClass("hide")
      $(target).find(".content-area").toggleClass("hide")
      window.setTimeout ->
        Session.set("editmode", null)
      , 100

  Template.upload.events =
    'mouseover .images': (e) ->
      Session.set("activePage", $(e.currentTarget).attr("id"))
    'mouseover .image': (e) ->
      #return if drapitInterface.onDragg || drapitInterface.onResize
      #drapitInterface.setActiveImage(@)
    'mouseover .seperator': (e) ->
      return if drapitInterface.onDragg || drapitInterface.onResize
      drapitInterface.setActiveImage(@)
    'mouseout .image': (e) ->
      #return if drapitInterface.onDragg || drapitInterface.onResize
      #drapitInterface.unsetActiveImage()
    'mouseout .seperator': (e) ->
      return if drapitInterface.onDragg || drapitInterface.onResize
      drapitInterface.unsetActiveImage()
    'mousedown .resize': (e) ->
      elm = $("##{drapitInterface.activeElm()._id}")
      r = $(e.currentTarget)
      behavior = if r.hasClass("left-top")
        "lt"
      else if r.hasClass("right-top")
        "rt"
      else if r.hasClass("left-bottom")
        "lb"
      else if r.hasClass("right-bottom")
        "rb"

      drapitInterface.startResize(behavior, x: e.pageX, y: e.pageY, width: elm.width(), height: elm.height())
      return false

    'mousedown .seperator': (e) ->
      elm = $("##{drapitInterface.activeElm()._id}")

      drapitInterface.startResize("tb", x: e.pageX, y: e.pageY, width: elm.width(), height: elm.height())
      return false

    'click .controllable': (e) ->
      e.stopPropagation()
      return false
    'click .seperator': (e) ->
      e.stopPropagation()
      return false
    'click .resize': (e) ->
      e.stopPropagation()
      return false

    'dblclick .content-area': (e) ->
      target = e.currentTarget
      $(target).toggleClass("hide")
      $(target).parent().find("textarea").toggleClass("hide")
      Session.set("editmode", @_id)

    'click textarea': (e) ->
      e.stopPropagation()

    'mousedown .controllable': (e) ->
      try
        clearTimeout(window.timeout)
        $("body").unbind("mouseup.checkmouse")
      catch e
        #

      drapitInterface.setActiveImage(@)
      Session.set("panel", @_id)

      up = false
      $("body").on "mouseup.checkmouse", ->
        up = true

      e.offsetX = e.layerX - $(e.target).position().left unless e.offsetX
      e.offsetY = e.layerY - $(e.target).position().top unless e.offsetY

      window.timeout = window.setTimeout ->
        drapitInterface.startDragg(x: e.offsetX, y: e.offsetY) unless up
        $("body").unbind("mouseup.checkmouse")
      , 100

      if @text?
        Session.set("panelType", 'content')
      else
        Session.set("panelType", 'image')
        return false

  Template.menubar.events =
    'click .add-page': (e) ->
      page = new Page
        css:
          height: 500
      page.save()


