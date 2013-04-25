json.array!(@comments) do |comment|
  json.extract! comment, :content, :user_id, :commentable_type, :commentable_id
  json.url comment_url(comment, format: :json)
end