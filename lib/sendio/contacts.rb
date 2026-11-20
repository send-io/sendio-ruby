# frozen_string_literal: true

module Sendio
  # Contacts api wrapper
  module Contacts
    class << self
      # https://developer.send.io/docs/api
      def create(params)
        if params[:audience_id]
          path = "audiences/#{params[:audience_id]}/contacts"
          # Audience-scoped contacts don't support properties
          payload = params.reject { |key, _| key == :properties }
        else
          path = "contacts"
          payload = params
        end
        Sendio::Request.new(path, payload, "post").perform
      end

      #
      # Retrieves a contact
      #
      # @param params [Hash] the parameters
      # @option params [String] :id either the contact id or contact's email (required)
      # @option params [String] :audience_id optional audience id to scope the operation
      #
      # @example Get contact by ID
      #   Sendio::Contacts.get(id: "contact_123")
      #
      # @example Get contact scoped to an audience
      #   Sendio::Contacts.get(id: "contact_123", audience_id: "aud_456")
      #
      # https://developer.send.io/docs/api
      def get(params = {})
        raise ArgumentError, "Missing `id` or `email` field" if params[:id].nil? && params[:email].nil?

        audience_id = params[:audience_id]
        contact_id = params[:id] || params[:email]
        path = if audience_id
                 "audiences/#{audience_id}/contacts/#{contact_id}"
               else
                 "contacts/#{contact_id}"
               end
        Sendio::Request.new(path, {}, "get").perform
      end

      #
      # List contacts
      #
      # @param params [Hash] optional parameters including pagination
      # @option params [String] :audience_id optional audience id to scope the operation
      # @option params [Integer] :limit number of records to return
      # @option params [String] :cursor pagination cursor
      #
      # @example List all contacts
      #   Sendio::Contacts.list
      #
      # @example List contacts with pagination
      #   Sendio::Contacts.list(limit: 10)
      #
      # @example List contacts scoped to a segment
      #   Sendio::Contacts.list(segment_id: "seg_456", limit: 10)
      #
      # @example List contacts scoped to an audience
      #   Sendio::Contacts.list(audience_id: "aud_456", limit: 10)
      #
      # https://developer.send.io/docs/api
      def list(params = {})
        path = if params[:audience_id]
                 audience_id = params[:audience_id]
                 Sendio::PaginationHelper.build_paginated_path("audiences/#{audience_id}/contacts",
                                                               params.except(:audience_id))
               elsif params[:segment_id]
                 segment_id = params[:segment_id]
                 Sendio::PaginationHelper.build_paginated_path("segments/#{segment_id}/contacts",
                                                               params.except(:segment_id))
               else
                 Sendio::PaginationHelper.build_paginated_path("contacts", params)
               end
        Sendio::Request.new(path, {}, "get").perform
      end

      #
      # Remove a contact
      #
      # @param params [Hash] the parameters
      # @option params [String] :id either the contact id or contact email (required)
      # @option params [String] :audience_id optional audience id to scope the operation
      #
      # @example Remove contact by ID
      #   Sendio::Contacts.remove(id: "contact_123")
      #
      # @example Remove contact scoped to an audience
      #   Sendio::Contacts.remove(id: "contact_123", audience_id: "aud_456")
      #
      # https://developer.send.io/docs/api
      def remove(params = {})
        raise ArgumentError, "Missing `id` or `email` field" if params[:id].nil? && params[:email].nil?

        audience_id = params[:audience_id]
        contact_id = params[:id] || params[:email]
        path = if audience_id
                 "audiences/#{audience_id}/contacts/#{contact_id}"
               else
                 "contacts/#{contact_id}"
               end
        Sendio::Request.new(path, {}, "delete").perform
      end

      #
      # Update a contact
      #
      # @param params [Hash] the contact params
      # https://developer.send.io/docs/api
      def update(params)
        raise ArgumentError, "Missing `id` or `email` field" if params[:id].nil? && params[:email].nil?

        contact_id = params[:id] || params[:email]
        if params[:audience_id]
          path = "audiences/#{params[:audience_id]}/contacts/#{contact_id}"
          # Audience-scoped contacts don't support properties
          payload = params.reject { |key, _| key == :properties }
        else
          path = "contacts/#{contact_id}"
          payload = params
        end
        Sendio::Request.new(path, payload, "patch").perform
      end
    end
  end
end
