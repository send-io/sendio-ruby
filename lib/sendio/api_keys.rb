# frozen_string_literal: true

module Sendio
  # api keys api wrapper
  module ApiKeys
    class << self
      # https://developer.send.io/docs/api
      def create(params)
        path = "api-keys"
        Sendio::Request.new(path, params, "post").perform
      end

      # https://developer.send.io/docs/api
      def list(params = {})
        path = Sendio::PaginationHelper.build_paginated_path("api-keys", params)
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def remove(api_key_id = "")
        path = "api-keys/#{api_key_id}"
        Sendio::Request.new(path, {}, "delete").perform
      end

      # https://developer.send.io/docs/api
      def update(params)
        path = "api-keys/#{params[:id]}"
        Sendio::Request.new(path, { name: params[:name] }, "patch").perform
      end
    end
  end
end
