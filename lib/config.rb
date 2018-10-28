module Prrr
  class Config
    def initialize
      self.attributes = Psych.safe_load(File.read("./config.yml"))
    end

    def organizations
      @organizations ||= attributes.map do |org, attributes|
        Organization.new(
          name: org,
          attributes: attributes,
          client: client,
        )
      end
    end

    def client
      return @client  if @client

      Octokit.configure do |c|
        c.api_endpoint = endpoint
      end

      @client = Octokit::Client.new(:access_token => access_token)
      @client.auto_paginate = true
      user = @client.user
      user.login
      @client
    end

    def access_token
      ENV.fetch("PRRR_ACCESS_TOKEN")
    end

    def endpoint
      ENV.fetch("PRRR_GITHUB_URL")
    end

    private

    attr_accessor :attributes
  end
end
