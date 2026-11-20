# frozen_string_literal: true

module Sendio
  # Segments api wrapper
  module Segments
    class << self
      # https://developer.send.io/docs/api
      def create(params)
        path = "segments"
        Sendio::Request.new(path, params, "post").perform
      end

      # https://developer.send.io/docs/api
      def get(segment_id = "")
        path = "segments/#{segment_id}"
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def update(params = {})
        path = "segments/#{params[:segment_id]}"
        Sendio::Request.new(path, { name: params[:name] }, "patch").perform
      end

      # https://developer.send.io/docs/api
      def list(params = {})
        path = Sendio::PaginationHelper.build_paginated_path("segments", params)
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def remove(segment_id = "")
        path = "segments/#{segment_id}"
        Sendio::Request.new(path, {}, "delete").perform
      end
    end
  end
end
