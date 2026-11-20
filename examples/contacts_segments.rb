# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

def example
  # Step 1: Create a segment
  puts "Creating a segment..."
  segment = Sendio::Segments.create(name: "Ruby SDK Test Segment")
  segment_id = segment[:id]
  puts "Created segment: #{segment_id}"

  # Step 2: Create a contact
  puts "\nCreating a contact..."
  contact_email = "test-#{Time.now.to_i}@example.com"
  contact = Sendio::Contacts.create(
    email: contact_email,
    first_name: "Test",
    last_name: "User"
  )
  contact_id = contact[:id]
  puts "Created contact: #{contact_id} (#{contact_email})"

  # Step 3: List all segments for the contact (should be empty initially)
  puts "\nListing segments for contact (should be empty)..."
  segments = Sendio::Contacts::Segments.list(contact_id: contact_id)
  puts "Contact segments: #{segments}"

  # Step 4: Add contact to the segment using contact_id
  puts "\nAdding contact to segment using contact_id..."
  result = Sendio::Contacts::Segments.add(
    contact_id: contact_id,
    segment_id: segment_id
  )
  puts "Added contact to segment: #{result}"

  # Step 5: List segments again (should now include our segment)
  puts "\nListing segments for contact (should now include the segment)..."
  segments = Sendio::Contacts::Segments.list(contact_id: contact_id)
  puts "Contact segments: #{segments}"

  # Step 6: You can also use email instead of contact_id
  puts "\nYou can also use email to list segments..."
  segments_by_email = Sendio::Contacts::Segments.list(email: contact_email)
  puts "Segments by email: #{segments_by_email}"

  # Step 6b: You can also use pagination parameters
  puts "\nYou can also use pagination parameters..."
  segments_paginated = Sendio::Contacts::Segments.list(
    contact_id: contact_id,
    limit: 10
  )
  puts "Segments with pagination: #{segments_paginated}"

  # Step 7: You can also list the contacts that are in a segment
  puts "\nListing contacts in the segment (should include the contact)..."
  contacts = Sendio::Contacts.list(segment_id: segment_id)
  puts "Contacts in the segment: #{contacts}"

  # Step 8: Remove contact from the segment
  puts "\nRemoving contact from segment..."
  removed = Sendio::Contacts::Segments.remove(
    contact_id: contact_id,
    segment_id: segment_id
  )
  puts "Removed contact from segment: #{removed}"

  # Step 9: Cleanup - remove contact and segment
  puts "\nCleaning up..."
  Sendio::Contacts.remove(id: contact_id)
  puts "Deleted contact: #{contact_id}"

  Sendio::Segments.remove(segment_id)
  puts "Deleted segment: #{segment_id}"

  puts "\n✓ Example completed successfully!"
end

example
