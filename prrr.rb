#!/usr/bin/env ruby
require "octokit"
require "logger"
require "yaml"

module Prrr
  def self.run
    Octokit.configure do |c|
      c.api_endpoint = "https://github.umn.edu/api/v3/"
    end

    config = Prrr::Config.new
    logger = Prrr::Logger.new
    client = config.client

    while true
      config.organizations.each do |organization|
        reviewer_team = organization.reviewer_team
        reviewer_team.refresh!

        repositories = Repositories.build(
          organization: organization.name,
          included: organization.repositories,
          client: client,
        )

        repositories.each do |repository|
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
      end

      @most_recent_check = Time.now
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "lib", "**", "*.rb")) { |file| require file }

Prrr.run
