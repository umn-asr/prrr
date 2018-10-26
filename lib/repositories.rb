class Repositories
  include Enumerable
  extend Forwardable
  def_delegators :@members, :each

  def self.build(organization:, included:)
    if included.any?
      Repositories.new(organization, included)
    else
      Repositories.all(organization)
    end
  end

  def initialize(organization, included, client: PRRR_CLIENT)
    @members = included.map do |name|
      if client.repository?("#{organization}/#{name}")
        client.repository("#{organization}/#{name}")
      end
    end
  end

  def self.all(organization, client: PRRR_CLIENT)
    repositories = client.organization_repositories(organization).map { |r| r.name }
    new(organization, repositories)
  end
end
