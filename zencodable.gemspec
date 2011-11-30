$:.push File.expand_path("../lib", __FILE__)

require "zencodable/version"

Gem::Specification.new do |s|
  s.name        = "zencodable"
  s.version     = Zencodable::VERSION
  s.authors     = ["Sam Beam"]
  s.email       = ["sbeam@onsetcorps.net"]
  s.homepage    = "http://onsetcorps.net"
  s.summary     = "peaceful and mindful multiformat video encoding with Zencoder API"
  s.description = "provides a `has_video_encodings` class method to your models that \
  allows you to configure and set up (most of) the important parameters you will need \
  to create multiple output video container formats (mp4, ogg, wmv, etc) from a single \
  uploaded source file. Uses the Zencoder API (zencoder.com) and (as of now) expects \
  you to have an S3 bucket where we can ask zencoder to place the generated files."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.1.0"
  s.add_dependency "aws-s3"
  s.add_dependency "zencoder"
  s.add_dependency "typhoeus"

  #s.add_development_dependency "rspec", "~> 2.6"
  s.add_development_dependency "rspec-rails", "~> 2.6"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "mocha"

end
