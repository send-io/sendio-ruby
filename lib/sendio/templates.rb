# frozen_string_literal: true

module Sendio
  # Templates api wrapper
  module Templates
    class << self
      # https://developer.send.io/docs/api
      def create(params = {})
        path = "templates"
        Sendio::Request.new(path, params, "post").perform
      end

      # https://developer.send.io/docs/api
      def get(template_id = "")
        path = "templates/#{template_id}"
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def update(template_id, params = {})
        path = "templates/#{template_id}"
        Sendio::Request.new(path, params, "patch").perform
      end

      # https://developer.send.io/docs/api
      def publish(template_id = "")
        path = "templates/#{template_id}/publish"
        Sendio::Request.new(path, {}, "post").perform
      end

      # https://developer.send.io/docs/api
      def duplicate(template_id = "")
        path = "templates/#{template_id}/duplicate"
        Sendio::Request.new(path, {}, "post").perform
      end

      # https://developer.send.io/docs/api
      def list(params = {})
        path = Sendio::PaginationHelper.build_paginated_path("templates", params)
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def remove(template_id = "")
        path = "templates/#{template_id}"
        Sendio::Request.new(path, {}, "delete").perform
      end
    end
  end
end
