# frozen_string_literal: true

require "sendio"
require "sendio/mailer"

module Sendio
  # Main railtime class
  class Railtie < ::Rails::Railtie
    ActiveSupport.on_load(:action_mailer) do
      add_delivery_method :sendio, Sendio::Mailer
      ActiveSupport.run_load_hooks(:sendio_mailer, Sendio::Mailer)
    end
  end
end
