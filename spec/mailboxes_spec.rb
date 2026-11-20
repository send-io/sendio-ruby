# frozen_string_literal: true

RSpec.describe "Mailboxes" do
  let(:mailbox_id) { "4b2f6a2e-0f3c-4c55-9d8e-6b1a2c3d4e5f" }

  let(:credentials) do
    {
      "username" => "support@example.com",
      "password" => "mbx_secret",
      "imap" => { "host" => "imap.send.io", "port" => 993, "security" => "ssl" },
      "smtp" => { "host" => "smtp.send.io", "port" => 587, "security" => "starttls" }
    }
  end

  let(:mailbox) do
    {
      "object" => "mailbox",
      "id" => mailbox_id,
      "address" => "support@example.com",
      "kind" => "normal",
      "agent_inbox_id" => nil,
      "imap_smtp" => "ready",
      "domain_id" => "d91cd9bd-1176-453e-8fc1-35364d380206",
      "domain" => "example.com",
      "warmup_enabled" => true,
      "warmup_changed_at" => nil,
      "created_at" => "2026-10-20T10:00:00Z",
      "sent" => 12,
      "sent_total" => 40,
      "delivered" => 11,
      "bounced" => 1,
      "complained" => 0,
      "last_sent_at" => "2026-10-22T09:00:00Z",
      "health" => "healthy"
    }
  end

  before do
    Sendio.configure do |config|
      config.api_key = "mx_123"
    end
  end

  # Stubs HTTParty and checks the verb, URL and JSON body sent on the wire.
  def expect_http(verb, path, body: nil, returns: {})
    allow(returns).to receive(:body).and_return(returns)
    expect(HTTParty).to receive(:send) do |sent_verb, url, options|
      expect(sent_verb).to eql(verb)
      expect(url).to eql("#{Sendio.base_url}#{path}")
      if body.nil?
        expect(options).not_to have_key(:body)
      else
        expect(JSON.parse(options[:body])).to eql(body)
      end
      returns
    end
  end

  describe "list" do
    it "should GET /mailboxes and return the mailboxes" do
      expect_http(:get, "mailboxes", returns: { "object" => "list", "has_more" => false, "data" => [mailbox] })

      result = Sendio::Mailboxes.list

      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to be(false)
      expect(result[:data].length).to eql(1)
      expect(result[:data].first["address"]).to eql("support@example.com")
      expect(result[:data].first["health"]).to eql("healthy")
    end
  end

  describe "create" do
    it "should POST /mailboxes and return the mailbox with credentials" do
      expect_http(:post, "mailboxes",
                  body: { "address" => "support@example.com" },
                  returns: mailbox.merge("credentials" => credentials))

      result = Sendio::Mailboxes.create(address: "support@example.com")

      expect(result[:id]).to eql(mailbox_id)
      expect(result[:object]).to eql("mailbox")
      expect(result[:credentials]["password"]).to eql("mbx_secret")
      expect(result[:credentials]["imap"]["port"]).to eql(993)
      expect(result[:credentials]["smtp"]["security"]).to eql("starttls")
    end

    it "should send local_part and domain_id" do
      params = { local_part: "support", domain_id: "d91cd9bd-1176-453e-8fc1-35364d380206" }
      expect_http(:post, "mailboxes",
                  body: { "local_part" => "support", "domain_id" => "d91cd9bd-1176-453e-8fc1-35364d380206" },
                  returns: mailbox)

      expect(Sendio::Mailboxes.create(params)[:credentials]).to be_nil
    end

    it "should raise when the address already exists" do
      resp = { "statusCode" => 409, "name" => "conflict", "message" => "Mailbox already exists" }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      expect { Sendio::Mailboxes.create(address: "support@example.com") }
        .to raise_error(Sendio::Error, /Mailbox already exists/)
    end
  end

  describe "update" do
    it "should PATCH /mailboxes/:id with warmup_enabled false" do
      expect_http(:patch, "mailboxes/#{mailbox_id}",
                  body: { "warmup_enabled" => false },
                  returns: mailbox.merge("warmup_enabled" => false))

      result = Sendio::Mailboxes.update(mailbox_id: mailbox_id, warmup_enabled: false)

      expect(result[:id]).to eql(mailbox_id)
      expect(result[:warmup_enabled]).to be(false)
    end

    it "should send warmup_enabled true" do
      expect_http(:patch, "mailboxes/#{mailbox_id}", body: { "warmup_enabled" => true }, returns: mailbox)

      expect(Sendio::Mailboxes.update(mailbox_id: mailbox_id, warmup_enabled: true)[:warmup_enabled]).to be(true)
    end
  end

  describe "reset_password" do
    it "should POST /mailboxes/:id/password and return the new credentials" do
      resp = {
        "object" => "mailbox_credentials",
        "id" => mailbox_id,
        "address" => "support@example.com",
        "credentials" => credentials,
        "note" => "The old password no longer works."
      }
      expect_http(:post, "mailboxes/#{mailbox_id}/password", returns: resp)

      result = Sendio::Mailboxes.reset_password(mailbox_id)

      expect(result[:object]).to eql("mailbox_credentials")
      expect(result[:address]).to eql("support@example.com")
      expect(result[:credentials]["username"]).to eql("support@example.com")
      expect(result[:credentials]["password"]).to eql("mbx_secret")
      expect(result[:note]).to eql("The old password no longer works.")
    end
  end

  describe "remove" do
    it "should DELETE /mailboxes/:id" do
      expect_http(:delete, "mailboxes/#{mailbox_id}",
                  returns: { "object" => "mailbox", "id" => mailbox_id, "deleted" => true })

      result = Sendio::Mailboxes.remove(mailbox_id)

      expect(result[:object]).to eql("mailbox")
      expect(result[:id]).to eql(mailbox_id)
      expect(result[:deleted]).to be(true)
    end
  end
end
