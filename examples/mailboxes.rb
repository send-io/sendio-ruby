# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

def create
  # The domain must be verified.
  mailbox = Sendio::Mailboxes.create({ address: "support@yourdomain.com" })
  puts mailbox
  # Shown once, when IMAP/SMTP is ready. The password is also an API key for this mailbox.
  puts mailbox[:credentials] if mailbox[:credentials]
end

def list
  mailboxes = Sendio::Mailboxes.list
  puts mailboxes
end

def update
  mailbox = Sendio::Mailboxes.update({ mailbox_id: "mailbox_id_here", warmup_enabled: false })
  puts mailbox
end

def reset_password
  # The old password stops working.
  creds = Sendio::Mailboxes.reset_password("mailbox_id_here")
  puts creds[:credentials]
end

def remove
  # Removes the email account, and the agent inbox on it if there is one.
  Sendio::Mailboxes.remove("mailbox_id_here")
  puts "removed"
end

list
# create
# update
# reset_password
# remove
