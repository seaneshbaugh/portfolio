# frozen_string_literal: true

def fixture_file(page_id, format)
  File.read(Rails.root.join('db', 'fixtures', 'files', 'pages', "#{page_id.to_s.rjust(2, '0')}.#{format}"))
end

Page.seed(:id) do |s|
  s.id = 1
  s.title = 'About'
  s.slug = 'about'
  s.body = fixture_file(1, 'html')
  s.style = fixture_file(1, 'css')
  s.script = fixture_file(1, 'js')
  s.meta_description = "I'm Sean Eshbaugh, and I like to program."
  s.meta_keywords = ''
  s.order = 0
  s.color = '#97080e'
  s.show_in_menu = true
  s.visible = true
  s.created_at = Time.parse('2012-11-18 06:38:34')
  s.updated_at = Time.parse('2018-08-14 11:26:48')
end

Page.seed(:id) do |s|
  s.id = 2
  s.title = 'Resume'
  s.slug = 'resume'
  s.body = fixture_file(2, 'html')
  s.style = fixture_file(2, 'css')
  s.script = fixture_file(2, 'js')
  s.meta_description = "Sean Eshbaugh's resume."
  s.meta_keywords = ''
  s.order = 1
  s.color = '#da4b0f'
  s.show_in_menu = true
  s.visible = true
  s.created_at = Time.parse('2012-11-17 21:43:47')
  s.updated_at = Time.parse('2018-02-20 11:32:27')
end

Page.seed(:id) do |s|
  s.id = 3
  s.title = 'Gems'
  s.slug = 'gems'
  s.body = fixture_file(3, 'html')
  s.style = fixture_file(3, 'css')
  s.script = fixture_file(3, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.order = 2
  s.color = '#e9b104'
  s.show_in_menu = true
  s.visible = true
  s.created_at = Time.parse('2012-11-17 21:46:26')
  s.updated_at = Time.parse('2014-07-04 18:42:46')
end

Page.seed(:id) do |s|
  s.id = 4
  s.title = 'Fun'
  s.slug = 'fun'
  s.body = fixture_file(4, 'html')
  s.style = fixture_file(4, 'css')
  s.script = fixture_file(4, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.order = 3
  s.color = '#488c13'
  s.show_in_menu = true
  s.visible = true
  s.created_at = Time.parse('2014-07-18 00:19:49')
  s.updated_at = Time.parse('2017-03-04 01:41:13')
end

Page.seed(:id) do |s|
  s.id = 5
  s.title = 'Shirts'
  s.slug = 'shirts'
  s.body = fixture_file(5, 'html')
  s.style = fixture_file(5, 'css')
  s.script = fixture_file(5, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.order = 0
  s.color = '#000000'
  s.show_in_menu = false
  s.visible = true
  s.created_at = Time.parse('2015-01-29 00:05:50')
  s.updated_at = Time.parse('2015-05-19 23:54:05')
end
