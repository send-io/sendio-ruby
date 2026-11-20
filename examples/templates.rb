# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

# Create a simple template
simple_params = {
  name: "welcome-email",
  html: "<strong>Welcome to our platform!</strong>"
}

template = Sendio::Templates.create(simple_params)
puts "Created template: #{template[:id]}"

# Create a template with variables
template_with_vars = {
  name: "personalized-welcome",
  html: "<strong>Hey, {{{NAME}}}, you are {{{AGE}}} years old.</strong>",
  variables: [
    {
      key: "NAME",
      type: "string",
      fallback_value: "user"
    },
    {
      key: "AGE",
      type: "number",
      fallback_value: 25
    }
  ]
}

template_advanced = Sendio::Templates.create(template_with_vars)
puts "Created template with variables: #{template_advanced[:id]}"

# Create a complete template with all optional fields
complete_params = {
  name: "complete-template",
  alias: "complete",
  from: "Acme <onboarding@yourdomain.com>",
  subject: "Welcome to Acme",
  reply_to: "support@send.io",
  html: "<h1>Hello {{{FIRST_NAME}}} {{{LAST_NAME}}}</h1><p>Your membership level: {{{TIER}}}</p>",
  text: "Hello {{{FIRST_NAME}}} {{{LAST_NAME}}}\n\nYour membership level: {{{TIER}}}",
  variables: [
    {
      key: "TIER",
      type: "string",
      fallback_value: "free"
    }
  ]
}

complete_template = Sendio::Templates.create(complete_params)
puts "Created complete template: #{complete_template[:id]}"
puts "Template object type: #{complete_template[:object]}"

# Get a template by ID
retrieved_template = Sendio::Templates.get(template[:id])
puts "\nRetrieved template by ID: #{retrieved_template[:id]}"
puts "Template name: #{retrieved_template[:name]}"
puts "Template status: #{retrieved_template[:status]}"
puts "Template HTML: #{retrieved_template[:html]}"

# Get a template by alias
retrieved_by_alias = Sendio::Templates.get("complete")
puts "\nRetrieved template by alias: #{retrieved_by_alias[:alias]}"
puts "Template ID: #{retrieved_by_alias[:id]}"
puts "Template from: #{retrieved_by_alias[:from]}"
puts "Template subject: #{retrieved_by_alias[:subject]}"

if retrieved_by_alias[:variables] && !retrieved_by_alias[:variables].empty?
  puts "Template variables:"
  retrieved_by_alias[:variables].each do |var|
    # Use string keys for nested objects
    puts "  - #{var['key']} (#{var['type']}): #{var['fallback_value']}"
  end
end

# Update a template by ID
update_params = {
  name: "updated-welcome-email",
  html: "<h1>Welcome!</h1><p>We're glad you're here, {{{NAME}}}!</p>",
  variables: [
    {
      key: "NAME",
      type: "string",
      fallback_value: "friend"
    }
  ]
}

updated_template = Sendio::Templates.update(template[:id], update_params)
puts "\nUpdated template: #{updated_template[:id]}"

# Verify the update by retrieving it again
verified = Sendio::Templates.get(template[:id])
puts "Updated template name: #{verified[:name]}"
puts "Updated template HTML: #{verified[:html]}"

# Update a template by alias
alias_update_params = {
  subject: "Welcome to Acme - Updated",
  from: "Acme Team <team@send.io>"
}

updated_by_alias = Sendio::Templates.update("complete", alias_update_params)
puts "\nUpdated template by alias: #{updated_by_alias[:id]}"

# Publish a template by ID
published_template = Sendio::Templates.publish(template[:id])
puts "\nPublished template: #{published_template[:id]}"

# Verify the template is published
published_status = Sendio::Templates.get(template[:id])
puts "Template status after publish: #{published_status[:status]}"

# Publish a template by alias
published_by_alias = Sendio::Templates.publish("complete")
puts "\nPublished template by alias: #{published_by_alias[:id]}"

# Check the published template
final_check = Sendio::Templates.get("complete")
puts "Final template status: #{final_check[:status]}"
puts "Published at: #{final_check[:published_at]}"

# Duplicate a template by ID
duplicated_template = Sendio::Templates.duplicate(template[:id])
puts "\nDuplicated template - New ID: #{duplicated_template[:id]}"

# Get the duplicated template to see its details
duplicated_details = Sendio::Templates.get(duplicated_template[:id])
puts "Duplicated template name: #{duplicated_details[:name]}"
puts "Duplicated template status: #{duplicated_details[:status]}"

# Duplicate a template by alias
duplicated_by_alias = Sendio::Templates.duplicate("complete")
puts "\nDuplicated template by alias - New ID: #{duplicated_by_alias[:id]}"

# Get details of the template duplicated from alias
alias_duplicate_details = Sendio::Templates.get(duplicated_by_alias[:id])
puts "Alias duplicate name: #{alias_duplicate_details[:name]}"
puts "Alias duplicate from: #{alias_duplicate_details[:from]}"
puts "Alias duplicate subject: #{alias_duplicate_details[:subject]}"

# List all templates
all_templates = Sendio::Templates.list
puts "\nListing all templates:"
puts "Total templates: #{all_templates[:data].length}"
puts "Has more: #{all_templates[:has_more]}"

all_templates[:data].each do |t|
  puts "  - #{t['name']} (#{t['id']}) - Status: #{t['status']}"
end

# List templates with pagination
paginated_templates = Sendio::Templates.list({ limit: 2 })
puts "\nListing templates with limit of 2:"
puts "Returned: #{paginated_templates[:data].length} templates"
puts "Has more: #{paginated_templates[:has_more]}"

# List templates after a specific ID
if paginated_templates[:data].length > 0
  first_id = paginated_templates[:data][0]['id']
  after_templates = Sendio::Templates.list({ limit: 2, after: first_id })
  puts "\nListing templates after ID #{first_id}:"
  puts "Returned: #{after_templates[:data].length} templates"
end

# Remove the duplicated template by ID
removed_template = Sendio::Templates.remove(duplicated_template[:id])
puts "\nRemoved template: #{removed_template[:id]}"
puts "Deleted: #{removed_template[:deleted]}"

# Remove the second duplicated template by its ID
removed_by_alias_dup = Sendio::Templates.remove(duplicated_by_alias[:id])
puts "\nRemoved duplicated template: #{removed_by_alias_dup[:id]}"
puts "Deleted: #{removed_by_alias_dup[:deleted]}"

# Verify templates were removed by listing again
final_list = Sendio::Templates.list
puts "\nFinal template count: #{final_list[:data].length}"
