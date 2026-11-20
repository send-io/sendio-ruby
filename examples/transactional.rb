# frozen_string_literal: true

require_relative "../lib/sendio"

raise if ENV["SENDIO_API_KEY"].nil?

Sendio.api_key = ENV["SENDIO_API_KEY"]

def create
  # The template must be published; the From must be on a verified sending domain.
  tx = Sendio::Transactional.create(
    {
      name: "Sign-in code",
      template_id: "signin-code",
      from: "Acme <security@yourdomain.com>",
      subject: "Your code is {{CODE}}"
    },
    options: { idempotency_key: "create-signin-code" }
  )
  puts tx
end

def send_email
  # Only the recipient and the template's variables: the transactional email sets the rest.
  email = Sendio::Emails.send(
    { transactional_id: "tx_id_here", to: "ada@example.com", variables: { CODE: "123456" } }
  )
  puts email
end

def list
  puts Sendio::Transactional.list({ search: "sign-in", limit: 10 })
end

def update
  tx = Sendio::Transactional.get("tx_id_here")
  # A 409 instead of overwriting a change made since it was read.
  puts Sendio::Transactional.update(
    { transactional_id: tx[:id], subject: "Your sign-in code is {{CODE}}", expected_updated_at: tx[:updated_at] }
  )
end

def send_test
  puts Sendio::Transactional.send_test("tx_id_here", { to: ["you@yourdomain.com"], variables: { CODE: "000000" } })
end

def stats
  puts Sendio::Transactional.stats("tx_id_here", { from: "2026-11-01", granularity: "daily" })
end

list
# create
# send_email
# update
# send_test
# stats
