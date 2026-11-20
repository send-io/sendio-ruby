# frozen_string_literal: true

module Sendio
  # The Mailboxes module manages mailboxes: real email accounts with an IMAP/SMTP login.
  #
  # @example Create a mailbox on a verified domain
  #   mailbox = Sendio::Mailboxes.create(address: "support@yourdomain.com")
  #   mailbox[:credentials] # shown once, when IMAP/SMTP is ready
  #
  # @example List mailboxes
  #   Sendio::Mailboxes.list
  #
  # @example Turn warmup off
  #   Sendio::Mailboxes.update(mailbox_id: "mbx_123", warmup_enabled: false)
  #
  # @example Reset the IMAP/SMTP password
  #   Sendio::Mailboxes.reset_password("mbx_123")
  #
  # @example Delete a mailbox
  #   Sendio::Mailboxes.remove("mbx_123")
  module Mailboxes
    class << self
      # Create a mailbox
      #
      # The domain must be verified. Raises Sendio::Error (409) if the address already exists.
      #
      # @param params [Hash] The mailbox parameters
      # @option params [String] :address The full address, e.g. "support@yourdomain.com"
      # @option params [String] :local_part The part before the "@" (with :domain_id, instead of :address)
      # @option params [String] :domain_id The domain ID (with :local_part)
      # @option params [String] :username For a free mailbox (no domain): the username
      # @option params [String] :org For a free mailbox: the organization (optional)
      # @option params [String] :display_name For a free mailbox: the display name (optional)
      #
      # @return [Hash] The mailbox object, plus :credentials (shown once) when IMAP/SMTP is ready.
      #   The password is also an API key for that mailbox; store it safely.
      def create(params = {})
        path = "mailboxes"
        Sendio::Request.new(path, params, "post").perform
      end

      # List all mailboxes (not paginated)
      #
      # @return [Hash] A list object whose :data holds the mailbox objects
      def list
        path = "mailboxes"
        Sendio::Request.new(path, {}, "get").perform
      end

      # Update a mailbox
      #
      # @param params [Hash] The mailbox update parameters
      # @option params [String] :mailbox_id The mailbox ID (required)
      # @option params [Boolean] :warmup_enabled Whether warmup is on (required)
      #
      # @return [Hash] The updated mailbox object
      def update(params = {})
        path = "mailboxes/#{params[:mailbox_id]}"
        Sendio::Request.new(path, { warmup_enabled: params[:warmup_enabled] }, "patch").perform
      end

      # Reset the IMAP/SMTP password of a mailbox
      #
      # The old password stops working. The new password is also an API key for that mailbox.
      #
      # @param mailbox_id [String] The mailbox ID
      #
      # @return [Hash] A mailbox_credentials object with :id, :address, :credentials and :note
      def reset_password(mailbox_id = "")
        path = "mailboxes/#{mailbox_id}/password"
        Sendio::Request.new(path, {}, "post").perform
      end

      # Delete a mailbox
      #
      # Removes the email account, and the agent inbox on it if there is one.
      #
      # @param mailbox_id [String] The mailbox ID
      #
      # @return [Hash] Confirmation object with :object, :id and :deleted
      def remove(mailbox_id = "")
        path = "mailboxes/#{mailbox_id}"
        Sendio::Request.new(path, {}, "delete").perform
      end
    end
  end
end
