# frozen_string_literal: true

module Sendio
  module Contacts
    # Contact Imports API wrapper
    module Imports
      class << self
        #
        # Create a new contact import from a CSV file.
        #
        # @param params [Hash] the parameters
        # @option params [String, IO] :file CSV file content (required). Maximum size is 50MB.
        # @option params [Hash, String] :column_map optional mapping of contact fields to CSV columns.
        #   Accepts a Hash (will be JSON-encoded) or a pre-encoded JSON String.
        # @option params [String] :on_conflict optional conflict strategy: 'upsert' or 'skip' (default 'skip').
        # @option params [Array, String] :segments optional list of segment IDs to add contacts to.
        #   Accepts an Array of segment ID strings (will be JSON-encoded as [{"id":"..."}])
        #   or a pre-encoded JSON String.
        # @option params [Array, String] :topics optional list of topic subscription objects.
        #   Each element must be a Hash with `id` (String) and `subscription` ('opt_in' or 'opt_out').
        #   Accepts an Array of Hashes (will be JSON-encoded) or a pre-encoded JSON String.
        #
        # https://developer.send.io/docs/api
        def create(params)
          raise ArgumentError, "Missing required `file` field" if params[:file].nil?

          # Normalize segments: convert array of IDs to [{id: ...}] format
          if params[:segments].is_a?(Array)
            params = params.merge(segments: params[:segments].map { |s| s.is_a?(String) ? { id: s } : s })
          end

          Sendio::MultipartRequest.new("contacts/imports", params, "post").perform
        end

        #
        # Retrieve a single contact import by ID.
        #
        # @param id [String] the contact import ID (required)
        #
        # https://developer.send.io/docs/api
        def get(id)
          raise ArgumentError, "Missing required `id` field" if id.nil? || id.empty?

          Sendio::Request.new("contacts/imports/#{id}", {}, "get").perform
        end

        #
        # Retrieve a list of contact imports.
        #
        # @param params [Hash] optional filtering and pagination parameters
        # @option params [String] :status filter by status: 'queued', 'in_progress', 'completed', or 'failed'
        # @option params [Integer] :limit number of results to return
        # @option params [String] :after cursor for forward pagination
        # @option params [String] :before cursor for backward pagination
        #
        # https://developer.send.io/docs/api
        def list(params = {})
          path = Sendio::PaginationHelper.build_paginated_path("contacts/imports", params)
          Sendio::Request.new(path, {}, "get").perform
        end
      end
    end
  end
end
