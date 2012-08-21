class FileUploadObserver
  constructor: ->
    try
      dropbox = $("body")[0]
      console.log dropbox

      # init event handlers
      dropbox.addEventListener("dragenter", ((e) => @dragEnter(e)), false)
      dropbox.addEventListener("dragexit", ((e) => @dragExit(e)), false)
      dropbox.addEventListener("dragover", ((e) => @dragOver(e)), false)
      dropbox.addEventListener("drop", ((e) => @drop(e)), false)
    catch e
      console.log e
      # Browser like IE


  dragEnter: (e) ->
    e.stopPropagation()
    e.preventDefault()

  dragExit: (e) ->
    e.stopPropagation()
    e.preventDefault()

  dragOver: (e) ->
    e.stopPropagation()
    e.preventDefault()

  drop: (e) ->
    console.log @
    e.stopPropagation()
    e.preventDefault()

    files = e.dataTransfer.files
    count = files.length

    # Only call the handler if 1 or more files was dropped.
    if count > 0
      window.files = files
      @handleFiles(files, e)
    else if window.libraryImage
      handleLibraryFiles(window.libraryImage, e)
      window.libraryImage = null

  getMouse: (e) ->
    mouse = {}
    if e.pageX || e.pageY
      mouse.x = e.pageX
      mouse.y = e.pageY
    else if e.clientX || e.clientY
      mouse.x = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft
      mouse.y = e.clientY + document.body.scrollTop + document.documentElement.scrollTop

    return mouse

  handleFiles: (files, e) ->
    mouse = @getMouse(e)

    unless FormData?
      alert('Your browser does not support standard HTML5 Drag and Drop. Use the camera button to upload images.')
      return

    blockUI() if files.length > 0

    form = new FormData()
    console.log files
    for file in files
      form.append('path', '/')
      form.append('upload[upload]', file)

      form.append('upload[left]', mouse.x)
      form.append('upload[top]', mouse.y)
      form.append('upload[content_type]', 'image')
      form.append('upload[max_width]', $(window).width())

      mouse.x += 10
      mouse.y += 10
      console.log "arg?"

      break # Multiple Upload not supported yet

    console.log form

    $.ajax
      url: 'http://barbra-streisand.dev/uploads.json'
      data: form
      cache: false
      contentType: false
      processData: false
      type: 'POST'
      success: (uploadJSON) ->
        $.unblockUI()
        page_id = Session.get("activePage") || Page.all()[0]._id
        page = $("##{page_id}")

        top = e.pageY - page.offset().top
        left = e.pageX

        image = new Image
          css:
            width: uploadJSON.width
            height: uploadJSON.height
            top: top
            left: left
          image_urls: uploadJSON.image_urls
          page_id: page_id
        image.save()
      error: ->
        alert('Bild konnte nicht verarbeitet werden!')
        $.unblockUI()

    ###
    xhr = new XMLHttpRequest()
    xhr.open("POST", "http://barbra-streisand.dev")
    xhr.onload = (response) ->
      console.log response

    xhr.send(form)
    ###
    
    
    ###
    Meteor.call "uploadImage", file, =>
      test = 
        success: (uploadJSON) ->
          $.unblockUI()
          # das auskommentieren, wenn faye funzt
          upload = new Pixbob.Models.Upload(uploadJSON)
          router.uploads.add(upload)
          window.router.setBackground()
        error: ->
          alert('Bild konnte nicht verarbeitet werden!')
          $.unblockUI()
    ###

