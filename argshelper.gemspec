Gem::Specification.new do |s|
	s.name = 'argshelper'
	s.version = '0.0.8'
	s.date = Time.now.strftime('%Y-%m-%d')
	s.summary = 'Command line arg aid'
	s.description = 'A simple command line argument helper'
	s.authors = [ "sleepless-p03t" ]
	s.email = 'sleepless.genesis6@gmail.com'
	s.files = [ "lib/argshelper.rb" ]
	s.homepage = 'https://rubygems.org/gems/argshelper'
	s.license = 'MIT'

	s.add_runtime_dependency('yard', '>=0.9.20')
	s.metadata["yard.run"] = "yri"
end
