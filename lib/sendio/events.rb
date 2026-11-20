# frozen_string_literal: true

module Sendio
  # events api wrapper
  module Events
    class << self
      # https://developer.send.io/docs/api
      def create(params = {})
        Sendio::Request.new("events", params, "post").perform
      end

      # https://developer.send.io/docs/api
      # identifier can be a UUID or an event name (e.g. "user.signed_up")
      def get(identifier = "")
        path = "events/#{CGI.escape(identifier.to_s)}"
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def update(params = {})
        identifier = params[:identifier]
        path = "events/#{CGI.escape(identifier.to_s)}"
        payload = params.reject { |k, _| k == :identifier }
        Sendio::Request.new(path, payload, "patch").perform
      end

      # https://developer.send.io/docs/api
      # identifier can be a UUID or an event name (e.g. "user.signed_up")
      def remove(identifier = "")
        path = "events/#{CGI.escape(identifier.to_s)}"
        Sendio::Request.new(path, {}, "delete").perform
      end

      # https://developer.send.io/docs/api
      def send(params = {})
        Sendio::Request.new("events/send", params, "post").perform
      end

      # https://developer.send.io/docs/api
      def list(params = {})
        path = Sendio::PaginationHelper.build_paginated_path("events", params)
        Sendio::Request.new(path, {}, "get").perform
      end
    end
  end
end
