# frozen_string_literal: true

module Sendio
  module Automations
    # Automation Templates api wrapper (ready-made automations you can create from)
    module Templates
      class << self
        # List the automation template catalog. Not paginated.
        # see more: https://developer.send.io/docs/api
        #
        # @param params [Hash] Optional parameters
        # @option params [String] :category Only templates in this category: "onboarding",
        #   "billing", "ecommerce", "engagement", "lead_capture", "appointments", "events",
        #   "education", "account", "nonprofit" or "internal"
        def list(params = {})
          query_params = {}
          query_params[:category] = params[:category] if params[:category]
          Sendio::Request.new("automation-templates", query_params, "get").perform
        end

        # Retrieve one automation template in full (how_it_works, events with schemas,
        # emails and params).
        # see more: https://developer.send.io/docs/api
        def get(slug)
          Sendio::Request.new("automation-templates/#{ERB::Util.url_encode(slug.to_s)}", {}, "get").perform
        end
      end
    end
  end
end
