class Content extends Model
  belongs_to: ["page"]
  attr_accessible: ["_id", "css", "page_id", "text", "user_id"]