# frozen_string_literal: true

module Sendio
  # logs api wrapper
  module Logs
    class << self
      # https://developer.send.io/docs/api
      def get(log_id = "")
        path = "logs/#{log_id}"
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def list(params = {})
        path = Sendio::PaginationHelper.build_paginated_path("logs", params)
        Sendio::Request.new(path, {}, "get").perform
      end
    end
  end
end
