lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "segmentation/version"

Gem::Specification.new do |spec|
  spec.name = "segmentation"
  spec.version = Segmentation::VERSION
  spec.authors = ["Alessandro Desantis"]
  spec.email = ["alessandrodesantis@nebulab.com"]

  spec.summary = "The missing Segment integration framework for Rails."
  spec.homepage = "https://github.com/nebulab/segmentation"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path("..", __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", "~> 6.1.4"

  spec.add_development_dependency "rspec-rails", "~> 5.0"
  spec.add_development_dependency "standard", "~> 1.1"
end
