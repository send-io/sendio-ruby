# frozen_string_literal: true

module Sendio
  # Module responsible for wrapping email sending API
  module Emails
    class << self
      # Sends or schedules an email.
      # see more: https://developer.send.io/docs/api
      #
      # To send a transactional email (see Sendio::Transactional), pass :transactional_id,
      # :to and the template's :variables, and no :from, :subject, :reply_to, :html, :text
      # or :template: the transactional email sets them. :track_opens and :track_clicks
      # (true or false) override open and click tracking for one email.
      def send(params, options: {})
        path = "emails"
        Sendio::Request.new(path, params, "post", options: options).perform
      end

      # Retrieve a single email.
      # see more: https://developer.send.io/docs/api
      def get(email_id = "")
        path = "emails/#{email_id}"
        Sendio::Request.new(path, {}, "get").perform
      end

      # Update a scheduled email.
      # see more: https://developer.send.io/docs/api
      def update(params)
        path = "emails/#{params[:email_id]}"
        Sendio::Request.new(path, params, "patch").perform
      end

      # Cancel a scheduled email.
      # see more: https://developer.send.io/docs/api
      def cancel(email_id = "")
        path = "emails/#{email_id}/cancel"
        Sendio::Request.new(path, {}, "post").perform
      end

      # Create a shareable link for a sent or received email.
      #
      # @param email_id [String] The email id (sent or received).
      # @param params [Hash] Optional parameters
      # @option params [String] :expires_in Human-readable duration (e.g. "10m", "2 hours",
      #   "1 day"). Defaults to "48h" and is capped at 48 hours.
      def share(email_id, params = {})
        path = "emails/#{email_id}/share"
        Sendio::Request.new(path, params, "post").perform
      end

      # List emails with optional pagination.
      # see more: https://developer.send.io/docs/api
      #
      # @param options [Hash] Optional parameters for pagination
      # @option options [Integer] :limit Maximum number of emails to return (1-100, default 20)
      # @option options [String] :after Cursor for pagination (newer emails)
      # @option options [String] :before Cursor for pagination (older emails)
      def list(options = {})
        path = "emails"

        # Build query parameters, filtering out nil values
        query_params = {}
        query_params[:limit] = options[:limit] if options[:limit]
        query_params[:after] = options[:after] if options[:after]
        query_params[:before] = options[:before] if options[:before]

        Sendio::Request.new(path, query_params, "get").perform
      end

      # Retrieve email metrics.
      # see more: https://developer.send.io/docs/api
      #
      # @param options [Hash] Optional parameters for filtering and shaping the metrics response
      # @option options [String] :start_date ISO 8601 date/datetime. Defaults to 6 days before :end_date
      # @option options [String] :end_date ISO 8601 date/datetime. Defaults to now
      # @option options [String] :timezone IANA timezone, e.g. "America/New_York". Defaults to "UTC"
      # @option options [String] :granularity Bucket size used when :period is in :dimensions.
      #   One of "hourly", "daily", "weekly", "monthly". Defaults to "daily"
      # @option options [Array<String>] :metrics Metrics to include. Defaults to all metrics.
      # @option options [Array<String>] :dimensions Dimensions to break down by: "period", "domain",
      #   "email", "broadcast". Defaults to none, which returns totals only.
      # @option options [Array<String>] :domain_id Restrict to these sending domain IDs (max 100)
      # @option options [Array<String>] :email_id Restrict to these email IDs (max 100)
      # @option options [Array<String>] :broadcast_id Restrict to these broadcast IDs (max 100)
      def metrics(options = {})
        path = "emails/metrics"
        validate_metrics_options(options)
        Sendio::Request.new(path, build_metrics_query(options), "get").perform
      end

      private

      # The `email` and `broadcast` dimensions/filters are mutually exclusive.
      def validate_metrics_options(options)
        dimensions = Array(options[:dimensions])
        has_broadcast = dimensions.include?("broadcast") || !Array(options[:broadcast_id]).empty?
        has_email = dimensions.include?("email") || !Array(options[:email_id]).empty?

        return unless has_broadcast && has_email

        raise ArgumentError,
              "`broadcast`/`broadcast_id` cannot be combined with `email`/`email_id`"
      end

      # Builds the metrics query hash, filtering out nil values and joining
      # list-style params (metrics, dimensions, domain_id, email_id, broadcast_id)
      # into comma-separated strings as expected by the API.
      def build_metrics_query(options)
        query_params = {}

        %i[start_date end_date timezone granularity].each do |key|
          value = options[key]
          query_params[key] = value unless blank?(value)
        end

        %i[metrics dimensions domain_id email_id broadcast_id].each do |key|
          values = Array(options[key]).reject { |value| blank?(value) }
          query_params[key] = values.join(",") unless values.empty?
        end

        query_params
      end

      def blank?(value)
        value.nil? || value.to_s.empty?
      end
    end
  end
end
