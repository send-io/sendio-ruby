# frozen_string_literal: true

RSpec.describe "Transactional" do
  let(:tx_id) { "tx_2fQk8Jv0Zr4mN7pB1sXyA9cDe3H" }

  let(:transactional_email) do
    {
      "object" => "transactional_email",
      "id" => tx_id,
      "name" => "Sign-in code",
      "template_id" => "9c3e1f4a-1111-4222-8333-944455556666",
      "template_name" => "Sign-in",
      "template_alias" => "signin-code",
      "template_deleted" => false,
      "published_version_id" => "0d3e1f4a-1111-4222-8333-944455556666",
      "published_version_number" => 3,
      "from" => "Acme <security@acme.test>",
      "subject" => "Your code is {{CODE}}",
      "preview_text" => nil,
      "reply_to" => [],
      "track_opens" => false,
      "track_clicks" => false,
      "created_via" => "api",
      "created_at" => "2026-11-16T09:00:00.123456+00:00",
      "updated_at" => "2026-11-16T09:00:00.123456+00:00"
    }
  end

  before do
    Sendio.configure do |config|
      config.api_key = "mx_123"
    end
  end

  # Stubs HTTParty and checks the verb, URL, JSON body and Idempotency-Key header sent on the wire.
  def expect_http(verb, path, body: nil, idempotency_key: nil, returns: {})
    allow(returns).to receive(:body).and_return(returns)
    expect(HTTParty).to receive(:send) do |sent_verb, url, options|
      expect(sent_verb).to eql(verb)
      expect(url).to eql("#{Sendio.base_url}#{path}")
      if body.nil?
        expect(options).not_to have_key(:body)
      else
        expect(JSON.parse(options[:body])).to eql(body)
      end
      expect(options[:headers]["Idempotency-Key"]).to eql(idempotency_key)
      returns
    end
  end

  describe "create" do
    it "should POST /transactional with the fields and the idempotency key" do
      expect_http(:post, "transactional",
                  body: {
                    "name" => "Sign-in code",
                    "template_id" => "signin-code",
                    "from" => "Acme <security@acme.test>",
                    "subject" => "Your code is {{CODE}}",
                    "track_opens" => false
                  },
                  idempotency_key: "create-signin",
                  returns: transactional_email)

      tx = Sendio::Transactional.create(
        {
          name: "Sign-in code",
          template_id: "signin-code",
          from: "Acme <security@acme.test>",
          subject: "Your code is {{CODE}}",
          track_opens: false
        },
        options: { idempotency_key: "create-signin" }
      )
      expect(tx[:id]).to eql(tx_id)
      expect(tx[:published_version_number]).to eql(3)
      expect(tx[:track_clicks]).to be(false)
    end
  end

  describe "list" do
    it "should GET /transactional with the filters and paging" do
      expect_http(:get, "transactional?limit=10&after=#{tx_id}&search=sign+in&template_id=signin-code",
                  returns: { "object" => "list", "has_more" => false, "data" => [transactional_email] })

      list = Sendio::Transactional.list({ limit: 10, after: tx_id, search: "sign in", template_id: "signin-code" })
      expect(list[:data].first["id"]).to eql(tx_id)
    end

    it "should GET /transactional without a query" do
      expect_http(:get, "transactional", returns: { "object" => "list", "has_more" => false, "data" => [] })
      Sendio::Transactional.list
    end
  end

  describe "get" do
    it "should GET /transactional/:id" do
      expect_http(:get, "transactional/#{tx_id}", returns: transactional_email)
      expect(Sendio::Transactional.get(tx_id)[:subject]).to eql("Your code is {{CODE}}")
    end
  end

  describe "update" do
    it "should PATCH /transactional/:id with the changes but not the id" do
      expect_http(:patch, "transactional/#{tx_id}",
                  body: {
                    "subject" => "Your sign-in code",
                    "preview_text" => "",
                    "reply_to" => [],
                    "track_clicks" => true,
                    "expected_updated_at" => "2026-11-16T09:00:00.123456+00:00"
                  },
                  returns: transactional_email)

      Sendio::Transactional.update(
        {
          transactional_id: tx_id,
          subject: "Your sign-in code",
          preview_text: "",
          reply_to: [],
          track_clicks: true,
          expected_updated_at: "2026-11-16T09:00:00.123456+00:00"
        }
      )
    end

    it "should raise on a 409 conflict" do
      resp = { statusCode: 409, name: "conflict", message: "Someone else changed it." }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      expect do
        Sendio::Transactional.update(
          { transactional_id: tx_id, name: "n", expected_updated_at: "2026-01-01T00:00:00Z" }
        )
      end.to raise_error(Sendio::Error)
    end
  end

  describe "remove" do
    it "should DELETE /transactional/:id" do
      expect_http(:delete, "transactional/#{tx_id}",
                  returns: { "object" => "transactional_email", "id" => tx_id, "deleted" => true })
      expect(Sendio::Transactional.remove(tx_id)[:deleted]).to be(true)
    end
  end

  describe "send_test" do
    it "should POST /transactional/:id/test with the recipients and variables" do
      expect_http(:post, "transactional/#{tx_id}/test",
                  body: { "to" => ["a@acme.test"], "variables" => { "CODE" => "123456" } },
                  returns: { "id" => "email_1" })
      expect(Sendio::Transactional.send_test(tx_id, { to: ["a@acme.test"], variables: { CODE: "123456" } })[:id])
        .to eql("email_1")
    end
  end

  describe "stats" do
    it "should GET /transactional/:id/stats with the period" do
      expect_http(:get, "transactional/#{tx_id}/stats?from=2026-11-01&timezone=Europe%2FParis&granularity=hourly",
                  returns: { "object" => "transactional_email_stats", "transactional_id" => tx_id,
                             "totals" => { "sent" => 4 } })
      stats = Sendio::Transactional.stats(
        tx_id, { from: "2026-11-01", timezone: "Europe/Paris", granularity: "hourly" }
      )
      expect(stats[:totals]["sent"]).to eql(4)
    end
  end

  describe "the transactional send and the broadcast template link" do
    it "Emails.send passes the transactional shape through" do
      expect_http(:post, "emails",
                  body: {
                    "transactional_id" => tx_id,
                    "to" => "ada@example.com",
                    "variables" => { "CODE" => "123456" },
                    "track_opens" => false,
                    "track_clicks" => false
                  },
                  returns: { "id" => "email_1" })
      Sendio::Emails.send(
        { transactional_id: tx_id, to: "ada@example.com", variables: { CODE: "123456" },
          track_opens: false, track_clicks: false }
      )
    end

    it "Broadcasts.update with template_id: nil sends template_id null" do
      expect_http(:patch, "broadcasts/b1", body: { "template_id" => nil }, returns: { "id" => "b1" })
      Sendio::Broadcasts.update({ broadcast_id: "b1", template_id: nil })
    end

    it "Broadcasts.create sends the template link" do
      expect_http(:post, "broadcasts",
                  body: { "name" => "Launch", "segment_id" => "s1", "template_id" => "launch",
                          "template_version_id" => "v1" },
                  returns: { "id" => "b1" })
      Sendio::Broadcasts.create({ name: "Launch", segment_id: "s1", template_id: "launch", template_version_id: "v1" })
    end
  end
end
