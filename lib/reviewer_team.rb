module Prrr
  class ReviewerTeam
    def initialize(organization:, name:, client:)
      self.organization = organization
      self.name = name
      self.client = client
    end

    def id
      attributes.id
    end

    def exists?
      !attributes.nil?
    end

    def has_members?
      members.any?
    end

    def reviewer_for(pull_request:)
      members.detect { |r| !r.casecmp(pull_request.user.login).zero? }
    end

    def enqueue(member: )
      members.delete(member)
      members.push(member)
    end

    def refresh!
      # Combines the current members with new members and preserves ordering
      @members = (members | get_members) & get_members
    end

    private

    attr_accessor :organization, :name, :client

    def attributes
      @attributes ||= client.organization_teams(organization).detect { |team| team.name.casecmp(name).zero? }
    end

    def members
      @members ||= get_members
    end

    def get_members
      client.team_members(id).map {|member| member.login }
    end
  end
end
