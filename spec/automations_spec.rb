# frozen_string_literal: true

RSpec.describe "Automations" do
  before do
    Sendio.configure do |config|
      config.api_key = "mx_123"
    end
  end

  let(:automation_id) { "auto_abc123" }
  let(:run_id) { "run_xyz789" }

  let(:steps) do
    [
      { key: "trigger", type: "trigger", config: { event_name: "user.created" } },
      { key: "send_welcome", type: "send_email", config: { template: { id: "tpl_xxx" } } }
    ]
  end

  let(:connections) do
    [{ from: "trigger", to: "send_welcome", type: "default" }]
  end

  describe "create" do
    it "should create an automation" do
      resp = {
        object: "automation",
        id: automation_id
      }
      params = { name: "Welcome Automation", steps: steps, connections: connections }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      result = Sendio::Automations.create(params)
      expect(result[:id]).to eql(automation_id)
      expect(result[:object]).to eql("automation")
    end

    it "should use POST /automations" do
      params = { name: "Welcome Automation", steps: steps, connections: connections }
      req = double("req", perform: { id: automation_id })
      expect(Sendio::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations")
        expect(verb).to eql("post")
        req
      end
      Sendio::Automations.create(params)
    end
  end

  describe "get" do
    it "should retrieve an automation" do
      resp = {
        object: "automation",
        id: automation_id,
        name: "Welcome Automation",
        status: "enabled",
        created_at: "2024-01-01T00:00:00+00:00",
        updated_at: "2024-01-01T00:00:00+00:00",
        steps: [
          { "key" => "trigger", "type" => "trigger", "config" => { "event_name" => "user.created" } },
          { "key" => "send_welcome", "type" => "send_email", "config" => { "template" => { "id" => "tpl_xxx" } } }
        ],
        connections: [{ "from" => "trigger", "to" => "send_welcome", "type" => "default" }]
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      result = Sendio::Automations.get(automation_id)
      expect(result[:id]).to eql(automation_id)
      expect(result[:object]).to eql("automation")
      expect(result[:name]).to eql("Welcome Automation")
      expect(result[:status]).to eql("enabled")
    end

    it "should use GET /automations/:id" do
      req = double("req", perform: { id: automation_id })
      expect(Sendio::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations/#{automation_id}")
        expect(verb).to eql("get")
        req
      end
      Sendio::Automations.get(automation_id)
    end
  end

  describe "update" do
    it "should update an automation" do
      resp = { object: "automation", id: automation_id }
      params = { automation_id: automation_id, status: "enabled" }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      result = Sendio::Automations.update(params)
      expect(result[:id]).to eql(automation_id)
    end

    it "should use PATCH /automations/:id" do
      params = { automation_id: automation_id, status: "enabled" }
      req = double("req", perform: { id: automation_id })
      expect(Sendio::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations/#{automation_id}")
        expect(verb).to eql("patch")
        req
      end
      Sendio::Automations.update(params)
    end

    it "should NOT include automation_id in the request body" do
      params = { automation_id: automation_id, name: "Updated Name" }
      req = double("req", perform: { id: automation_id })
      expect(Sendio::Request).to receive(:new).once do |_path, body, _verb|
        expect(body).not_to have_key(:automation_id)
        expect(body[:name]).to eql("Updated Name")
        req
      end
      Sendio::Automations.update(params)
    end
  end

  describe "remove" do
    it "should delete an automation" do
      resp = { object: "automation", id: automation_id, deleted: true }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      result = Sendio::Automations.remove(automation_id)
      expect(result[:id]).to eql(automation_id)
      expect(result[:deleted]).to eql(true)
    end

    it "should use DELETE /automations/:id" do
      req = double("req", perform: { id: automation_id, deleted: true })
      expect(Sendio::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations/#{automation_id}")
        expect(verb).to eql("delete")
        req
      end
      Sendio::Automations.remove(automation_id)
    end
  end

  describe "duplicate" do
    it "should duplicate an automation" do
      resp = { object: "automation", id: "e169aa45-1ecf-4183-9955-b1499d5701d3" }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      result = Sendio::Automations.duplicate(automation_id)
      expect(result[:object]).to eql("automation")
      expect(result[:id]).to eql("e169aa45-1ecf-4183-9955-b1499d5701d3")
    end

    it "should use POST /automations/:id/duplicate" do
      req = double("req", perform: { id: automation_id })
      expect(Sendio::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations/#{automation_id}/duplicate")
        expect(verb).to eql("post")
        req
      end
      Sendio::Automations.duplicate(automation_id)
    end
  end

  describe "stop" do
    it "should stop an automation" do
      resp = { object: "automation", id: automation_id, status: "disabled" }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      result = Sendio::Automations.stop(automation_id)
      expect(result[:id]).to eql(automation_id)
      expect(result[:status]).to eql("disabled")
    end

    it "should use POST /automations/:id/stop" do
      req = double("req", perform: { id: automation_id })
      expect(Sendio::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations/#{automation_id}/stop")
        expect(verb).to eql("post")
        req
      end
      Sendio::Automations.stop(automation_id)
    end
  end

  describe "list" do
    it "should list automations" do
      resp = {
        object: "list",
        has_more: false,
        data: [
          { "id" => automation_id, "name" => "Welcome Automation", "status" => "enabled", "created_at" => "2024-01-01T00:00:00+00:00" }
        ]
      }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      result = Sendio::Automations.list
      expect(result[:object]).to eql("list")
      expect(result[:data].length).to eql(1)
      expect(result[:has_more]).to eql(false)
      expect(result[:data].first["id"]).to eql(automation_id)
    end

    it "should list automations with status filter" do
      resp = { object: "list", has_more: false, data: [{ "id" => automation_id, "status" => "enabled" }] }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      result = Sendio::Automations.list({ status: "enabled" })
      expect(result[:data].first["status"]).to eql("enabled")
    end

    it "should list automations with pagination params" do
      resp = { object: "list", has_more: true, data: [{ "id" => automation_id }] }
      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
      result = Sendio::Automations.list({ limit: 1 })
      expect(result[:has_more]).to eql(true)
    end

    it "should use GET /automations" do
      req = double("req", perform: { object: "list", data: [], has_more: false })
      expect(Sendio::Request).to receive(:new).once do |path, _body, verb|
        expect(path).to eql("automations")
        expect(verb).to eql("get")
        req
      end
      Sendio::Automations.list
    end
  end

  describe "Runs" do
    it "should be accessible as Sendio::Automations::Runs" do
      expect(Sendio::Automations::Runs).to be_a(Module)
    end

    describe "list" do
      it "should list runs for an automation" do
        resp = {
          object: "list",
          has_more: false,
          data: [
            {
              "id" => run_id,
              "status" => "completed",
              "started_at" => "2024-01-01T00:00:00+00:00",
              "completed_at" => "2024-01-01T00:01:00+00:00",
              "created_at" => "2024-01-01T00:00:00+00:00"
            }
          ]
        }
        allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
        result = Sendio::Automations::Runs.list(automation_id)
        expect(result[:object]).to eql("list")
        expect(result[:data].length).to eql(1)
        expect(result[:data].first["id"]).to eql(run_id)
        expect(result[:has_more]).to eql(false)
      end

      it "should use GET /automations/:id/runs" do
        req = double("req", perform: { object: "list", data: [], has_more: false })
        expect(Sendio::Request).to receive(:new).once do |path, _body, verb|
          expect(path).to eql("automations/#{automation_id}/runs")
          expect(verb).to eql("get")
          req
        end
        Sendio::Automations::Runs.list(automation_id)
      end

      it "should list runs with pagination params" do
        resp = { object: "list", has_more: true, data: [{ "id" => run_id }] }
        allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
        result = Sendio::Automations::Runs.list(automation_id, { limit: 1 })
        expect(result[:has_more]).to eql(true)
      end
    end

    describe "get" do
      it "should retrieve a specific run" do
        resp = {
          object: "automation_run",
          id: run_id,
          status: "completed",
          started_at: "2024-01-01T00:00:00+00:00",
          completed_at: "2024-01-01T00:01:00+00:00",
          created_at: "2024-01-01T00:00:00+00:00",
          steps: []
        }
        allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)
        result = Sendio::Automations::Runs.get(automation_id, run_id)
        expect(result[:id]).to eql(run_id)
        expect(result[:object]).to eql("automation_run")
        expect(result[:status]).to eql("completed")
      end

      it "should use GET /automations/:id/runs/:run_id" do
        req = double("req", perform: { id: run_id })
        expect(Sendio::Request).to receive(:new).once do |path, _body, verb|
          expect(path).to eql("automations/#{automation_id}/runs/#{run_id}")
          expect(verb).to eql("get")
          req
        end
        Sendio::Automations::Runs.get(automation_id, run_id)
      end
    end
  end

  describe "create_from_template" do
    let(:params) do
      { slug: "welcome-series", sender: { from: "Acme <hi@acme.com>" }, topic_id: "topic_123" }
    end

    it "should use POST /automations/from-template with the params as body" do
      req = double("req", perform: { object: "automation", id: automation_id })
      expect(Sendio::Request).to receive(:new).once do |path, body, verb, options:|
        expect(path).to eql("automations/from-template")
        expect(verb).to eql("post")
        expect(body).to eql(params)
        expect(options).to eql({})
        req
      end
      Sendio::Automations.create_from_template(params)
    end

    it "should send the Idempotency-Key header when :idempotency_key is provided" do
      resp = { "object" => "automation", "id" => automation_id, "status" => "disabled" }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      result = Sendio::Automations.create_from_template(params, options: { idempotency_key: "tpl-1" })

      expect(result[:id]).to eql(automation_id)
      expect(HTTParty).to have_received(:send).with(
        :post,
        "#{Sendio::Request::BASE_URL}automations/from-template",
        {
          headers: {
            "Content-Type" => "application/json",
            "Accept" => "application/json",
            "Authorization" => "Bearer mx_123",
            "User-Agent" => "sendio-ruby:#{Sendio::VERSION}",
            "Idempotency-Key" => "tpl-1"
          },
          body: params.to_json
        }
      )
    end

    it "should not send the Idempotency-Key header when no key is provided" do
      resp = { "object" => "automation", "id" => automation_id }
      allow(resp).to receive(:body).and_return(resp)
      allow(HTTParty).to receive(:send).and_return(resp)

      Sendio::Automations.create_from_template(params)

      expect(HTTParty).to have_received(:send) do |_verb, _url, opts|
        expect(opts[:headers]).not_to have_key("Idempotency-Key")
      end
    end
  end

  describe "Templates" do
    it "should be accessible as Sendio::Automations::Templates" do
      expect(Sendio::Automations::Templates).to be_a(Module)
    end

    describe "list" do
      it "should use GET /automation-templates without a query" do
        req = double("req", perform: { object: "list", categories: [], data: [] })
        expect(Sendio::Request).to receive(:new).once do |path, body, verb|
          expect(path).to eql("automation-templates")
          expect(body).to eql({})
          expect(verb).to eql("get")
          req
        end
        Sendio::Automations::Templates.list
      end

      it "should pass category as a query param" do
        resp = { "object" => "list", "categories" => ["billing"], "data" => [] }
        allow(resp).to receive(:body).and_return(resp)
        allow(HTTParty).to receive(:send).and_return(resp)

        result = Sendio::Automations::Templates.list(category: "billing")

        expect(result[:object]).to eql("list")
        expect(HTTParty).to have_received(:send).with(
          :get,
          "#{Sendio::Request::BASE_URL}automation-templates",
          hash_including(query: { category: "billing" })
        )
      end
    end

    describe "get" do
      it "should use GET /automation-templates/:slug" do
        req = double("req", perform: { object: "automation_template", slug: "welcome-series" })
        expect(Sendio::Request).to receive(:new).once do |path, _body, verb|
          expect(path).to eql("automation-templates/welcome-series")
          expect(verb).to eql("get")
          req
        end
        result = Sendio::Automations::Templates.get("welcome-series")
        expect(result[:slug]).to eql("welcome-series")
      end
    end
  end
end
