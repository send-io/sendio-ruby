# frozen_string_literal: true

RSpec.describe "Broadcasts" do

  before do
    Sendio.configure do |config|
      config.api_key = "mx_123"
    end
  end

  describe "create" do
    it "should create broadcast with audience_id" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        "audience_id": "123123"
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      expect(Sendio::Broadcasts.create(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end

    it "should create broadcast with segment_id" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        "segment_id": "123123"
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      expect(Sendio::Broadcasts.create(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end

    it "should create broadcast with both segment_id and audience_id (segment_id takes precedence)" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        "segment_id": "segment123",
        "audience_id": "audience123"
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      expect(Sendio::Broadcasts.create(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end

    it "should create and send broadcast with send: true" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        segment_id: "123123",
        from: "onboarding@send.io",
        subject: "Hello World",
        html: "<p>Hello</p>",
        send: true
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      expect(Sendio::Broadcasts.create(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end

    it "should create and schedule broadcast with send: true and scheduled_at" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        segment_id: "123123",
        from: "onboarding@send.io",
        subject: "Hello World",
        html: "<p>Hello</p>",
        send: true,
        scheduled_at: "in 1 min"
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      expect(Sendio::Broadcasts.create(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end
  end

  describe "update" do
    it "should update broadcast" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        "broadcast_id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      expect(Sendio::Broadcasts.update(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end
  end

  describe "send" do
    it "should send broadcast" do
      resp = {
        "id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794"
      }
      params = {
        "broadcast_id": "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794",
        "scheduled_at": "in 1 min"
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      expect(Sendio::Broadcasts.send(params)[:id]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
    end
  end

  describe "list" do
    it "should list broadcasts" do
      resp = {
        "object": "list",
        "data": [
          {
            "id" => "49a3999c-0ce1-4ea6-ab68-afcd6dc2e794",
            "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
            "status" => "draft",
            "created_at" => "2024-11-01T15:13:31.723+00:00",
            "scheduled_at" => nil,
            "sent_at" => nil
          },
          {
            "id" => "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
            "audience_id" => "78261eea-8f8b-4381-83c6-79fa7120f1cf",
            "status" => "sent",
            "created_at" => "2024-12-01T19:32:22.98+00:00",
            "scheduled_at" => "2024-12-02T19:32:22.98+00:00",
            "sent_at" => "2024-12-02T19:32:22.98+00:00"
          }
        ]
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      broadcasts = Sendio::Broadcasts.list[:data]

      expect(broadcasts.length).to eql(2)

      expect(broadcasts[0]["id"]).to eql("49a3999c-0ce1-4ea6-ab68-afcd6dc2e794")
      expect(broadcasts[0]["audience_id"]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(broadcasts[0]["status"]).to eql("draft")
      expect(broadcasts[0]["created_at"]).to eql("2024-11-01T15:13:31.723+00:00")
      expect(broadcasts[0]["scheduled_at"]).to eql(nil)
      expect(broadcasts[0]["sent_at"]).to eql(nil)

      expect(broadcasts[1]["id"]).to eql("559ac32e-9ef5-46fb-82a1-b76b840c0f7b")
      expect(broadcasts[1]["audience_id"]).to eql("78261eea-8f8b-4381-83c6-79fa7120f1cf")
      expect(broadcasts[1]["status"]).to eql("sent")
      expect(broadcasts[1]["created_at"]).to eql("2024-12-01T19:32:22.98+00:00")
      expect(broadcasts[1]["scheduled_at"]).to eql("2024-12-02T19:32:22.98+00:00")
      expect(broadcasts[1]["sent_at"]).to eql("2024-12-02T19:32:22.98+00:00")
    end
  end

  describe "clicked_links" do
    it "lists a broadcast's clicked links" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id" => "b2Zmc2V0OjA",
            "url" => "https://send.io/pricing",
            "clicks" => 42,
            "unique_clicks" => 30
          },
          {
            "id" => "b2Zmc2V0OjE",
            "url" => "https://developer.send.io/docs/api",
            "clicks" => 17,
            "unique_clicks" => 15
          }
        ]
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      result = Sendio::Broadcasts.clicked_links("559ac32e-9ef5-46fb-82a1-b76b840c0f7b")

      expect(result[:object]).to eql("list")
      expect(result[:has_more]).to eql(false)
      expect(result[:data].length).to eql(2)
      expect(result[:data][0]["url"]).to eql("https://send.io/pricing")
      expect(result[:data][0]["clicks"]).to eql(42)
      expect(result[:data][0]["unique_clicks"]).to eql(30)
    end

    it "accepts pagination parameters" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": []
      }

      request_instance = instance_double(Sendio::Request)
      allow(request_instance).to receive(:perform).and_return(resp)
      allow(Sendio::Request).to receive(:new) do |path, _body, _verb|
        expect(path).to include("broadcasts/559ac32e-9ef5-46fb-82a1-b76b840c0f7b/clicked-links")
        expect(path).to include("limit=10")
        expect(path).to include("after=key_123")
        expect(path).to include("before=key_456")
        request_instance
      end

      params = { limit: 10, after: "key_123", before: "key_456" }
      result = Sendio::Broadcasts.clicked_links("559ac32e-9ef5-46fb-82a1-b76b840c0f7b", params)
      expect(result[:object]).to eql("list")
    end
  end

  describe "cancel" do
    it "should cancel broadcast" do
      resp = {
        "object": "broadcast",
        "id": "559ac32e-9ef5-46fb-82a1-b76b840c0f7b"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      broadcast = Sendio::Broadcasts.cancel(resp[:id])
      expect(broadcast[:id]).to eql "559ac32e-9ef5-46fb-82a1-b76b840c0f7b"
    end
  end

  describe "duplicate" do
    it "should duplicate broadcast" do
      resp = {
        "object": "broadcast",
        "id": "e169aa45-1ecf-4183-9955-b1499d5701d3"
      }
      expect(Sendio::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("broadcasts/559ac32e-9ef5-46fb-82a1-b76b840c0f7b/duplicate")
        expect(verb).to eql("post")
        double("req", perform: resp)
      end
      result = Sendio::Broadcasts.duplicate("559ac32e-9ef5-46fb-82a1-b76b840c0f7b")
      expect(result[:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(result[:object]).to eql("broadcast")
    end
  end

  describe "remove" do
    it "should remove broadcast" do
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return("")
      expect { Sendio::Broadcasts.remove }.not_to raise_error
    end
  end

  describe "recipients" do
    it "should raise when type is missing" do
      expect do
        Sendio::Broadcasts.recipients("559ac32e-9ef5-46fb-82a1-b76b840c0f7b", {})
      end.to raise_error(ArgumentError, "type is required")
    end

    it "should list recipients for a basic event type" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id" => "b2Zmc2V0OjA",
            "contact_id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "email" => "carter@example.com"
          }
        ]
      }
      expect(Sendio::Request).to receive(:new).with(
        "broadcasts/559ac32e-9ef5-46fb-82a1-b76b840c0f7b/recipients?type=sent",
        {},
        "get"
      ).and_call_original
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      recipients = Sendio::Broadcasts.recipients(
        "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
        { type: "sent" }
      )

      expect(recipients[:object]).to eql("list")
      expect(recipients[:has_more]).to eql(false)
      expect(recipients[:data].length).to eql(1)
      expect(recipients[:data][0]["id"]).to eql("b2Zmc2V0OjA")
      expect(recipients[:data][0]["contact_id"]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
      expect(recipients[:data][0]["email"]).to eql("carter@example.com")
    end

    it "should list recipients with count for opened type" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id" => "b2Zmc2V0OjA",
            "contact_id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "email" => "carter@example.com",
            "count" => 3
          }
        ]
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      recipients = Sendio::Broadcasts.recipients(
        "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
        { type: "opened" }
      )

      expect(recipients[:data][0]["count"]).to eql(3)
    end

    it "should list recipients with clicked_links for clicked type" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id" => "b2Zmc2V0OjA",
            "contact_id" => "e169aa45-1ecf-4183-9955-b1499d5701d3",
            "email" => "carter@example.com",
            "count" => 2,
            "clicked_links" => [
              { "url" => "https://send.io/pricing", "clicks" => 2 }
            ]
          }
        ]
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      recipients = Sendio::Broadcasts.recipients(
        "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
        { type: "clicked" }
      )

      expect(recipients[:data][0]["count"]).to eql(2)
      expect(recipients[:data][0]["clicked_links"]).to eql(
        [{ "url" => "https://send.io/pricing", "clicks" => 2 }]
      )
    end

    it "should list recipients with bounce_type for bounced type" do
      resp = {
        "object": "list",
        "has_more": false,
        "data": [
          {
            "id" => "b2Zmc2V0OjA",
            "contact_id" => nil,
            "email" => "carter@example.com",
            "bounce_type" => "permanent"
          }
        ]
      }
      expect(Sendio::Request).to receive(:new).with(
        "broadcasts/559ac32e-9ef5-46fb-82a1-b76b840c0f7b/recipients?type=bounced&bounce_type=permanent",
        {},
        "get"
      ).and_call_original
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      recipients = Sendio::Broadcasts.recipients(
        "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
        { type: "bounced", bounce_type: "permanent" }
      )

      expect(recipients[:data][0]["contact_id"]).to eql(nil)
      expect(recipients[:data][0]["bounce_type"]).to eql("permanent")
    end

    it "should raise when broadcast is not found" do
      resp = {
        "statusCode" => 404,
        "name" => "not_found",
        "message" => "Broadcast not found"
      }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      expect do
        Sendio::Broadcasts.recipients("missing-id", { type: "sent" })
      end.to raise_error(Sendio::Error::NotFoundError, /Broadcast not found/)
    end
  end

  describe "get broadcast" do

    it "should retrieve a broadcast" do

      resp = {
        "object": "broadcast",
        "id": "559ac32e-9ef5-46fb-82a1-b76b840c0f7b",
        "name": "Announcements",
        "audience_id": "78261eea-8f8b-4381-83c6-79fa7120f1cf",
        "from": "Acme <onboarding@send.io>",
        "subject": "hello world",
        "reply_to": nil,
        "preview_text": "Check out our latest announcements",
        "status": "draft",
        "created_at": "2024-12-01T19:32:22.98+00:00",
        "scheduled_at": nil,
        "sent_at": nil,
        "html": "<p>hello world</p>",
        "text": "hello world"
      }

      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      broadcast = Sendio::Broadcasts.get("559ac32e-9ef5-46fb-82a1-b76b840c0f7b")

      expect(broadcast[:object]).to eql "broadcast"
      expect(broadcast[:id]).to eql "559ac32e-9ef5-46fb-82a1-b76b840c0f7b"
      expect(broadcast[:name]).to eql "Announcements"
      expect(broadcast[:audience_id]).to eql "78261eea-8f8b-4381-83c6-79fa7120f1cf"
      expect(broadcast[:from]).to eql "Acme <onboarding@send.io>"
      expect(broadcast[:subject]).to eql "hello world"
      expect(broadcast[:reply_to]).to eql nil
      expect(broadcast[:preview_text]).to eql "Check out our latest announcements"
      expect(broadcast[:status]).to eql "draft"
      expect(broadcast[:created_at]).to eql "2024-12-01T19:32:22.98+00:00"
      expect(broadcast[:scheduled_at]).to eql nil
      expect(broadcast[:sent_at]).to eql nil
      expect(broadcast[:html]).to eql "<p>hello world</p>"
      expect(broadcast[:text]).to eql "hello world"
    end
  end


  # Captures the HTTP call so a test can assert the exact verb, URL and JSON body.
  def stub_http(resp = { "object": "broadcast", "id": "b_1" })
    calls = []
    allow(resp).to receive(:body).and_return(resp)
    allow(HTTParty).to receive(:send) do |verb, url, opts|
      calls << { verb: verb, url: url, body: opts[:body] && JSON.parse(opts[:body]), query: opts[:query] }
      resp
    end
    calls
  end

  describe "request bodies" do
    it "sends every create field, tracking: false included" do
      calls = stub_http
      params = {
        name: "Launch", from: "Acme <a@acme.com>", subject: "Hi", reply_to: ["r@acme.com"],
        html: "<p>Hi</p>", text: "Hi", preview_text: "Preview", topic_id: "t_1",
        segment_id: "s_1", segment_ids: %w[s_1 s_2], exclude_segment_ids: ["s_3"],
        audience: "segments", unsubscribe_scope: "list", tracking: false,
        template_engine: "handlebars", send: true, scheduled_at: "in 1 hour"
      }
      Sendio::Broadcasts.create(params)
      expect(calls.length).to eql 1
      expect(calls[0][:verb]).to eql :post
      expect(calls[0][:url]).to end_with "/broadcasts"
      expect(calls[0][:body]).to eql JSON.parse(params.to_json)
      expect(calls[0][:body]["tracking"]).to eql false
    end

    it "creates an empty draft with an empty body" do
      calls = stub_http
      Sendio::Broadcasts.create
      expect(calls[0][:body]).to be_nil
    end

    it "keeps the deprecated audience_id on create" do
      calls = stub_http
      expect { Sendio::Broadcasts.create(audience_id: "a_1", name: "x") }.to output(/DEPRECATION/).to_stderr
      expect(calls[0][:body]).to eql({ "audience_id" => "a_1", "name" => "x" })
    end

    it "puts the update broadcast_id in the path only" do
      calls = stub_http
      Sendio::Broadcasts.update(broadcast_id: "b_1", name: "Renamed", tracking: false, topic_id: nil,
                                segment_ids: ["s_1"], audience: "all", template_engine: "simple")
      expect(calls[0][:verb]).to eql :patch
      expect(calls[0][:url]).to end_with "/broadcasts/b_1"
      expect(calls[0][:body]).to eql({ "name" => "Renamed", "tracking" => false, "topic_id" => nil,
                                       "segment_ids" => ["s_1"], "audience" => "all",
                                       "template_engine" => "simple" })
    end

    it "strips a string-keyed broadcast_id from the update body" do
      calls = stub_http
      Sendio::Broadcasts.update("broadcast_id" => "b_1", "name" => "Renamed")
      expect(calls[0][:url]).to end_with "/broadcasts/b_1"
      expect(calls[0][:body]).to eql({ "name" => "Renamed" })
    end

    it "sends only scheduled_at to send" do
      calls = stub_http
      Sendio::Broadcasts.send(broadcast_id: "b_1", scheduled_at: "in 1 min")
      expect(calls[0][:verb]).to eql :post
      expect(calls[0][:url]).to end_with "/broadcasts/b_1/send"
      expect(calls[0][:body]).to eql({ "scheduled_at" => "in 1 min" })
    end

    it "sends no body to send without scheduled_at" do
      calls = stub_http
      Sendio::Broadcasts.send(broadcast_id: "b_1")
      expect(calls[0][:body]).to be_nil
    end

    it "passes the list filters as query parameters" do
      calls = stub_http({ "object": "list", "has_more": false, "data": [] })
      Sendio::Broadcasts.list(limit: 5, after: "x", status: "draft", segment_id: "s_1", search: "launch week")
      expect(calls[0][:verb]).to eql :get
      expect(calls[0][:url]).to end_with "/broadcasts?limit=5&after=x&status=draft&segment_id=s_1&search=launch+week"
    end

    it "keeps get, remove, cancel and duplicate bodyless" do
      calls = stub_http
      Sendio::Broadcasts.get("b_1")
      Sendio::Broadcasts.remove("b_1")
      Sendio::Broadcasts.cancel("b_1")
      Sendio::Broadcasts.duplicate("b_1")
      expect(calls.map { |c| [c[:verb], c[:url].split("/", 4).last, c[:body]] }).to eql [
        [:get, "broadcasts/b_1", nil], [:delete, "broadcasts/b_1", nil],
        [:post, "broadcasts/b_1/cancel", nil], [:post, "broadcasts/b_1/duplicate", nil]
      ]
    end

    it "passes the recipients filters as query parameters" do
      calls = stub_http({ "object": "list", "has_more": false, "data": [] })
      Sendio::Broadcasts.recipients("b_1", type: "bounced", email: "a@b.com", bounce_type: "permanent", limit: 2, before: "c")
      expect(calls[0][:url]).to end_with "/broadcasts/b_1/recipients?type=bounced&email=a%40b.com&bounce_type=permanent&limit=2&before=c"
    end
  end

  describe "estimate" do
    it "posts the audience and returns the estimate" do
      calls = stub_http({ "object": "broadcast_estimate", "recipients": 120, "skipped": { "invalid" => 3 } })
      params = { segment_id: "s_1", segment_ids: ["s_2"], exclude_segment_ids: ["s_3"], audience: "segments", topic_id: "t_1" }
      result = Sendio::Broadcasts.estimate(params)
      expect(calls[0][:verb]).to eql :post
      expect(calls[0][:url]).to end_with "/broadcasts/estimate"
      expect(calls[0][:body]).to eql JSON.parse(params.to_json)
      expect(result[:object]).to eql "broadcast_estimate"
      expect(result[:recipients]).to eql 120
      expect(result[:skipped]["invalid"]).to eql 3
    end

    it "estimates everyone" do
      calls = stub_http({ "object": "broadcast_estimate", "recipients": 9, "skipped": { "invalid" => 0 } })
      Sendio::Broadcasts.estimate(audience: "all")
      expect(calls[0][:body]).to eql({ "audience" => "all" })
    end
  end

  describe "test" do
    it "sends a test to a list of addresses" do
      calls = stub_http({ "object": "broadcast_test", "sent": 2 })
      result = Sendio::Broadcasts.test("b_1", ["a@x.com", "b@x.com"])
      expect(calls[0][:verb]).to eql :post
      expect(calls[0][:url]).to end_with "/broadcasts/b_1/test"
      expect(calls[0][:body]).to eql({ "to" => ["a@x.com", "b@x.com"] })
      expect(result[:sent]).to eql 2
    end

    it "wraps a single address" do
      calls = stub_http({ "object": "broadcast_test", "sent": 1 })
      Sendio::Broadcasts.test("b_1", "a@x.com")
      expect(calls[0][:body]).to eql({ "to" => ["a@x.com"] })
    end
  end

  describe "stats" do
    it "gets the broadcast's stats" do
      calls = stub_http({ "recipients": 10, "delivered": 9, "open_rate": 0.5, "skipped": { "invalid" => 1 } })
      result = Sendio::Broadcasts.stats("b_1")
      expect(calls[0][:verb]).to eql :get
      expect(calls[0][:url]).to end_with "/broadcasts/b_1/stats"
      expect(calls[0][:body]).to be_nil
      expect(result[:delivered]).to eql 9
    end
  end

  describe "versions" do
    it "lists versions with pagination" do
      calls = stub_http({ "object": "list", "has_more": false,
                          "data": [{ "object" => "broadcast_version", "version_number" => 2, "current" => true }] })
      result = Sendio::Broadcasts.list_versions("b_1", limit: 10, after: "v_1", before: "v_3")
      expect(calls[0][:verb]).to eql :get
      expect(calls[0][:url]).to end_with "/broadcasts/b_1/versions?limit=10&after=v_1&before=v_3"
      expect(result[:data][0]["version_number"]).to eql 2
    end

    it "lists versions without parameters" do
      calls = stub_http({ "object": "list", "has_more": false, "data": [] })
      Sendio::Broadcasts.list_versions("b_1")
      expect(calls[0][:url]).to end_with "/broadcasts/b_1/versions"
    end

    it "gets a version by number" do
      calls = stub_http({ "object": "broadcast_version", "version_number": 3 })
      result = Sendio::Broadcasts.get_version("b_1", 3)
      expect(calls[0][:verb]).to eql :get
      expect(calls[0][:url]).to end_with "/broadcasts/b_1/versions/3"
      expect(result[:version_number]).to eql 3
    end

    it "labels a version" do
      calls = stub_http({ "object": "broadcast_version", "version_number": 3 })
      Sendio::Broadcasts.update_version("b_1", 3, name: "Final", comment: "Approved")
      expect(calls[0][:verb]).to eql :patch
      expect(calls[0][:url]).to end_with "/broadcasts/b_1/versions/3"
      expect(calls[0][:body]).to eql({ "name" => "Final", "comment" => "Approved" })
    end

    it "restores a version" do
      calls = stub_http({ "object": "broadcast_version", "version_number": 4 })
      Sendio::Broadcasts.restore_version("b_1", 3)
      expect(calls[0][:verb]).to eql :post
      expect(calls[0][:url]).to end_with "/broadcasts/b_1/versions/3/restore"
      expect(calls[0][:body]).to be_nil
    end
  end

end
