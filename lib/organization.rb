require_relative "./reviewer_team"

module Prrr
  class Organization
    attr_reader :name, :reviewer_team, :repositories

    def initialize(name:, attributes:, client:)
      self.name = name
      self.reviewer_team = ReviewerTeam.new(organization: name,
                                            name: attributes.fetch("review_team"),
                                            client: client
                                           )
      self.repositories = attributes["repositories"].to_a
    end

    private

    attr_writer :name, :reviewer_team, :repositories
  end
end
