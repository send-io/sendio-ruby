# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

def example
  puts "Creating a string contact property..."
  string_property = Sendio::ContactProperties.create({
    key: "company_name",
    type: "string",
    fallback_value: "Acme Corp"
  })
  puts "Created property: #{string_property}"

  property_id = string_property[:id]

  puts "\nCreating a number contact property..."
  number_property = Sendio::ContactProperties.create({
    key: "age",
    type: "number",
    fallback_value: 0
  })
  puts "Created property: #{number_property}"

  puts "\nRetrieving contact property by ID..."
  retrieved_property = Sendio::ContactProperties.get(property_id)
  puts "Retrieved property: #{retrieved_property}"

  puts "\nListing all contact properties..."
  all_properties = Sendio::ContactProperties.list
  puts "All properties: #{all_properties}"

  puts "\nListing contact properties with pagination..."
  paginated_properties = Sendio::ContactProperties.list({ limit: 10 })
  puts "Paginated properties: #{paginated_properties}"

  puts "\nUpdating contact property..."
  updated_property = Sendio::ContactProperties.update({
    id: property_id,
    fallback_value: "Example Company"
  })
  puts "Updated property: #{updated_property}"

  puts "\nDeleting contact property..."
  deleted = Sendio::ContactProperties.remove(property_id)
  puts "Deleted property: #{deleted}"
end

example
