# frozen_string_literal: true

def fixture_file(post_id, format)
  File.read(Rails.root.join('db', 'fixtures', 'files', 'posts', "#{post_id.to_s.rjust(2, '0')}.#{format}"))
end

Post.seed(:id) do |s|
  s.id = 1
  s.user_id = 1
  s.title = 'Finally Learning to Make Games'
  s.slug = 'finally-learning-to-make-games'
  s.body = fixture_file(1, 'html')
  s.style = fixture_file(1, 'css')
  s.script = fixture_file(1, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2012-05-26 05:34:22')
  s.updated_at = Time.parse('2013-10-15 14:36:52')
end

Post.where(id: 1).first.tag_list.add('C#')

Post.seed(:id) do |s|
  s.id = 2
  s.user_id = 1
  s.title = 'Overriding But Preserving Ruby Methods'
  s.slug = 'overriding-but-preserving-ruby-methods'
  s.body = fixture_file(2, 'html')
  s.style = fixture_file(2, 'css')
  s.script = fixture_file(2, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2012-12-01 04:30:52')
  s.updated_at = Time.parse('2013-10-15 14:39:00')
end

Post.where(id: 2).first.tag_list.add('Ruby', 'Rails', 'ActiveRecord', 'Kentouzu', 'paper_trail')

Post.seed(:id) do |s|
  s.id = 3
  s.user_id = 1
  s.title = 'Configuring Nginx and Unicorn for force_ssl'
  s.slug = 'configuring-nginx-and-unicorn-for-force_ssl'
  s.body = fixture_file(3, 'html')
  s.style = fixture_file(3, 'css')
  s.script = fixture_file(3, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2013-02-05 17:39:26')
  s.updated_at = Time.parse('2013-10-15 14:41:47')
end

Post.where(id: 3).first.tag_list.add('Nginx', 'Unicorn', 'Rails', 'SSL')

Post.seed(:id) do |s|
  s.id = 4
  s.user_id = 1
  s.title = 'Why I Program'
  s.slug = 'why-i-program'
  s.body = fixture_file(4, 'html')
  s.style = fixture_file(4, 'css')
  s.script = fixture_file(4, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2013-03-01 11:37:45')
  s.updated_at = Time.parse('2013-03-01 11:39:46')
end

Post.seed(:id) do |s|
  s.id = 5
  s.user_id = 1
  s.title = 'Ripping Vinyl'
  s.slug = 'ripping-vinyl'
  s.body = fixture_file(5, 'html')
  s.style = fixture_file(5, 'css')
  s.script = fixture_file(5, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2013-03-03 05:55:02')
  s.updated_at = Time.parse('2013-11-25 18:18:15')
end

Post.where(id: 5).first.tag_list.add('records')

Post.seed(:id) do |s|
  s.id = 6
  s.user_id = 1
  s.title = 'Logging in Go'
  s.slug = 'logging-in-go'
  s.body = fixture_file(6, 'html')
  s.style = fixture_file(6, 'css')
  s.script = fixture_file(6, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2013-03-21 23:01:01')
  s.updated_at = Time.parse('2013-10-15 14:44:26')
end

Post.where(id: 6).first.tag_list.add('Go')

Post.seed(:id) do |s|
  s.id = 7
  s.user_id = 1
  s.title = 'I heard you like Ruby and Erlang so I put Ruby inside Erlang for you'
  s.slug = 'i-heard-you-like-ruby-and-erlang-so-i-put-ruby-inside-erlang-for-you'
  s.body = fixture_file(7, 'html')
  s.style = fixture_file(7, 'css')
  s.script = fixture_file(7, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2013-07-19 16:06:21')
  s.updated_at = Time.parse('2013-10-15 14:44:45')
end

Post.where(id: 7).first.tag_list.add('Elixir', 'Ruby', 'Erlang')

Post.seed(:id) do |s|
  s.id = 8
  s.user_id = 1
  s.title = 'More Elixir Adventures'
  s.slug = 'more-elixir-adventures'
  s.body = fixture_file(8, 'html')
  s.style = fixture_file(8, 'css')
  s.script = fixture_file(8, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2013-08-01 08:12:36')
  s.updated_at = Time.parse('2013-10-15 14:45:09')
end

Post.where(id: 8).first.tag_list.add('Elixir')

Post.seed(:id) do |s|
  s.id = 9
  s.user_id = 1
  s.title = 'Recursive Closures in Elixir'
  s.slug = 'recursive-closures-in-elixir'
  s.body = fixture_file(9, 'html')
  s.style = fixture_file(9, 'css')
  s.script = fixture_file(9, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2013-08-06 17:35:43')
  s.updated_at = Time.parse('2013-10-15 14:45:37')
end

Post.where(id: 9).first.tag_list.add('Elixir')

Post.seed(:id) do |s|
  s.id = 10
  s.user_id = 1
  s.title = 'Nth Element of a List in Scheme'
  s.slug = 'nth-element-of-a-list-in-scheme'
  s.body = fixture_file(10, 'html')
  s.style = fixture_file(10, 'css')
  s.script = fixture_file(10, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2013-10-14 16:53:21')
  s.updated_at = Time.parse('2013-10-15 14:46:21')
end

Post.where(id: 10).first.tag_list.add('Scheme', 'Common Lisp', 'Clojure', 'tail recursion')

Post.seed(:id) do |s|
  s.id = 11
  s.user_id = 1
  s.title = 'Chef Resource Condtionals'
  s.slug = 'chef-resource-condtionals'
  s.body = fixture_file(11, 'html')
  s.style = fixture_file(11, 'css')
  s.script = fixture_file(11, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2013-11-26 10:15:40')
  s.updated_at = Time.parse('2014-01-27 22:19:37')
end

Post.where(id: 11).first.tag_list.add('Ruby', 'Chef')

Post.seed(:id) do |s|
  s.id = 12
  s.user_id = 1
  s.title = 'Multiple Key Hashes in Ruby'
  s.slug = 'multiple-key-hashes-in-ruby'
  s.body = fixture_file(12, 'html')
  s.style = fixture_file(12, 'css')
  s.script = fixture_file(12, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2014-04-14 15:27:03')
  s.updated_at = Time.parse('2014-05-27 22:42:51')
end

Post.where(id: 12).first.tag_list.add('Ruby', 'data structures')

Post.seed(:id) do |s|
  s.id = 13
  s.user_id = 1
  s.title = 'Converting Text into a Sorted List'
  s.slug = 'converting-text-into-a-sorted-list'
  s.body = fixture_file(13, 'html')
  s.style = fixture_file(13, 'css')
  s.script = fixture_file(13, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2014-04-17 23:29:42')
  s.updated_at = Time.parse('2015-11-01 01:14:18')
end

Post.where(id: 13).first.tag_list.add('sed', 'tr', 'awk', 'Ruby', 'shell scripting')

Post.seed(:id) do |s|
  s.id = 14
  s.user_id = 1
  s.title = 'One of the Hard Things'
  s.slug = 'one-of-the-hard-things'
  s.body = fixture_file(14, 'html')
  s.style = fixture_file(14, 'css')
  s.script = fixture_file(14, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2014-09-05 23:52:48')
  s.updated_at = Time.parse('2018-08-03 13:14:58')
end

Post.where(id: 14).first.tag_list.add('Ruby', 'Rails', 'Spring', 'caching')

Post.seed(:id) do |s|
  s.id = 15
  s.user_id = 1
  s.title = 'Finding All ActiveRecord Callbacks'
  s.slug = 'finding-all-activerecord-callbacks'
  s.body = fixture_file(15, 'html')
  s.style = fixture_file(15, 'css')
  s.script = fixture_file(15, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2015-03-27 22:21:12')
  s.updated_at = Time.parse('2015-04-21 16:12:39')
end

Post.where(id: 15).first.tag_list.add('Ruby', 'Rails', 'ActiveRecord', 'callbacks')

Post.seed(:id) do |s|
  s.id = 16
  s.user_id = 1
  s.title = 'The Equivalence of MIN and AND and MAX and OR in K'
  s.slug = 'the-equivalence-of-min-and-and-and-max-and-or-in-k'
  s.body = fixture_file(16, 'html')
  s.style = fixture_file(16, 'css')
  s.script = fixture_file(16, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2015-06-18 11:44:48')
  s.updated_at = Time.parse('2015-06-18 11:47:48')
end

Post.where(id: 16).first.tag_list.add('K', 'boolean logic')

Post.seed(:id) do |s|
  s.id = 17
  s.user_id = 1
  s.title = 'Creating an OpenGL 4.1 program with GLEW and GLFW in XCode'
  s.slug = 'creating-an-opengl-4-1-program-with-glew-and-glfw-in-xcode'
  s.body = fixture_file(17, 'html')
  s.style = fixture_file(17, 'css')
  s.script = fixture_file(17, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2015-08-04 23:17:15')
  s.updated_at = Time.parse('2016-04-05 20:04:56')
end

Post.where(id: 17).first.tag_list.add('OpenGL', 'C++', 'Xcode', 'OS X', 'GLEW', 'GLFW')

Post.seed(:id) do |s|
  s.id = 18
  s.user_id = 1
  s.title = 'RIP Marvin Minsky'
  s.slug = 'rip-marvin-minsky'
  s.body = fixture_file(18, 'html')
  s.style = fixture_file(18, 'css')
  s.script = fixture_file(18, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2016-01-25 20:06:58')
  s.updated_at = Time.parse('2016-01-25 20:06:58')
end

Post.seed(:id) do |s|
  s.id = 19
  s.user_id = 1
  s.title = 'Compacting an Assocation List in Scheme'
  s.slug = 'compacting-an-assocation-list-in-scheme'
  s.body = fixture_file(19, 'html')
  s.style = fixture_file(19, 'css')
  s.script = fixture_file(19, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2016-02-02 14:04:49')
  s.updated_at = Time.parse('2016-04-05 20:54:11')
end

Post.where(id: 19).first.tag_list.add('Scheme', 'association lists')

Post.seed(:id) do |s|
  s.id = 20
  s.user_id = 1
  s.title = 'How Did That Get There?'
  s.slug = 'how-did-that-get-there'
  s.body = fixture_file(20, 'html')
  s.style = fixture_file(20, 'css')
  s.script = fixture_file(20, 'js')
  s.meta_description = ''
  s.meta_keywords = ''
  s.visible = true
  s.created_at = Time.parse('2017-04-14 21:25:29')
  s.updated_at = Time.parse('2018-02-23 14:10:33')
end

Post.where(id: 20).first.tag_list.add('Ruby')
