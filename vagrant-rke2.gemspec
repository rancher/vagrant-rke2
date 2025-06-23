require_relative 'lib/vagrant-rke2/version'

Gem::Specification.new do |spec|
  spec.name          = "vagrant-rke2"
  spec.version       = VagrantPlugins::Rke2::VERSION
  spec.authors       = ["Derek Nola"]
  spec.email         = ["derek.nola@suse.com"]

  spec.license      = 'Apache-2.0'

  spec.summary       = "Manage RKE2 installations on Vagrant guests"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/dereknola/vagrant-rke2"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] =spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
