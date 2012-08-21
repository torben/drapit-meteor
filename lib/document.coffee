if window? && window.location?
  window.location.subdomain = ->
    hostname = window.location.host
    parts = hostname.split('.')

    if parts.length <= 2
      ""
    else
      parts.slice(0,parts.length - 2).join(".")
