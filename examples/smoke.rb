# frozen_string_literal: true

# Live smoke test (not part of the unit tests). Sends ONE real email.
#
#   SENDIO_API_KEY=mx_... SENDIO_BASE_URL=https://api.send.io ruby -Ilib examples/smoke.rb
#
# Optional: SMOKE_FROM (default ada@compat-sdk.sendio-test.dev), SMOKE_TO (default delivered@send.io).

require_relative "../lib/sendio"

abort "SENDIO_API_KEY is not set" if ENV["SENDIO_API_KEY"].to_s.empty?

Sendio.api_key = ENV["SENDIO_API_KEY"]
puts "base_url: #{Sendio.base_url}"

sent = Sendio::Emails.send({
  from: ENV.fetch("SMOKE_FROM", "ada@compat-sdk.sendio-test.dev"),
  to: [ENV.fetch("SMOKE_TO", "delivered@send.io")],
  subject: "sendio-ruby #{Sendio::VERSION} smoke",
  html: "<p>sendio-ruby smoke test</p>"
})
puts "send: id=#{sent[:id]}"

got = Sendio::Emails.get(sent[:id])
puts "get: id=#{got[:id]} last_event=#{got[:last_event]} subject=#{got[:subject].inspect}"

domains = Sendio::Domains.list
puts "domains.list: #{domains[:data].length} domain(s): " \
     "#{domains[:data].map { |d| "#{d["name"] || d[:name]}(#{d["status"] || d[:status]})" }.join(", ")}"

keys = Sendio::ApiKeys.list
puts "api_keys.list: #{keys[:data].length} key(s)"

puts "SMOKE OK"
