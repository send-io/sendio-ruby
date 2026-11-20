# frozen_string_literal: true

# Version
require "sendio/version"

# Utils
require "httparty"
require "json"
require "cgi"
require "erb"
require "sendio/errors"
require "sendio/response"
require "sendio/client"
require "sendio/request"
require "sendio/multipart_request"
require "sendio/pagination_helper"

# API Operations
require "sendio/segments"
require "sendio/api_keys"
require "sendio/broadcasts"
require "sendio/batch"
require "sendio/contacts"
require "sendio/contacts/imports"
require "sendio/contacts/segments"
require "sendio/contacts/topics"
require "sendio/contact_properties"
require "sendio/domains"
require "sendio/emails"
require "sendio/templates"
require "sendio/emails/receiving"
require "sendio/emails/attachments"
require "sendio/emails/receiving/attachments"
require "sendio/logs"
require "sendio/mailboxes"
require "sendio/topics"
require "sendio/transactional"
require "sendio/webhooks"
require "sendio/oauth_grants"
require "sendio/automations"
require "sendio/automations/runs"
require "sendio/automations/templates"
require "sendio/events"
require "sendio/suppressions"
require "sendio/suppressions/batch"
require "sendio/usage"

# Rails
require "sendio/railtie" if defined?(Rails) && defined?(ActionMailer)
require "sendio/action_mailbox" if defined?(Rails) && defined?(ActionMailbox)

# Main Sendio module
module Sendio
  DEFAULT_BASE_URL = "https://api.send.io"

  class << self
    attr_accessor :api_key
    attr_writer :base_url

    # The API base URL, always returned with a trailing slash.
    # Resolution order: Sendio.base_url = "...", then ENV["SENDIO_BASE_URL"],
    # then https://api.send.io. A trailing slash is optional everywhere.
    def base_url
      url = @base_url.to_s.strip
      url = ENV["SENDIO_BASE_URL"].to_s.strip if url.empty?
      url = DEFAULT_BASE_URL if url.empty?
      "#{url.sub(%r{/+\z}, "")}/"
    end

    def configure
      yield self if block_given?
      true
    end
    alias config configure
  end

  # @deprecated Use Segments instead
  Audiences = Segments
end
