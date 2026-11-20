# frozen_string_literal: true

module Sendio
  # oauth grants api wrapper
  module OAuthGrants
    class << self
      # https://developer.send.io/docs/api
      def list(params = {})
        path = Sendio::PaginationHelper.build_paginated_path("oauth/grants", params)
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def revoke(oauth_grant_id = "")
        path = "oauth/grants/#{oauth_grant_id}"
        Sendio::Request.new(path, {}, "delete").perform
      end
    end
  end
end
