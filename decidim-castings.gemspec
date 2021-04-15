# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/castings/version"

Gem::Specification.new do |s|
  s.version = Decidim::Castings.version
  s.authors = ["Belighted"]
  s.email = ["info@belighted.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/belighted/decidim-module-castings"
  s.required_ruby_version = ">= 2.5"

  s.name = "decidim-castings"
  s.summary = "A decidim castings module"
  s.description = "Provides the functionalities to get committee composition."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.require_paths = ["lib"]

  s.add_dependency "decidim-core", Decidim::Castings.version
  s.add_dependency "decidim-admin", Decidim::Castings.version
  s.add_dependency "caxlsx"
  s.add_dependency "roo", "~> 2.8.3"

end
