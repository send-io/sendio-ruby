# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

params = {
  "from": "Acme <onboarding@yourdomain.com>",
  "to": ["delivered@send.io"],
  "subject": "Hello from Sendio (Ruby SDK) - Scheduled",
  "html": "<strong>Hello, from Sendio (Ruby SDK)</strong>",

  # ISO 8601 format, you can get that in Ruby with
  # DateTime.now.iso8601(3)
  "scheduled_at": "2024-09-05T11:52:01.858Z",
}

email = Sendio::Emails.send(params)
puts(email)

update_params = {
  "email_id": email[:id],
  "scheduled_at": "2024-11-05T11:52:01.858Z",
}

updated_email = Sendio::Emails.update(update_params)
puts(updated_email)

canceled = Sendio::Emails.cancel(updated_email[:id])
puts(canceled)