class Image extends Model
  belongs_to: ["page"]
  attr_accessible: ["_id", "css", "page_id", "image_urls", "user_id"]

  host: "http://barbra-streisand.dev"
  sizes: [
    { key: 'thumb', value: 100 }
    { key: 'small', value: 250 }
    { key: 'medium', value: 500 }
    { key: 'big', value: 1000 }
    { key: 'ultra', value: 2000 }
  ]

  src: ->
    for size in @sizes
      if @css.width <= size.value
        return @image_urls[size.key]
