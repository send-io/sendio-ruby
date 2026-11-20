# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

def example
  csv_content = <<~CSV
    email,first_name,last_name
    alice@example.com,Alice,Smith
    bob@example.com,Bob,Jones
  CSV

  # Basic import
  result = Sendio::Contacts::Imports.create(
    file: csv_content,
    column_map: {
      "email" => "email",
      "first_name" => "first_name",
      "last_name" => "last_name"
    },
    on_conflict: "upsert"
  )
  puts "Import created: #{result}"
  import_id = result[:id]

  # Import with segments (object form, matching API reference)
  result_with_segments = Sendio::Contacts::Imports.create(
    file: csv_content,
    on_conflict: "upsert",
    segments: [{ id: "60a2ac5e-0774-456e-817d-ebf40f6dba31" }]
  )
  puts "Import with segments: #{result_with_segments}"

  # Import with topics
  result_with_topics = Sendio::Contacts::Imports.create(
    file: csv_content,
    on_conflict: "upsert",
    topics: [
      { id: "6eb54030-9489-4e9c-8de6-cd337c5fef1e", subscription: "opt_in" }
    ]
  )
  puts "Import with topics: #{result_with_topics}"

  # Get import status
  import = Sendio::Contacts::Imports.get(import_id)
  puts "Import status: #{import[:status]}"
  puts "Counts: #{import[:counts]}"

  # List imports
  imports = Sendio::Contacts::Imports.list
  puts "All imports: #{imports}"

  # List with status filter
  completed_imports = Sendio::Contacts::Imports.list(status: "completed")
  puts "Completed imports: #{completed_imports}"

  # List with pagination
  paginated = Sendio::Contacts::Imports.list(limit: 5)
  puts "Paginated imports: #{paginated}"
end

example
