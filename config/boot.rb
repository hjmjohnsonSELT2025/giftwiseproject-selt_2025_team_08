ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
require "bootsnap/setup" # Speed up boot time by caching expensive operations.
begin
	require 'cgi'
	unless CGI.class_variable_defined?(:'@@accept_charset')
		CGI.class_variable_set(:'@@accept_charset', nil)
	end
rescue Exception
end
