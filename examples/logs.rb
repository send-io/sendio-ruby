# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

def get_log
  log = Sendio::Logs.get("3d4a472d-bc6d-4dd2-aa9d-d3d11b549e55")
  puts log
end

def list
  logs = Sendio::Logs.list
  puts logs
end

def list_paginated
  logs = Sendio::Logs.list({ limit: 10, after: "log_id_here" })
  puts logs
  puts "Has more: #{logs[:has_more]}" if logs[:has_more]
end

get_log
list
# list_paginated
