# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "sirv-image"
  spec.version       = "2.0.0"
  spec.authors       = ["Sirv"]
  spec.email         = ["support@sirv.com"]

  spec.summary       = "Sirv image transformation Ruby SDK"
  spec.description   = "Official Ruby SDK for the Sirv dynamic imaging API. This SDK provides a simple way to request any modified image (dimensions, format, quality, sharpen, crop, watermark etc.) using the 100+ image transformation options in Sirv's image optimization service."
  spec.homepage      = "https://sirv.github.io/sirv-image-ruby/"
  spec.metadata      = {
    "source_code_uri" => "https://github.com/sirv/sirv-image-ruby",
    "bug_tracker_uri" => "https://github.com/sirv/sirv-image-ruby/issues"
  }
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files         = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.0"
end
