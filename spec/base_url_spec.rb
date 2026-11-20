# frozen_string_literal: true

RSpec.describe "Sendio.base_url" do
  around do |example|
    saved_env = ENV.fetch("SENDIO_BASE_URL", nil)
    ENV.delete("SENDIO_BASE_URL")
    Sendio.base_url = nil
    example.run
  ensure
    Sendio.base_url = nil
    saved_env.nil? ? ENV.delete("SENDIO_BASE_URL") : ENV["SENDIO_BASE_URL"] = saved_env
  end

  it "defaults to https://api.send.io/" do
    expect(Sendio.base_url).to eq("https://api.send.io/")
  end

  it "reads SENDIO_BASE_URL with or without a trailing slash" do
    ENV["SENDIO_BASE_URL"] = "https://api.example.test"
    expect(Sendio.base_url).to eq("https://api.example.test/")
    ENV["SENDIO_BASE_URL"] = "https://api.example.test/"
    expect(Sendio.base_url).to eq("https://api.example.test/")
  end

  it "can be set at runtime and takes precedence over the env var" do
    ENV["SENDIO_BASE_URL"] = "https://env.example.test/"
    Sendio.base_url = "http://localhost:8080"
    expect(Sendio.base_url).to eq("http://localhost:8080/")
    Sendio.base_url = nil
    expect(Sendio.base_url).to eq("https://env.example.test/")
  end

  it "is used for requests" do
    Sendio.api_key = "mx_123"
    Sendio.base_url = "https://api.example.test/"
    response = double(HTTParty::Response, body: "{}", parsed_response: {}, headers: {})
    expect(HTTParty).to receive(:send)
      .with(:get, "https://api.example.test/domains", hash_including(:headers))
      .and_return(response)
    Sendio::Request.new("domains", {}, "get").perform
  end
end
