id = 1

User.seed do |s|
  s.id = id
  s.email = 'sean@seaneshbaugh.com'
  s.password = 'changeme'
  s.role = 'sysadmin'
  s.first_name = 'Sean'
  s.last_name = 'Eshbaugh'

  id += 1
end
