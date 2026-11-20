# frozen_string_literal: true

module Sendio
  # Topics api wrapper
  module Topics
    class << self
      # https://developer.send.io/docs/api
      def create(params = {})
        path = "topics"
        Sendio::Request.new(path, params, "post").perform
      end

      # https://developer.send.io/docs/api
      def get(topic_id = "")
        path = "topics/#{topic_id}"
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def update(params = {})
        path = "topics/#{params[:topic_id]}"
        Sendio::Request.new(path, params, "patch").perform
      end

      # https://developer.send.io/docs/api
      def list(params = {})
        path = Sendio::PaginationHelper.build_paginated_path("topics", params)
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def remove(topic_id = "")
        path = "topics/#{topic_id}"
        Sendio::Request.new(path, {}, "delete").perform
      end
    end
  end
end
