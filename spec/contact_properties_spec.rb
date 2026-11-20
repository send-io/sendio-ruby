# frozen_string_literal: true

RSpec.describe "ContactProperties" do
  before do
    Sendio.configure do |config|
      config.api_key = "mx_123"
    end
  end

  describe "create contact property" do
    it "should create a contact property with string type" do
      resp = {
        object: "contact_property",
        id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      }

      params = {
        key: "company_name",
        type: "string",
        fallback_value: "Acme Corp"
      }

      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      property = Sendio::ContactProperties.create(params)

      expect(property[:object]).to eql("contact_property")
      expect(property[:id]).to eql("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
    end

    it "should create a contact property with number type" do
      resp = {
        object: "contact_property",
        id: "c7d35c9f-bg1c-5d4d-cf0d-460cce816a9f"
      }

      params = {
        key: "age",
        type: "number",
        fallback_value: 0
      }

      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      property = Sendio::ContactProperties.create(params)

      expect(property[:object]).to eql("contact_property")
      expect(property[:id]).to eql("c7d35c9f-bg1c-5d4d-cf0d-460cce816a9f")
    end
  end

  describe "get contact property" do
    it "should retrieve a contact property by id" do
      resp = {
        object: "contact_property",
        id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        key: "company_name",
        type: "string",
        fallback_value: "Acme Corp",
        created_at: "2023-04-08T00:11:13.110779+00:00"
      }

      property_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"

      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      property = Sendio::ContactProperties.get(property_id)

      expect(property[:object]).to eql("contact_property")
      expect(property[:id]).to eql("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
      expect(property[:key]).to eql("company_name")
      expect(property[:type]).to eql("string")
      expect(property[:fallback_value]).to eql("Acme Corp")
    end
  end

  describe "list contact properties" do
    it "should list all contact properties" do
      resp = {
        object: "list",
        has_more: false,
        data: [
          {
            "id" => "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
            "key" => "company_name",
            "type" => "string",
            "fallback_value" => "Acme Corp",
            "created_at" => "2023-04-08T00:11:13.110779+00:00"
          }
        ]
      }

      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      properties = Sendio::ContactProperties.list

      expect(properties[:object]).to eql("list")
      expect(properties[:has_more]).to eql(false)
      expect(properties[:data]).to be_an(Array)
      expect(properties[:data].first["id"]).to eql("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
    end

    it "should list contact properties with pagination" do
      resp = {
        object: "list",
        has_more: true,
        data: []
      }

      params = { limit: 10, after: "cursor_123" }

      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      properties = Sendio::ContactProperties.list(params)

      expect(properties[:object]).to eql("list")
      expect(properties[:has_more]).to eql(true)
    end
  end

  describe "update contact property" do
    it "should update a contact property" do
      resp = {
        object: "contact_property",
        id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"
      }

      params = {
        id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        fallback_value: "Example Company"
      }

      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      property = Sendio::ContactProperties.update(params)

      expect(property[:object]).to eql("contact_property")
      expect(property[:id]).to eql("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
    end
  end

  describe "remove contact property" do
    it "should delete a contact property" do
      resp = {
        object: "contact_property",
        id: "b6d24b8e-af0b-4c3c-be0c-359bbd97381e",
        deleted: true
      }

      property_id = "b6d24b8e-af0b-4c3c-be0c-359bbd97381e"

      allow_any_instance_of(Sendio::Request).to receive(:perform).and_return(resp)

      result = Sendio::ContactProperties.remove(property_id)

      expect(result[:object]).to eql("contact_property")
      expect(result[:id]).to eql("b6d24b8e-af0b-4c3c-be0c-359bbd97381e")
      expect(result[:deleted]).to eql(true)
    end
  end
end
