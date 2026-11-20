# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

params = [
  {
    "from": "Acme <onboarding@yourdomain.com>",
    "to": ["delivered@send.io"],
    "subject": "hey",
    "html": "<strong>hello, world!</strong>",
  },
  {
    "from": "Acme <onboarding@yourdomain.com>",
    "to": ["delivered@send.io"],
    "subject": "hello",
    "html": "<strong>hello, world!</strong>",
  },
]

# Send a batch of emails without Idempotency key
emails = Sendio::Batch.send(params)
puts "Emails sent without Idempotency key:"
puts(emails)

# Send a batch of emails with Idempotency key
emails = Sendio::Batch.send(params, options: { idempotency_key: "af67ff1cdf3cdf1" })
puts "Emails sent with Idempotency key:"
puts(emails)

# Example with batch_validation: permissive
# This will send valid emails and return errors for invalid ones
params_with_invalid = [
  {
    "from": "Acme <onboarding@yourdomain.com>",
    "to": ["delivered@send.io"],
    "subject": "Valid email",
    "html": "<strong>This email is valid!</strong>",
  },
  {
    "from": "Acme <onboarding@yourdomain.com>",
    "to": ["invalid-email"],  # Invalid email format
    "subject": "Invalid email",
    "html": "<strong>This email has an invalid recipient!</strong>",
  },
]

# Send batch with permissive validation mode
# This will send the valid email and return error details for the invalid one
emails = Sendio::Batch.send(params_with_invalid, options: { batch_validation: "permissive" })
puts "\nEmails sent with permissive validation mode:"
puts "Successful emails:"
puts emails[:data] if emails[:data]
puts "Errors:"
puts emails[:errors] if emails[:errors]

# Send batch with strict validation mode (default behavior)
# This will fail the entire batch if any email is invalid
begin
  emails = Sendio::Batch.send(params_with_invalid, options: { batch_validation: "strict" })
  puts "\nEmails sent with strict validation mode:"
  puts(emails)
rescue => e
  puts "\nStrict validation mode failed as expected:"
  puts "Error: #{e.message}"
end