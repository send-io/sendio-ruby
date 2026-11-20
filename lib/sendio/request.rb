# frozen_string_literal: true

module Sendio
  # This class is responsible for making the appropriate HTTP calls
  # and raising the specific errors based on the response.
  class Request
    # Base URL resolved when the gem is loaded (always ends with "/").
    # Kept for backwards compatibility; requests use Sendio.base_url, which
    # also honours runtime changes (Sendio.base_url = "...").
    env_base_url = ENV.fetch("SENDIO_BASE_URL", "").strip
    BASE_URL = "#{(env_base_url.empty? ? "https://api.send.io" : env_base_url).sub(%r{/+\z}, "")}/".freeze

    attr_accessor :body, :verb, :options

    def initialize(path = "", body = {}, verb = "POST", options: {})
      raise if (api_key = Sendio.api_key).nil?

      api_key = api_key.call if api_key.is_a?(Proc)

      @path = path
      @body = body
      @verb = verb
      @options = options
      @headers = {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "User-Agent" => "sendio-ruby:#{Sendio::VERSION}",
        "Authorization" => "Bearer #{api_key}"
      }

      set_idempotency_key
      set_batch_validation
    end

    # Performs the HTTP call
    def perform
      options = build_request_options
      resp = HTTParty.send(@verb.to_sym, "#{Sendio.base_url}#{@path}", options)

      check_json!(resp)
      data = process_response(resp)
      headers = extract_headers(resp)

      Sendio::Response.new(data, headers)
    end

    def handle_error!(data, resp = nil)
      code = data[:statusCode]
      body = data[:message]
      headers = resp.respond_to?(:headers) ? resp.headers : (data[:headers] || {})

      # get error from the known list of errors
      error_class = Sendio::Error::ERRORS[code] || Sendio::Error
      raise error_class.new(body, code, headers)
    end

    private

    def build_request_options
      options = { headers: @headers }

      if get_request_with_query?
        options[:query] = @body
      elsif !@body.empty?
        options[:body] = @body.to_json
      end

      options
    end

    def get_request_with_query?
      @verb.downcase == "get" && !@body.empty?
    end

    def process_response(resp)
      # Extract the parsed data from HTTParty response or use the hash directly (for tests/mocks)
      data = resp.respond_to?(:parsed_response) ? resp.parsed_response : resp
      data ||= {}
      data.transform_keys!(&:to_sym) unless resp.body.empty?
      handle_error!(data, resp) if error_response?(data)
      data
    end

    def error_response?(resp)
      resp[:statusCode] && resp[:statusCode] != 200 && resp[:statusCode] != 201
    end

    def set_idempotency_key
      # Only set idempotency key if the verb is POST for now.
      #
      # Does not set it if the idempotency_key is nil or empty
      if @verb.downcase == "post" && !@options[:idempotency_key].nil? && !@options[:idempotency_key].empty?
        @headers["Idempotency-Key"] = @options[:idempotency_key]
      end
    end

    def set_batch_validation
      # Set x-batch-validation header for batch emails
      # Supported values: 'strict' (default) or 'permissive'
      if @path == "emails/batch" && @options[:batch_validation]
        @headers["x-batch-validation"] = @options[:batch_validation]
      end
    end

    def check_json!(resp)
      if resp.body.is_a?(Hash)
        JSON.parse(resp.body.to_json)
      else
        JSON.parse(resp.body)
      end
    rescue JSON::ParserError, TypeError
      raise Sendio::Error::InternalServerError.new("send.io API returned an unexpected response", nil)
    end

    # Extract and normalize headers from the HTTParty response
    def extract_headers(resp)
      return {} unless resp.respond_to?(:headers)

      resp.headers.to_h.transform_keys { |k| k.to_s.downcase }
    end
  end
end
