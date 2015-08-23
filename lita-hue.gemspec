Gem::Specification.new do |spec|
  spec.name          = "lita-hue"
  spec.version       = "0.1.0.pre"
  spec.authors       = ["Donald Guy"]
  spec.email         = ["donald.b.guy@gmail.com"]
  spec.description   = "Lita Plugin to control Phillips Hue Lights"
  spec.summary       = "Lita UI for hue-lib gem allowing control of Phillips Hue Lights"
  spec.homepage      = "http://github.com/donaldguy/lita-hue"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "hue-lib"
  spec.add_dependency "css_color"

  spec.add_runtime_dependency "lita", ">= 4.5"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
