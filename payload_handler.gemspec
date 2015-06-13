$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "payload_handler/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "payload_handler"
  s.version     = PayloadHandler::VERSION
  s.authors     = ["Eric Carty-Fickes"]
  s.email       = ["ericcf@northwestern.edu"]
  s.homepage    = "https://github.com/cbitstech/payload_handler_ruby"
  s.summary     = "Authentication related functionality for BIT projects."
  s.description = "Authentication related functionality for BIT projects."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile",
                "README.md"]

  s.add_dependency "activesupport", "~> 4.2"

  s.add_development_dependency "rspec-rails", "~> 3.1"
  s.add_development_dependency "rubocop", "~> 0.32.0"
  s.add_development_dependency "simplecov"
end
