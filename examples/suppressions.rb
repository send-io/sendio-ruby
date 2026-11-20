# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

def suppressions
  suppression = Sendio::Suppressions.add(email: "steve.wozniak@gmail.com")
  puts "Added suppression: #{suppression[:id]}"

  # List: filter by origin and paginate.
  list = Sendio::Suppressions.list(origin: "manual", limit: 10)
  list[:data].each do |entry|
    puts "#{entry["email"]} suppressed by #{entry["origin"]} (source: #{entry["source_id"] || "none"})"
  end

  # Get: the path segment accepts either the suppression ID or the email address.
  retrieved = Sendio::Suppressions.get("steve.wozniak@gmail.com")
  puts "Retrieved suppression #{retrieved[:id]} created at #{retrieved[:created_at]}"

  removed = Sendio::Suppressions.remove(suppression[:id])
  puts "Removed suppression: #{removed[:deleted]}"
end

def batch_suppressions
  added = Sendio::Suppressions::Batch.add(
    emails: ["steve.wozniak@gmail.com", "steve.jobs@gmail.com"]
  )
  puts "Added #{added[:data].length} suppressions"

  # Remove: pass either `emails` or `ids`, never both.
  removed = Sendio::Suppressions::Batch.remove(ids: added[:data].map { |entry| entry["id"] })
  puts "Removed #{removed[:data].length} suppressions"
end

suppressions
batch_suppressions
