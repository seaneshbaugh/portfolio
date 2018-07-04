# frozen_string_literal: true

class PageSerializer
  include FastJsonapi::ObjectSerializer

  set_type :page

  attributes :title, :body
end
