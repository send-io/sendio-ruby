# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

params = {
  "from": "Acme <onboarding@yourdomain.com>",
  "to": ["delivered@send.io"],
  "subject": "Hello from Sendio Ruby SDK",
  "text": "test",
  "tags": {
    "country": "br"
  }
}

# With Idempotency
puts "Sending email with Idempotency key:"
email = Sendio::Emails.send(params, options: { idempotency_key: "123" })
puts(email)

# Without Idempotency
puts "Sending email without Idempotency key:"
email = Sendio::Emails.send(params)
puts(email)

email = Sendio::Emails.get(email[:id])
puts(email[:id])

# List emails
puts "\n=== Listing Emails ==="

# List all emails with default limit (20)
puts "Listing all emails:"
emails = Sendio::Emails.list

puts "Total emails: #{emails[:data].length}"
puts "Has more: #{emails[:has_more]}"

emails[:data].each do |e|
  puts "  - #{e["id"]}: #{e["subject"]} (#{e["last_event"]})"
end

# List with custom limit
puts "\nListing with limit of 5:"
limited_emails = Sendio::Emails.list(limit: 5)

puts "Retrieved #{limited_emails[:data].length} emails"

# Example of pagination (if you have more than 5 emails)
if limited_emails["has_more"] && limited_emails["data"].last
  last_id = limited_emails["data"].last["id"]
  puts "\nGetting next page after ID: #{last_id}"
  next_page = Sendio::Emails.list(limit: 5, after: last_id)
  puts "Next page has #{next_page["data"].length} emails"
end

attachments = Sendio::Emails::Attachments.list(email_id: email[:id])

puts "Total attachments: #{attachments[:data].length}"
puts "Has more: #{attachments[:has_more]}"

if attachments[:data] && !attachments[:data].empty?
  attachments[:data].each do |attachment|
    puts "\n  Attachment:"
    puts "    ID: #{attachment[:id]}"
    puts "    Filename: #{attachment[:filename]}"
    puts "    Size: #{attachment[:size]} bytes"
    puts "    Content Type: #{attachment[:content_type]}"
  end

  # Retrieve details for the first attachment
  puts "\n=== Retrieving Single Attachment ==="
  attachment_id = attachments[:data].first[:id]
  puts "Retrieving attachment: #{attachment_id}"

  attachment = Sendio::Emails::Attachments.get(
    id: attachment_id,
    email_id: email[:id]
  )

  puts "\nAttachment Details:"
  puts "  ID: #{attachment[:id]}"
  puts "  Filename: #{attachment[:filename]}"
  puts "  Size: #{attachment[:size]} bytes"
  puts "  Content Type: #{attachment[:content_type]}"
  puts "  Download URL: #{attachment[:download_url]}"
  puts "  Expires At: #{attachment[:expires_at]}"
else
  puts "No attachments found for this email"
end
