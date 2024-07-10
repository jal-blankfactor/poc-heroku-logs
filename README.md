# PoC Heroku Logs

## Setup

### MacOS

```bash
brew install awscli

# for local testing
brew install --cask docker

brew tap hashicorp/tap
brew install hashicorp/tap/terraform

brew tap heroku/brew
brew install heroku
```

## Dev

```bash
# Manage heroku drains
heroku drains -a poc-heroku-logs
heroku drains:add -a poc-heroku-logs <url>
heroku drains:remove -a poc-heroku-logs <url>

# After terraform init
terraform -chdir="./terraform" workspace select dev
terraform -chdir="./terraform" apply

```
