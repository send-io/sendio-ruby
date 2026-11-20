# frozen_string_literal: true

require "rails/engine"

module Sendio
  module ActionMailbox
    # Rails engine that routes send.io's +email.received+ webhooks to the
    # Action Mailbox ingress controller.
    class Engine < ::Rails::Engine
      initializer "sendio.action_mailbox.routes" do |app|
        app.routes.append do
          post "/rails/action_mailbox/sendio/inbound_emails",
               to: "action_mailbox/ingresses/sendio/inbound_emails#create",
               as: :rails_sendio_inbound_emails
        end
      end
    end
  end
end
