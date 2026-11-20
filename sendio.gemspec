# frozen_string_literal: true

require_relative "lib/sendio/version"

Gem::Specification.new do |spec|
  spec.name          = "sendio"
  spec.version       = Sendio::VERSION
  spec.summary       = "The official Ruby and Rails SDK for send.io"
  spec.description   = "Send and manage email with the send.io API from Ruby and Rails " \
                       "(ActionMailer delivery method included)."
  spec.homepage      = "https://send.io"
  spec.license       = "MIT"

  spec.author        = "send.io"
  spec.email         = "support@send.io"

  spec.metadata = {
    "homepage_uri" => "https://send.io",
    "documentation_uri" => "https://developer.send.io/docs/api",
    "rubygems_mfa_required" => "true"
  }

  spec.files         = Dir["*.{md,txt}", "LICENSE", "NOTICE", "{app,lib}/**/*"]
  spec.require_path  = "lib"
  spec.required_ruby_version = ">= 3.2"
  spec.add_dependency "base64"
  spec.add_dependency "httparty", ">= 0.22.0"
end
