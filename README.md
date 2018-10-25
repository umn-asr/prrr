# PRRRR

Pull Request Review Request Requester

<img src="https://media.giphy.com/media/xUA7aVAw3xQ4pzYkiA/giphy.gif" />

Watches repositories for Pull Requests that need review. Requests a review from the next person in line.

## Setup

## GitHub Org and Repository

Currently this only watches a single repository for a single org. Edit [`prrr.rb`] to set your organization and repository name. 

Example:

```ruby
organization = "asrweb"
repository = "#{organization}/prrr"
```

### GitHub Access Token

- Go to your [Personal Access Token page](https://github.umn.edu/settings/tokens)
- Click "Generate New Token"
- Give your token a name, the exact name does not matter
- Choose `repo`
- Click the Generate Token button
- Copy your token somewhere safe
- Edit `prrr.rb` and replace `<your token here>` with your token

Example:

```ruby
access_token = "3102c1f0692be0986bbc0358f9285eb1fc99f334"
```

### GitHub Reviewer Team

- In your GitHub organization, [create a team](https://help.github.com/articles/creating-a-team/) of people you want to review Pull Requests. You can call this team whatever you'd like.

Example:

```ruby
review_team = "reviewers"
```

## Usage

Requires that you have Docker installed and running.

Two options:

- `./run`

or

- `docker build -t prrrr .`
- `docker run -it --rm prrr`

## Problems

### I don't want this person to review PRs anymore!

Remove them from your GitHub Reviewer Team

### I want this bot to do something different!

Gopher It. Pull requests are welcome.
