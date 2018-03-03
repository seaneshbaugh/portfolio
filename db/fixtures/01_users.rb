# frozen_string_literal: true

User.seed(:id) do |s|
  s.id = 1
  s.email = 'sean@seaneshbaugh.com'
  s.password = 'changeme'
  s.role = 'sysadmin'
  s.first_name = 'Sean'
  s.last_name = 'Eshbaugh'
end
