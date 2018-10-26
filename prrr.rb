#!/usr/bin/env ruby
require "octokit"
require "logger"
require_relative "lib/reviewer_team"

organization = ENV.fetch("PRRR_ORGANIZATION")
repository = "#{organization}/#{ENV.fetch("PRRR_REPOSITORY")}"
access_token = ENV.fetch("PRRR_ACCESS_TOKEN")
review_team = ENV.fetch("PRRR_REVIEW_TEAM")

logger = Logger.new('/proc/1/fd/1')

Octokit.configure do |c|
  c.api_endpoint = "https://github.umn.edu/api/v3/"
end

client = Octokit::Client.new(:access_token => access_token)
PRRR_CLIENT = client

user = client.user
user.login

fail "Repostiory #{repository} does not exist" unless client.repository?(repository)

reviewer_team = ReviewerTeam.new(organization: organization, name: review_team)

fail "Review Team #{review_team} does not exist" unless reviewer_team.exists?

fail "Review Team #{review_team} has no members" unless reviewer_team.has_members?

while true
  client.pull_requests(repository, state: 'open').each do |pr|
    reviewed = client.pull_request_reviews(repository, pr.number).any?
    requested = client.pull_request_review_requests(repository, pr.number)[:users].any?

    if !reviewed && !requested
      next_reviewer = reviewer_team.reviewer_for(pull_request: pr)

      logger.info("#{pr.html_url} assigned to #{next_reviewer}")

      client.request_pull_request_review(repository, pr.number, reviewers: [next_reviewer])

      reviewer_team.enqueue(member: next_reviewer)
    end
  end
  sleep 30
end
