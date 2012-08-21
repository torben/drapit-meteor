class DrapitInterface
  elm: null
  constructor: ->
    ### OBSERVER ###
    jQuery =>
      $(document).keyup (e) =>
        return if @activeElm() == null

        pixel = if e.shiftKey then 10 else 1
        #console.log e.keyCode
        found = true
        if e.keyCode == 38 # ↑
          @activeElm().css.top = parseInt(@activeElm().css.top) - pixel
        else if e.keyCode == 39 # →
          @activeElm().css.left = parseInt(@activeElm().css.left) + pixel
        else if e.keyCode == 40 # ↓
          @activeElm().css.top =  parseInt(@activeElm().css.top) + pixel
        else if e.keyCode == 37 # ←
          @activeElm().css.left = parseInt(@activeElm().css.left) - pixel
        else if e.keyCode == 8 # DELETE
          @activeElm().destroy()
        else
          found = false
          return

        if found # TODO: need to break scrolling down
          e.stopPropagation()
          e.preventDefault()

        @update()

  activeElm: ->
    return @elm if @elm != null
    @elm = Image.find_by_id(Session.get("selected_element")) || Content.find_by_id(Session.get("selected_element")) || Page.find_by_id(Session.get("selected_element"))
    @elm

  setActiveImage: (elm, type) ->
    return if Session.equals("selected_element", elm._id) || Session.get("user_id") == null || isNaN(Session.get("user_id"))
    @elm = null
    Session.set("selected_element", elm._id)

  unsetActiveImage: ->
    @elm = null
    Session.set("selected_element", null)
    Session.set("panel", null)

  startDragg: (startPos) ->
    return if @activeElm() == null
    @onDragg = true

    $("body").on "mouseup.dragg", =>
      @stopDragg()

    $("body").on("mousemove.dragg", ((e) =>
      image = $("##{@activeElm()._id}")
      top = e.pageY-startPos.y - image.parent().offset().top
      $(image).css(left: "#{e.pageX-startPos.x}px", top: "#{top}px")
    ))

  storeText: (text) ->
    return if @activeElm() == null
    @activeElm().text = text
    @update()

  stopDragg: ->
    @onDragg = false
    image = $("##{@activeElm()._id}")
    @activeElm().css.top = parseInt($(image).css("top"))
    @activeElm().css.left = parseInt($(image).css("left"))
    @update()

    $("body").unbind("mousemove.dragg").unbind("mouseup.dragg")

  startResize: (behavior, startSize) ->
    return if @activeElm() == null
    @onResize = true

    $("body").on "mouseup.resize", =>
      @stopResize()

    image = $("##{@activeElm()._id}")
    origX = parseInt($(image).css("left"))
    origY = parseInt($(image).css("top"))
    origHeight = parseInt($(image).css("height"))
    origWidth = parseInt($(image).css("width"))

    $("body").on("mousemove.resize", ((e) =>
      if behavior == "tb"
        height = startSize.height + ((startSize.y-e.pageY) * -1)

        $(image).css
          height: "#{height}px"

      else if behavior == "lt"
        width = startSize.width + (startSize.x-e.pageX)
        height = startSize.height + (startSize.y-e.pageY)

        width = 20 if width < 20
        height = 20 if height < 20

        $(image).css
          width: "#{width}px"
          height: "#{height}px"
          left: "#{origX-(startSize.x-e.pageX)}px"
          top: "#{origY-(startSize.y-e.pageY)}px"
      else if behavior == "rt"
        width = startSize.width + (e.pageX-startSize.x)
        height = startSize.height + ((e.pageY-startSize.y) * -1)
        y = (origHeight - height) * -1

        width = 20 if width < 20
        height = 20 if height < 20

        $(image).css
          width: "#{width}px"
          height: "#{height}px"
          top: "#{origY-y}px"
      else if behavior == "lb"
        width = startSize.width + (startSize.x-e.pageX)
        height = startSize.height + ((startSize.y-e.pageY) * -1)
        x = (origWidth - width) * -1

        width = 20 if width < 20
        height = 20 if height < 20

        $(image).css
          width: "#{width}px"
          height: "#{height}px"
          left: "#{origX-x}px"
          top: "#{origY-y}px"
      else if behavior == "rb"
        width = startSize.width + (e.pageX-startSize.x)
        height = startSize.height + (e.pageY-startSize.y)

        width = 20 if width < 20
        height = 20 if height < 20

        $(image).css
          width: "#{width}px"
          height: "#{height}px"
    ))

  stopResize: ->
    @onResize = false
    image = $("##{@activeElm()._id}")
    @activeElm().css = {} unless @activeElm.css?
    @activeElm().css.width = parseInt($(image).css("width")) || $(image).width() || 100
    @activeElm().css.height = parseInt($(image).css("height")) || $(image).height() || 100
    @activeElm().css.top = parseInt($(image).css("top")) || 10
    @activeElm().css.left = parseInt($(image).css("left")) || 10
    @update()

    $("body").unbind("mousemove.resize").unbind("mouseup.resize")

  update: ->
    @activeElm().save()
    return
    ###
    console.log @activeElm
    return
    if @activeElm.images?
      delete @activeElm.images
      delete @activeElm.contents
      update(@activeElm._id, @activeElm)
    else if @activeElm.text?
      contents.update(@activeElm._id, @activeElm)
    else
      images.update(@activeElm._id, @activeElm)
    ###

