#!/usr/bin/env ruby
require "octokit"
require "logger"

organization = ENV.fetch("PRRR_ORGANIZATION")
repository = "#{organization}/#{ENV.fetch("PRRR_REPOSITORY")}"
access_token = ENV.fetch("PRRR_ACCESS_TOKEN")
review_team = ENV.fetch("PRRR_REVIEW_TEAM")

logger = Logger.new('/proc/1/fd/1')

Octokit.configure do |c|
  c.api_endpoint = "https://github.umn.edu/api/v3/"
end

client = Octokit::Client.new(:access_token => access_token)

user = client.user
user.login

fail "Repostiory #{repository} does not exist" unless client.repository?(repository)

reviewer_team = client.organization_teams(organization).detect  do |team|
  team.name.casecmp(review_team).zero?
end

fail "Review Team #{review_team} does not exist" unless reviewer_team

reviewers = client.team_members(reviewer_team.id).map {|member| member.login }

fail "Review Team #{review_team} has no members" unless reviewers

while true
  client.pull_requests(repository, state: 'open').each do |pr|
    reviewed = client.pull_request_reviews(repository, pr.number).any?
    requested = client.pull_request_review_requests(repository, pr.number)[:users].any?

    if !reviewed && !requested
      next_reviewer = reviewers.detect { |r| !r.casecmp(pr.user.login).zero? }

      logger.info("#{pr.html_url} assigned to #{next_reviewer}")

      client.request_pull_request_review(repository, pr.number, reviewers: [next_reviewer])

      reviewers.delete(next_reviewer)
      reviewers.push(next_reviewer)
    end
  end
  sleep 30
end
