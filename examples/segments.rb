# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

def example
  params = {
    name: "New Segment One",
  }
  segment = Sendio::Segments.create(params)
  puts "Created new segment: #{segment[:id]}"

  Sendio::Segments.get(segment[:id])
  puts "retrieved segment id: #{segment[:id]}"

  segments = Sendio::Segments.list
  puts segments

  # Example with pagination
  paginated_segments = Sendio::Segments.list({ limit: 5 })
  puts "Paginated segments (limit 5):"
  puts paginated_segments

  Sendio::Segments.remove segment[:id]
  puts "deleted #{segment[:id]}"
end

example