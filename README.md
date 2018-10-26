# PRRR

Pull Request Review Request Requester

<img src="https://media.giphy.com/media/xUA7aVAw3xQ4pzYkiA/giphy.gif" />

Watches repositories for Pull Requests that need review. Requests a review from the next person in line.

## Setup

### `docker-compose.yml`

- `docker pull asr-docker-local.artifactory.umn.edu/prrr:latest`
- Create a `docker-compose.yml` file that looks like

```yaml
version: '2'

services:
  prrr:
    image: asr-docker-local.artifactory.umn.edu/prrr:latest
    restart: always
    volumes:
      - ${PWD}/config.yml:/usr/src/app/config.yml
    environment:
      - PRRR_ACCESS_TOKEN=3102c1f0692be0986bbc0358f9285eb1fc99f334
```

### PRRR Access Token

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

If you want to watch all repositories within the organization, leave out the repository key:

```yml
---
asrweb:
  review_team: reviewers
```

If you want multiple organizations, each will need their own review_team.

```yml
---
asrweb:
  review_team: reviewers
docker:
  review_team: docker_helpers
ansible-roles:
  review_team: ansible_committee
```

#### Review Team

The team of GitHub users you want reviewing Pull Requests.

In your GitHub organization, [create a team](https://help.github.com/articles/creating-a-team/) of people you want to review Pull Requests. You can call this team whatever you'd like.

## Usage

`docker-compose up -d`

## Problems

### I don't want this person to review PRs anymore!

Remove them from your GitHub Reviewer Team

### I want this bot to do something different!

PRRRfect. Pull requests are welcome.
