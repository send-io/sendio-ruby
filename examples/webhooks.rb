# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

# Create a new webhook
create_params = {
  endpoint: "https://webhook.example.com/handler",
  events: ["email.sent", "email.delivered", "email.bounced"]
}

webhook = Sendio::Webhooks.create(create_params)
puts "Created webhook: #{webhook[:id]}"
puts "Signing secret: #{webhook[:signing_secret]}"

# Retrieve a specific webhook
retrieved_webhook = Sendio::Webhooks.get(webhook[:id])
puts "\nRetrieved webhook: #{retrieved_webhook[:id]}"
puts "Endpoint: #{retrieved_webhook[:endpoint]}"
puts "Status: #{retrieved_webhook[:status]}"
puts "Events: #{retrieved_webhook[:events]}"
puts "Created at: #{retrieved_webhook[:created_at]}"

# Update the webhook
update_params = {
  webhook_id: webhook[:id],
  endpoint: "https://new-webhook.example.com/handler",
  events: ["email.sent", "email.delivered"],
  status: "enabled"
}

updated_webhook = Sendio::Webhooks.update(update_params)
puts "\nUpdated webhook: #{updated_webhook[:id]}"

# Rotate the webhook signing secret
rotated_webhook = Sendio::Webhooks.rotate_signing_secret(webhook[:id])
puts "\nRotated signing secret for webhook: #{rotated_webhook[:id]}"
puts "New signing secret: #{rotated_webhook[:signing_secret]}"

# List all webhooks
webhooks = Sendio::Webhooks.list
puts "\nTotal webhooks: #{webhooks[:data].length}"
puts "Has more: #{webhooks[:has_more]}"

webhooks[:data].each_with_index do |wh, index|
  puts "\nWebhook #{index + 1}:"
  puts "  ID: #{wh['id']}"
  puts "  Endpoint: #{wh['endpoint']}"
  puts "  Status: #{wh['status']}"
  puts "  Events: #{(wh['events'] || []).join(', ')}"
  puts "  Created at: #{wh['created_at']}"
end

# Example with pagination
if webhooks[:data] && webhooks[:data].length > 0
  first_webhook_id = webhooks[:data].first['id']
  paginated_webhooks = Sendio::Webhooks.list({ limit: 10, after: first_webhook_id })
  puts "\nPaginated webhooks (limit 10, after #{first_webhook_id}):"
  puts "Total in page: #{paginated_webhooks[:data].length}"
  puts "Has more: #{paginated_webhooks[:has_more]}"
end

# List webhook events
webhook_events = Sendio::Webhooks.list_events(webhook[:id], limit: 10)
puts "\nWebhook events: #{webhook_events[:data].length}"
puts "Has more: #{webhook_events[:has_more]}"

if webhook_events[:data].any?
  event_id = webhook_events[:data].first["id"]

  # Retrieve a webhook event
  webhook_event = Sendio::Webhooks.get_event(webhook[:id], event_id)
  puts "\nWebhook event: #{webhook_event[:id]}"
  puts "Status: #{webhook_event[:status]}"

  # Replay a webhook event
  replayed_event = Sendio::Webhooks.replay_event(webhook[:id], event_id)
  puts "\nReplayed webhook event: #{replayed_event[:id]}"

  # List delivery attempts for a webhook event
  attempts = Sendio::Webhooks.list_event_attempts(webhook[:id], event_id, limit: 10)
  puts "\nDelivery attempts: #{attempts[:data].length}"
  puts "Has more: #{attempts[:has_more]}"
end

# Remove the webhook
removed_webhook = Sendio::Webhooks.remove(webhook[:id])
puts "\nRemoved webhook: #{removed_webhook[:id]}"
puts "Deleted: #{removed_webhook[:deleted]}"
