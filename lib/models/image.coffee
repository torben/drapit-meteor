class Image extends Model
  belongs_to: ["page"]
  attr_accessible: ["_id", "css", "page_id", "src", "user_id"]