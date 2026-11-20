# frozen_string_literal: true

module Sendio
  # Errors wrapper class
  # For more info: https://developer.send.io/docs/api
  class Error < StandardError
    # 4xx HTTP status code
    ClientError = Class.new(self)

    # 5xx HTTP status code
    ServerError = Class.new(self)

    # code 500
    InternalServerError = Class.new(ServerError)

    # code 422
    InvalidRequestError = Class.new(ServerError)

    # code 429
    class RateLimitExceededError < ServerError
      attr_reader :rate_limit_limit, :rate_limit_remaining, :rate_limit_reset, :retry_after

      def initialize(msg, code = nil, headers = {})
        super(msg, code, headers)
        @rate_limit_limit = headers["ratelimit-limit"]&.to_i
        @rate_limit_remaining = headers["ratelimit-remaining"]&.to_i
        @rate_limit_reset = headers["ratelimit-reset"]&.to_i
        @retry_after = headers["retry-after"]&.to_i
      end
    end

    # code 404
    NotFoundError = Class.new(ServerError)

    # code 402 insufficient_credits: the credit balance does not cover the
    # send, and nothing was sent. 429 also covers the quota names
    # daily_quota_exceeded, monthly_quota_exceeded,
    # subaccount_daily_quota_exceeded and subaccount_monthly_quota_exceeded.
    InsufficientCreditsError = Class.new(ClientError)

    ERRORS = {
      401 => Sendio::Error::InvalidRequestError,
      402 => Sendio::Error::InsufficientCreditsError,
      404 => Sendio::Error::NotFoundError,
      422 => Sendio::Error::InvalidRequestError,
      429 => Sendio::Error::RateLimitExceededError,
      400 => Sendio::Error::InvalidRequestError,
      500 => Sendio::Error::InternalServerError
    }.freeze

    attr_reader :headers

    def initialize(msg, code = nil, headers = {})
      super(msg)
      @code = code
      @headers = headers
    end
  end
end
