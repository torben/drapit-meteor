class Page extends Model
  has_many: ["contents", "images"]
  attr_accessible: ["_id", "css", "height", "user_id", "nickname"]