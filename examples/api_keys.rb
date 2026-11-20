# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

def create
  params = {
    name: "name"
  }
  key = Sendio::ApiKeys.create(params)
  puts key
end

def list
  keys = Sendio::ApiKeys.list
  puts keys
end

def list_paginated
  # List with pagination parameters
  paginated_keys = Sendio::ApiKeys.list({ limit: 10, after: "key_id_here" })
  puts "Paginated response:"
  puts paginated_keys
  puts "Has more: #{paginated_keys[:has_more]}" if paginated_keys[:has_more]
end

def remove
  key = Sendio::ApiKeys.create({name: "t"})
  puts "created api key id: #{key[:id]}"
  Sendio::ApiKeys.remove key[:id]
  puts "removed #{key[:id]}"
end

create
# list
# remove
