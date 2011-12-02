$:.push File.expand_path("../lib", __FILE__)

require "zencodable/version"

Gem::Specification.new do |s|
  s.name        = "zencodable"
  s.version     = Zencodable::VERSION
  s.authors     = ["Sam Beam"]
  s.email       = ["sbeam@onsetcorps.net"]
  s.homepage    = "https://github.com/sbeam/zencodable"
  s.summary     = "mindful multiformat video encoding for AR models with Zencoder API"
  s.description = "provides a `has_video_encodings` class method to your models that \
  allows you to configure and set up any Zencoder settings you will need \
  to create multiple output video container formats (mp4, ogg, wmv, etc) from a single \
  uploaded source file. Uses the Zencoder API (zencoder.com) and (as of now) expects \
  you to have an S3 bucket where we can ask zencoder to place the generated files."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.0"
  s.add_dependency "aws-s3"
  s.add_dependency "zencoder"
  s.add_runtime_dependency "typhoeus"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mocha"
  s.add_development_dependency "factory_girl"

end
