# frozen_string_literal: true

module ActionMailbox
  module Ingresses
    module Sendio
      # Ingests inbound emails delivered by send.io's +email.received+ webhook.
      #
      # send.io webhooks only carry the received email's metadata, so the full message
      # (including any attachments) is fetched from the send.io API before being enqueued
      # for routing. The webhook request is authenticated by verifying its Svix signature
      # against the webhook's signing secret, which is stored in the
      # +action_mailbox.sendio_signing_secret+ Rails credential or the
      # +SENDIO_INGRESS_SIGNING_SECRET+ environment variable.
      #
      # Returns:
      #
      # - <tt>204 No Content</tt> if an inbound email is successfully recorded and enqueued for
      #   routing, or if the event is not an +email.received+ event and was ignored
      # - <tt>401 Unauthorized</tt> if the request's signature could not be validated
      # - <tt>404 Not Found</tt> if Action Mailbox is not configured to accept inbound emails
      #   from Sendio
      # - <tt>422 Unprocessable Entity</tt> if the request's payload is malformed
      # - <tt>500 Server Error</tt> if the webhook signing secret is missing, the send.io API
      #   could not be reached, or one of the Active Record database, the Active Storage
      #   service, or the Active Job backend is misconfigured or unavailable
      class InboundEmailsController < ActionMailbox::BaseController
        before_action :authenticate

        def create
          return head :no_content unless email_received_event?
          return head :unprocessable_entity if email_id.nil?

          ActionMailbox::InboundEmail.create_and_extract_message_id! raw_email
          head :no_content
        rescue JSON::ParserError => e
          logger.error e.message
          head :unprocessable_entity
        end

        private

        def raw_email
          ::Sendio::ActionMailbox::MessageBuilder.new(email_id).raw_email
        end

        def email_received_event?
          event["type"] == "email.received"
        end

        def email_id
          event.dig("data", "email_id")
        end

        def event
          @event ||= JSON.parse(request.raw_post)
        end

        def authenticate
          head :unauthorized unless authenticated?
        end

        def authenticated?
          if signing_secret.present?
            verified_signature?
          else
            raise ArgumentError, <<~MESSAGE.squish
              Missing required Sendio webhook signing secret. Set action_mailbox.sendio_signing_secret
              in your application's encrypted credentials or provide the SENDIO_INGRESS_SIGNING_SECRET
              environment variable.
            MESSAGE
          end
        end

        def verified_signature?
          ::Sendio::Webhooks.verify(
            payload: request.raw_post,
            headers: {
              svix_id: request.headers["svix-id"],
              svix_timestamp: request.headers["svix-timestamp"],
              svix_signature: request.headers["svix-signature"]
            },
            webhook_secret: signing_secret
          )
        rescue RuntimeError
          false
        end

        def signing_secret
          Rails.application.credentials.dig(:action_mailbox, :sendio_signing_secret) ||
            ENV["SENDIO_INGRESS_SIGNING_SECRET"]
        end
      end
    end
  end
end
