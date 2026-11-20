# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

def create
  params = {
    name: "example@example.com",
    region: "us-east-1",
    custom_return_path: "outbound",
  }
  domain = Sendio::Domains.create(params)
  puts domain

  Sendio::Domains.remove domain[:id]
  puts "deleted #{domain[:id]}"
end

def create_with_tracking
  params = {
    name: "example@example.com",
    region: "us-east-1",
    tracking_subdomain: "links",
  }
  domain = Sendio::Domains.create(params)
  puts "open_tracking: #{domain[:open_tracking]}"
  puts "click_tracking: #{domain[:click_tracking]}"
  puts "tracking_subdomain: #{domain[:tracking_subdomain]}"
  puts domain

  Sendio::Domains.remove domain[:id]
  puts "deleted #{domain[:id]}"
end

def get
  domain = Sendio::Domains.create({name: "test"})
  puts "created domain id: #{domain[:id]}"

  retrieved = Sendio::Domains.get domain[:id]
  puts "retrieved domain: #{retrieved[:id]}"
  puts retrieved

  Sendio::Domains.remove retrieved[:id]
  puts "deleted #{retrieved[:id]}"
end

def update
  domain = Sendio::Domains.create({name: "test"})
  puts "created domain id: #{domain[:id]}"

  params = {
    id: domain[:id],
    open_tracking: false,
    click_tracking: false,
    tls: "enforced",
    tracking_subdomain: "links",
  }
  updated = Sendio::Domains.update(params)
  puts "updated domain: #{updated[:id]}"
  puts updated
end

def list
  domains = Sendio::Domains.list
  puts domains

  # Example with pagination
  paginated_domains = Sendio::Domains.list({ limit: 20, before: "domain_id_here" })
  puts "Paginated domains (limit 20, before domain_id_here):"
  puts paginated_domains
end

def remove
  domain = Sendio::Domains.create({name: "test"})
  puts "created domain id: #{domain[:id]}"
  Sendio::Domains.remove domain[:id]
  puts "deleted #{domain[:id]}"
end

def verify
  domain = Sendio::Domains.create({name: "test2"})
  puts "created domain id: #{domain[:id]}"

  Sendio::Domains.verify domain[:id]
  puts "verified #{domain[:id]}"

  Sendio::Domains.remove domain[:id]
  puts "deleted #{domain[:id]}"
end

create
create_with_tracking
get
update
list
remove
verify
