# frozen_string_literal: true

module SlugNormalization
  extend ActiveSupport::Concern

  def normalize_friendly_id(value)
    CGI.unescapeHTML(Sanitize.clean(value.to_s)).gsub(/'|"/, "").gsub(" & ", " and ").delete("&").squeeze(" ").parameterize
  end
end
