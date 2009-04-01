require 'rubygems'

spec = Gem::Specification.new do |s|

  s.name = 'jira4r'
  s.version = "0.0.1"
  s.platform = Gem::Platform::RUBY
  s.summary = "jira4r is a pure-Ruby JIRA client library"
# s.requirements << 'Jabber server'
  s.files = Dir.glob("lib/**/*").delete_if { |item| item.include?(".svn") }
  s.require_path = 'lib'
# s.autorequire = 'jabber4r/jabber4r'
  
  s.has_rdoc=false

  s.author = "Ben Walding"
  s.email = "bwalding@codehaus.org"
# s.rubyforge_project = "jabber4r"
  s.homepage = "http://jira4r.rubyhaus.org"

end

if $0==__FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end