# frozen_string_literal: true

module Sendio
  # domains api wrapper
  module Domains
    class << self
      # https://developer.send.io/docs/api
      #
      # Pass +capabilities: { receiving: "enabled" }+ to also receive email on
      # the domain (send.io then requires its MX record). Sending is always on:
      # +capabilities: { sending: "disabled" }+ is rejected with a 422.
      #
      # @example
      #   Sendio::Domains.create({ name: "example.com", capabilities: { receiving: "enabled" } })
      def create(params)
        path = "domains"
        Sendio::Request.new(path, params, "post").perform
      end

      # https://developer.send.io/docs/api
      #
      # +capabilities: { receiving: "disabled" }+ turns receiving off: send.io
      # stops accepting email for the domain and no longer requires its MX
      # record, so remove that record from your DNS. +capabilities: { receiving:
      # "enabled" }+ turns it back on and asks for the domain's MX record
      # (publish it to start receiving email). Sending can't be disabled.
      #
      # @example
      #   Sendio::Domains.update({ id: domain[:id], capabilities: { receiving: "disabled" } })
      def update(params)
        path = "domains/#{params[:id]}"
        Sendio::Request.new(path, params, "patch").perform
      end

      # https://developer.send.io/docs/api
      def get(domain_id = "")
        path = "domains/#{domain_id}"
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def list(params = {})
        path = Sendio::PaginationHelper.build_paginated_path("domains", params)
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def remove(domain_id = "")
        path = "domains/#{domain_id}"
        Sendio::Request.new(path, {}, "delete").perform
      end

      # https://developer.send.io/docs/api
      def verify(domain_id = "")
        path = "domains/#{domain_id}/verify"
        Sendio::Request.new(path, {}, "post").perform
      end
    end
  end
end
