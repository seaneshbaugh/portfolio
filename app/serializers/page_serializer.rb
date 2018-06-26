class PageSerializer
  include FastJsonapi::ObjectSerializer

  set_type :page

  attributes :title, :body
end
