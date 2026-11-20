# frozen_string_literal: true

module Sendio
  # automations api wrapper
  module Automations
    class << self
      # https://developer.send.io/docs/api
      def create(params = {})
        Sendio::Request.new("automations", params, "post").perform
      end

      # https://developer.send.io/docs/api
      def get(automation_id = "")
        Sendio::Request.new("automations/#{automation_id}", {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def update(params = {})
        path = "automations/#{params[:automation_id]}"
        payload = params.reject { |k, _| k == :automation_id }
        Sendio::Request.new(path, payload, "patch").perform
      end

      # https://developer.send.io/docs/api
      def remove(automation_id = "")
        Sendio::Request.new("automations/#{automation_id}", {}, "delete").perform
      end

      # https://developer.send.io/docs/api
      def duplicate(automation_id = "")
        Sendio::Request.new("automations/#{automation_id}/duplicate", {}, "post").perform
      end

      # https://developer.send.io/docs/api
      def stop(automation_id = "")
        Sendio::Request.new("automations/#{automation_id}/stop", {}, "post").perform
      end

      # Create a disabled automation from an automation template.
      # see more: https://developer.send.io/docs/api
      #
      # @param params [Hash] :slug and :sender ({ from:, reply_to: }) are required; :topic_id is
      #   required for marketing templates. Optional :version, :name, :events
      #   ({ ref => { mode: "create" | "existing", name: } }) and :params ({ ref => value }).
      # @param options [Hash] Additional options for the request
      # @option options [String] :idempotency_key Optional idempotency key
      #
      # @example
      #   Sendio::Automations.create_from_template(
      #     { slug: "welcome-series", sender: { from: "Acme <hi@acme.com>" }, topic_id: "topic_123" },
      #     options: { idempotency_key: "welcome-1" }
      #   )
      def create_from_template(params, options: {})
        Sendio::Request.new("automations/from-template", params, "post", options: options).perform
      end

      # https://developer.send.io/docs/api
      def list(params = {})
        path = Sendio::PaginationHelper.build_paginated_path("automations", params)
        Sendio::Request.new(path, {}, "get").perform
      end
    end
  end
end
