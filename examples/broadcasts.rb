# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

# replace with an existing segment id
segment_id = "78b8d3bc-a55a-45a3-aee6-6ec0a5e13d7e"

create_params = {
  from: "Acme <onboarding@yourdomain.com>",
  subject: "Hello from Ruby SDK",
  segment_id: segment_id,
  text: "Hello, how are you?",
  name: "Hello from Ruby SDK",
}

broadcast = Sendio::Broadcasts.create(create_params)
puts "created broadcast: #{broadcast[:id]}"

# Example using deprecated audience_id (still works for backwards compatibility)
create_params_deprecated = {
  from: "Acme <onboarding@yourdomain.com>",
  subject: "Hello from Ruby SDK (deprecated audience_id)",
  audience_id: segment_id, # deprecated: use segment_id instead
  text: "This example shows audience_id still works",
  name: "Broadcast with deprecated audience_id",
}

broadcast_deprecated = Sendio::Broadcasts.create(create_params_deprecated)
puts "created broadcast with deprecated audience_id: #{broadcast_deprecated[:id]}"

# Clean up the deprecated example if it's in draft status
retrieved_deprecated = Sendio::Broadcasts.get(broadcast_deprecated[:id])
if retrieved_deprecated[:status] == 'draft'
  Sendio::Broadcasts.remove(broadcast_deprecated[:id])
  puts "removed deprecated example broadcast: #{broadcast_deprecated[:id]}"
end

update_params = {
  broadcast_id: broadcast[:id],
  name: "Hello from Ruby SDK - updated",
}

updated_broadcast = Sendio::Broadcasts.update(update_params)
puts "updated broadcast: #{updated_broadcast[:id]}"

send_params = {
  broadcast_id: broadcast[:id],
  scheduled_at: "in 1 min",
}

sent_broadcast = Sendio::Broadcasts.send(send_params)
puts "sent broadcast: #{sent_broadcast[:id]}"

broadcasts = Sendio::Broadcasts.list
puts broadcasts

# Example with pagination - only demonstrate if has_more is true
if broadcasts[:has_more]
  # In real usage, you'd use the cursor from the previous response
  # For this example, we just show pagination with limit
  paginated_broadcasts = Sendio::Broadcasts.list({ limit: 5 })
  puts "\nPaginated broadcasts (limit 5):"
  puts paginated_broadcasts
else
  puts "\nNo more broadcasts to paginate through"
end

retrieved = Sendio::Broadcasts.get(broadcast[:id])
puts "retrieved #{retrieved[:id]}"
puts "html: #{retrieved[:html]}"
puts "text: #{retrieved[:text]}"

if retrieved[:status] == 'draft'
  Sendio::Broadcasts.remove(broadcast[:id])
  puts "removed #{broadcast[:id]}"
else
  puts 'Cannot remove a broadcast that is not in draft status'
end