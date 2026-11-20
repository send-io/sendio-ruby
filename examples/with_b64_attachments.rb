# frozen_string_literal: true

require_relative "../lib/sendio"
require "stringio"
require "base64"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

file = IO.read(File.join(File.dirname(__FILE__), "../resources/invoice.pdf"))

params = {
  "from": "Acme <onboarding@yourdomain.com>",
  "to": ["delivered@send.io"],
  "text": "heyo",
  "subject": "Hello with base 64 encoded attachment",
  "attachments": [
    {
      "filename": "invoice.pdf",
      "content": Base64.encode64(file).to_s
    },
  ]
}

sent = Sendio::Emails.send(params)
puts sent
