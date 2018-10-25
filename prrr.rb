#!/usr/bin/env ruby
require "octokit"

Octokit.configure do |c|
  c.api_endpoint = "https://github.umn.edu/api/v3/"
end

organization = "<your organiziaton here>"
repository = "#{organization}/<your repository name here>"
access_token = "<your token here>"
review_team = "<your review team name here>"

client = Octokit::Client.new(:access_token => access_token)

user = client.user
user.login

reviewer_team = client.organization_teams(organization).detect  do |team|
  team.name.casecmp(review_team).zero?
end

reviewers = client.team_members(reviewer_team.id).map {|member| member.login }

while true
  if client.repository?(repository)
    repo = client.repository(repository)

    client.pull_requests(repository, state: 'open').each do |pr|
      reviewed = client.pull_request_reviews(repository, pr.number).any?
      requested = client.pull_request_review_requests(repository, pr.number)[:users].any?

      if !reviewed && !requested
          next_reviewer = reviewers.detect { |r| !r.casecmp(pr.user.login).zero? }

          client.request_pull_request_review(repository, pr.number, reviewers: [next_reviewer])

          reviewers.delete(next_reviewer)
          reviewers.push(next_reviewer)
      end
    end
  else
    fail "Repository #{repository} does not exist"
  end
  sleep 30
end
