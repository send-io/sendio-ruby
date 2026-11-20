# frozen_string_literal: true

require_relative "../lib/sendio"
require "stringio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

file = IO.read(File.join(File.dirname(__FILE__), "../resources/invoice.pdf"))

params = {
  "from": "Acme <onboarding@yourdomain.com>",
  "to": ["delivered@send.io"],
  "text": "heyo",
  "subject": "Hello with attachment",
  "attachments": [
    {
      "filename": "invoice.pdf", # local file
      "content": file.bytes # make sure to use .bytes() here
    },
    {
      "path": "https://example.com/invoice.pdf",
      "filename": "from_external_path.pdf"
    }
  ]
}

sent = Sendio::Emails.send(params)
puts sent

inline_attachment_params = {
  "from": "Acme <onboarding@yourdomain.com>",
  "to": ["delivered@send.io"],
  "html": "<p>This is an email with an <img width=100 height=40 src=\"cid:image\" /> embed image</p>",
  "subject": "Sendio Ruby SDK inline attachment example",
  "attachments": [
    {
      "path": "https://example.com/logo.png",
      "filename": "logo.png",
      "content_id": "image"
    }
  ]
}

sent = Sendio::Emails.send(inline_attachment_params)
puts sent