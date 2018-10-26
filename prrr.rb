#!/usr/bin/env ruby
require "octokit"
require "logger"
require "yaml"
require_relative "lib/reviewer_team"
require_relative "lib/repositories"

config = Psych.safe_load(File.read("./config.yml"))

access_token = ENV.fetch("PRRR_ACCESS_TOKEN")

organization = config.keys.first
review_team = config[organization].fetch("review_team")

logger = Logger.new('/proc/1/fd/1')

Octokit.configure do |c|
  c.api_endpoint = "https://github.umn.edu/api/v3/"
end

client = Octokit::Client.new(:access_token => access_token)
PRRR_CLIENT = client

client.auto_paginate = true
user = client.user
user.login


reviewer_team = ReviewerTeam.new(organization: organization, name: review_team)

fail "Review Team #{review_team} does not exist" unless reviewer_team.exists?

fail "Review Team #{review_team} has no members" unless reviewer_team.has_members?

while true
  reviewer_team.refresh!

  repositories = Repositories.build(
    organization: organization,
    included: config[organization]["repositories"].to_a,
  )

  repositories.each do |repository|
    logger.info("checking repo #{repository.full_name}")

    if @most_recent_check
      next unless repository.pushed_at.utc > @most_recent_check.utc
    end

    client.pull_requests(repository.full_name, state: 'open').each do |pr|
      reviewed = client.pull_request_reviews(repository.full_name, pr.number).any?
      requested = client.pull_request_review_requests(repository.full_name, pr.number)[:users].any?

      if !reviewed && !requested
        next_reviewer = reviewer_team.reviewer_for(pull_request: pr)

        logger.info("#{pr.html_url} assigned to #{next_reviewer}")

        client.request_pull_request_review(repository.full_name, pr.number, reviewers: [next_reviewer])

        reviewer_team.enqueue(member: next_reviewer)
      end
    end
    sleep 1
  end

  @most_recent_check = Time.now
end
