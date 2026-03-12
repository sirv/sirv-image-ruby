# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "sirv_image"
  spec.version       = "1.0.0"
  spec.authors       = ["Sirv"]
  spec.email         = ["support@sirv.com"]

  spec.summary       = "Sirv SDK for building URLs and HTML tags for images, spins, videos, 3D models, and galleries"
  spec.description   = "SDK for building Sirv CDN URLs and HTML viewer tags. " \
                        "Supports responsive srcset generation, image/zoom/spin/video/model/gallery viewers, " \
                        "nested parameter flattening, and Sirv JS script tag generation."
  spec.homepage      = "https://sirv.com/help/articles/dynamic-imaging/"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.files         = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec", "~> 3.0"
end
