class PostSerializer
  include FastJsonapi::ObjectSerializer

  set_type :post

  attributes :title, :body
end
