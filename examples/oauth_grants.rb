# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

def list
  grants = Sendio::OAuthGrants.list
  puts grants
end

def list_paginated
  paginated_grants = Sendio::OAuthGrants.list({ limit: 10, after: "grant_id_here" })
  puts "Paginated response:"
  puts paginated_grants
  puts "Has more: #{paginated_grants[:has_more]}" if paginated_grants[:has_more]
end

def revoke
  grant = Sendio::OAuthGrants.revoke("oauth_grant_id_here")
  puts grant
end

list
# list_paginated
# revoke
