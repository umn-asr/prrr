# PRRRR

Pull Request Review Request Requester

<img src="https://media.giphy.com/media/xUA7aVAw3xQ4pzYkiA/giphy.gif" />

Watches repositories for Pull Requests that need review. Requests a review from the next person in line.

## Setup

### `docker-compose.yml`

- `docker pull asr-docker-local.artifactory.umn.edu/prrr:0.2.0`
- Create a `docker-compose.yml` file that looks like

```yaml
version: '2'

services:
  prrr:
    image: asr-docker-local.artifactory.umn.edu/prrr:0.2.0
    restart: always
    environment:
      - PRRR_ORGANIZATION=asrweb
      - PRRR_REPOSITORY=student_athletes
      - PRRR_ACCESS_TOKEN=3102c1f0692be0986bbc0358f9285eb1fc99f334
      - PRRR_REVIEW_TEAM=reviewers
```

A brief description of these environment variables and what they do:

### Access Token

You will need a GitHub Personal Access token so that PRRR can interact with GitHub.

- Go to your [Personal Access Token page](https://github.umn.edu/settings/tokens)
- Click "Generate New Token"
- Give your token a name, the exact name does not matter
- Choose `repo`
- Click the Generate Token button
- Place your token in the `docker-compose.yml` file

### `config.yml`

Configure which GitHub organizations and repositories you want to observe with `config.yml`. The structure should be:

```yml
---
org_name:
  repositories:
  - repo_name
  review_team: name_of_team
```

A filled-out example is:

```yml
---
asrweb:
  repositories:
  - prrr
  review_team: reviewers
```

#### Review Team

The team of GitHub users you want reviewing Pull Requests.

In your GitHub organization, [create a team](https://help.github.com/articles/creating-a-team/) of people you want to review Pull Requests. You can call this team whatever you'd like.

#### Limitations

Currently you can only have one organization and one repository. Additional repositories will be ignored.

## Usage

`docker-compose up -d`

## Problems

### I don't want this person to review PRs anymore!

Remove them from your GitHub Reviewer Team

### I want this bot to do something different!

PRRRfect. Pull requests are welcome.
