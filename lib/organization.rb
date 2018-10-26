require_relative "./reviewer_team"

class Organization
  attr_reader :name, :reviewer_team, :repositories

  def initialize(name:, attributes:)
    self.name = name
    self.reviewer_team = ReviewerTeam.new(organization: name, name: attributes.fetch("review_team"))
    self.repositories = attributes["repositories"].to_a
  end

  private

  attr_writer :name, :reviewer_team, :repositories
end
