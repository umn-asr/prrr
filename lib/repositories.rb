module Prrr
  class Repositories
    include Enumerable
    extend Forwardable
    def_delegators :@members, :each

    def self.build(organization:, included:, client:)
      if included.any?
        new(organization, included, client)
      else
        all(organization, client)
      end
    end

    def initialize(organization, included, client)
      @members = included.map do |name|
        if client.repository?("#{organization}/#{name}")
          client.repository("#{organization}/#{name}")
        end
      end
    end
    private_class_method :new

    def self.all(organization, client)
      repositories = client.organization_repositories(organization).map { |r| r.name }
      new(organization, repositories)
    end
    private_class_method :all
  end
end
