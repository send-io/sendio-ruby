# frozen_string_literal: true

module Sendio
  # The Transactional module manages transactional emails (/transactional).
  #
  # A transactional email is a named, saved send of a published template: a sign-in code,
  # a password reset, a receipt. It stores the envelope (from, subject, preview text,
  # reply-to, and open and click tracking, off by default) and a template; the content is
  # always the template's published version at send time. Send it with Sendio::Emails.send
  # and :transactional_id, passing only the recipient and its :variables. A republish of the
  # template, or an update, reaches every send within 10 seconds.
  #
  # @example Create a transactional email, then send it
  #   tx = Sendio::Transactional.create(
  #     name: "Sign-in code",
  #     template_id: "signin-code",
  #     from: "Acme <security@yourdomain.com>",
  #     subject: "Your code is {{CODE}}"
  #   )
  #   Sendio::Emails.send({ transactional_id: tx[:id], to: "ada@example.com", variables: { CODE: "123456" } })
  module Transactional
    class << self
      # Create a transactional email
      #
      # @param params [Hash] The transactional email
      # @option params [String] :name 1 to 255 characters (required)
      # @option params [String] :template_id The id or alias of a published template (required)
      # @option params [String] :from The sender, on a verified sending domain (required)
      # @option params [String] :subject The subject; it may use the template's variables (required)
      # @option params [String] :preview_text The inbox preview text
      # @option params [String, Array<String>] :reply_to At most 50 addresses
      # @option params [Boolean] :track_opens Open tracking (default false)
      # @option params [Boolean] :track_clicks Click tracking (default false)
      # @param options [Hash] Request options: :idempotency_key makes a retried create
      #   return the first answer
      #
      # @return [Hash] The transactional email
      def create(params = {}, options: {})
        Sendio::Request.new("transactional", params, "post", options: options).perform
      end

      # List transactional emails, newest first
      #
      # @param params [Hash] Optional filters and pagination
      # @option params [Integer] :limit The maximum number of results (1-100)
      # @option params [String] :after The cursor for pagination
      # @option params [String] :before The cursor for pagination
      # @option params [String] :search Only those whose name or subject matches
      # @option params [String] :template_id Only those of this template (id or alias)
      #
      # @return [Hash] A list object whose :data holds the transactional emails
      def list(params = {})
        path = Sendio::PaginationHelper.build_paginated_path("transactional", params)
        Sendio::Request.new(path, {}, "get").perform
      end

      # Retrieve a transactional email, with the :variables of the template version its
      # sends use now
      #
      # @param transactional_id [String] The transactional email id (tx_...)
      #
      # @return [Hash] The transactional email
      def get(transactional_id = "")
        Sendio::Request.new("transactional/#{transactional_id}", {}, "get").perform
      end

      # Update a transactional email: only the keys given change
      #
      # @param params [Hash] The changes
      # @option params [String] :transactional_id The transactional email id (path only, required)
      # @option params [String] :expected_updated_at The :updated_at you read: when it changed
      #   since, the update raises a 409 conflict instead of overwriting that change
      #   (plus the fields of create; preview_text: "" and reply_to: [] clear them)
      #
      # @return [Hash] The updated transactional email
      def update(params = {})
        body = params.reject { |k, _| k.to_s == "transactional_id" }
        transactional_id = params[:transactional_id] || params["transactional_id"]
        Sendio::Request.new("transactional/#{transactional_id}", body, "patch").perform
      end

      # Delete a transactional email; sends of it then fail with 404. Its stats stay readable.
      #
      # @param transactional_id [String] The transactional email id (tx_...)
      #
      # @return [Hash] Confirmation object with :object, :id and :deleted
      def remove(transactional_id = "")
        Sendio::Request.new("transactional/#{transactional_id}", {}, "delete").perform
      end

      # Send a transactional email to 1 to 5 addresses now, with "[Test] " before the subject.
      # Tests are not counted in stats.
      #
      # @param transactional_id [String] The transactional email id (tx_...)
      # @param params [Hash] The test
      # @option params [String, Array<String>] :to 1 to 5 addresses (required)
      # @option params [Hash] :variables The template variables
      #
      # @return [Hash] The test email's :id
      def send_test(transactional_id = "", params = {})
        Sendio::Request.new("transactional/#{transactional_id}/test", params, "post").perform
      end

      # Read a transactional email's numbers in a period (the last 30 days by default)
      #
      # @param transactional_id [String] The transactional email id (tx_...)
      # @param params [Hash] Optional period
      # @option params [String] :from A date (2026-11-01) or an ISO 8601 time; at most 90 days before :to
      # @option params [String] :to A date or an ISO 8601 time
      # @option params [String] :timezone An IANA time zone (default UTC)
      # @option params [String] :version One template version: an id, or a version number
      # @option params [String] :granularity "daily" (the default) or "hourly"
      #
      # @return [Hash] The stats: :totals, :daily, :per_version and :top_links
      def stats(transactional_id = "", params = {})
        path = Sendio::PaginationHelper.build_paginated_path("transactional/#{transactional_id}/stats", params)
        Sendio::Request.new(path, {}, "get").perform
      end
    end
  end
end
