# frozen_string_literal: true

module Sendio
  # broadcasts api wrapper
  module Broadcasts
    class << self
      # https://developer.send.io/docs/api
      # @note A draft needs no fields. With send: true, from, subject, an html or
      #   text body and an audience (segment_id, segment_ids or audience: "all")
      #   are required.
      # @note Accepted fields: name, from, subject, reply_to, html, text, preview_text,
      #   topic_id, segment_id, segment_ids, exclude_segment_ids, audience ("segments"
      #   or "all"), unsubscribe_scope ("all" or "list"), tracking (true/false),
      #   template_engine ("simple" or "handlebars"), template_id, template_version_id,
      #   send and scheduled_at. audience_id is deprecated - use segment_id instead.
      # @note template_id makes the broadcast from a published template (id or alias): it
      #   copies the version's content (template_version_id picks the version, default the
      #   one published now), and its subject, from, preview text and reply-to where the
      #   broadcast has none. Not with html, text or template_engine. Sendio::Broadcasts.get
      #   returns :unfillable_variables for such a broadcast; while it is not empty, sending
      #   is refused with a 422.
      # @note When send: true is passed, the broadcast is sent immediately instead of
      #   creating a draft. When using send: true, you can also include scheduled_at
      #   to schedule the broadcast. Passing scheduled_at without send: true is an error.
      def create(params = {})
        if params[:audience_id] && !params[:segment_id]
          warn "[DEPRECATION] Using audience_id in broadcasts is deprecated. Use segment_id instead."
        end
        path = "broadcasts"
        Sendio::Request.new(path, params, "post").perform
      end

      # https://developer.send.io/docs/api
      # @note Takes the create fields except send and scheduled_at; only the keys
      #   given are changed. The broadcast_id goes in the path, never in the body
      #   (once a broadcast is sending or sent, only name can be changed).
      #   audience_id is deprecated - use segment_id instead.
      # @note template_id: nil detaches the broadcast from its template (its content stays);
      #   template_version_id alone switches to another published version of it. Sending
      #   html, text or template_engine gives it its own content and detaches it too.
      def update(params = {})
        if params[:audience_id] && !params[:segment_id]
          warn "[DEPRECATION] Using audience_id in broadcasts is deprecated. Use segment_id instead."
        end
        broadcast_id, body = extract_broadcast_id(params)
        path = "broadcasts/#{broadcast_id}"
        Sendio::Request.new(path, body, "patch").perform
      end

      # https://developer.send.io/docs/api
      # @option params [String] :broadcast_id the broadcast to send (path only)
      # @option params [String] :scheduled_at when to send it (optional)
      def send(params = {})
        broadcast_id, body = extract_broadcast_id(params)
        path = "broadcasts/#{broadcast_id}/send"
        Sendio::Request.new(path, body, "post").perform
      end

      # https://developer.send.io/docs/api
      # @option params [Integer] :limit the maximum number of results to return (optional)
      # @option params [String] :after the cursor for pagination (optional)
      # @option params [String] :before the cursor for pagination (optional)
      # @option params [String] :status only broadcasts with this status (optional)
      # @option params [String] :segment_id only broadcasts sent to this segment (optional)
      # @option params [String] :search only broadcasts matching this text (optional)
      def list(params = {})
        path = Sendio::PaginationHelper.build_paginated_path("broadcasts", params)
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      def clicked_links(broadcast_id = "", params = {})
        path = Sendio::PaginationHelper.build_paginated_path("broadcasts/#{broadcast_id}/clicked-links", params)
        Sendio::Request.new(path, {}, "get").perform
      end

      def cancel(broadcast_id = "")
        path = "broadcasts/#{broadcast_id}/cancel"
        Sendio::Request.new(path, {}, "post").perform
      end

      # https://developer.send.io/docs/api
      # @note Creates a new draft with the same content as the source, named after it with " (copy)" appended.
      def duplicate(broadcast_id = "")
        path = "broadcasts/#{broadcast_id}/duplicate"
        Sendio::Request.new(path, {}, "post").perform
      end

      # https://developer.send.io/docs/api
      def remove(broadcast_id = "")
        path = "broadcasts/#{broadcast_id}"
        Sendio::Request.new(path, {}, "delete").perform
      end

      # https://developer.send.io/docs/api
      def get(broadcast_id = "")
        path = "broadcasts/#{broadcast_id}"
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      # @param broadcast_id [String] the broadcast id
      # @param params [Hash] the parameters
      # @option params [String] :type the recipient event type to filter by (required):
      #   sent, delivered, opened, clicked, bounced, complained, unsubscribed, suppressed
      # @option params [String] :email filter recipients by email address (optional)
      # @option params [String] :bounce_type filter bounced recipients by bounce type (optional,
      #   only valid when type is bounced): permanent, transient, undetermined
      # @option params [Integer] :limit the maximum number of results to return (optional)
      # @option params [String] :after the cursor for pagination (optional)
      # @option params [String] :before the cursor for pagination (optional)
      def recipients(broadcast_id = "", params = {})
        raise ArgumentError, "type is required" if params[:type].nil?

        base_path = "broadcasts/#{broadcast_id}/recipients"
        path = Sendio::PaginationHelper.build_paginated_path(base_path, params)
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      # @note How many contacts an audience reaches now, before anything is saved.
      # @option params [String] :segment_id a single segment (optional)
      # @option params [Array<String>] :segment_ids several segments (optional)
      # @option params [Array<String>] :exclude_segment_ids segments left out (optional)
      # @option params [String] :audience "segments" or "all" (optional)
      # @option params [String] :topic_id only contacts opted in to this topic (optional)
      # @return { object: "broadcast_estimate", recipients:, skipped: { invalid: } }
      def estimate(params = {})
        Sendio::Request.new("broadcasts/estimate", params, "post").perform
      end

      # https://developer.send.io/docs/api
      # @note Sends a test of the broadcast, subject prefixed [Test].
      # @param broadcast_id [String] the broadcast id
      # @param to [String, Array<String>] 1 to 5 addresses
      def test(broadcast_id = "", to = [])
        path = "broadcasts/#{broadcast_id}/test"
        Sendio::Request.new(path, { to: Array(to) }, "post").perform
      end

      # https://developer.send.io/docs/api
      def stats(broadcast_id = "")
        path = "broadcasts/#{broadcast_id}/stats"
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      # @note Saved versions of a broadcast, newest first.
      # @option params [Integer] :limit the maximum number of results to return (optional)
      # @option params [String] :after the cursor for pagination (optional)
      # @option params [String] :before the cursor for pagination (optional)
      def list_versions(broadcast_id = "", params = {})
        path = Sendio::PaginationHelper.build_paginated_path("broadcasts/#{broadcast_id}/versions", params)
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      # @param version [Integer, String] the version_number or version id
      def get_version(broadcast_id = "", version = "")
        path = "broadcasts/#{broadcast_id}/versions/#{version}"
        Sendio::Request.new(path, {}, "get").perform
      end

      # https://developer.send.io/docs/api
      # @note Only a version's label (name, comment) can change; its content is immutable.
      # @option params [String] :name the version name (optional)
      # @option params [String] :comment the version comment (optional)
      def update_version(broadcast_id = "", version = "", params = {})
        path = "broadcasts/#{broadcast_id}/versions/#{version}"
        Sendio::Request.new(path, params, "patch").perform
      end

      # https://developer.send.io/docs/api
      # @note Copies a version back into a draft or scheduled broadcast, saved as a new version.
      def restore_version(broadcast_id = "", version = "")
        path = "broadcasts/#{broadcast_id}/versions/#{version}/restore"
        Sendio::Request.new(path, {}, "post").perform
      end

      private

      # Splits the broadcast id (path) from the JSON body.
      def extract_broadcast_id(params)
        body = params.reject { |k, _| k.to_s == "broadcast_id" }
        [params[:broadcast_id] || params["broadcast_id"], body]
      end
    end
  end
end
