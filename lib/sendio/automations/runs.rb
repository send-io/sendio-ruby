# frozen_string_literal: true

module Sendio
  module Automations
    # Automation Runs api wrapper
    module Runs
      class << self
        # https://developer.send.io/docs/api
        def list(automation_id, params = {})
          base_path = "automations/#{automation_id}/runs"
          path = Sendio::PaginationHelper.build_paginated_path(base_path, params)
          Sendio::Request.new(path, {}, "get").perform
        end

        # https://developer.send.io/docs/api
        def get(automation_id, run_id)
          Sendio::Request.new("automations/#{automation_id}/runs/#{run_id}", {}, "get").perform
        end
      end
    end
  end
end
