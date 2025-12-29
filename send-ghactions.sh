#!/bin/bash

# Required variables:
# CURRENT_DATE: $(date +"%Y%m%d-%H%M%S")
# AUTHOR_NAME: $(git log -1 "$GITHUB_SHA" --pretty="%aN")
# COMMITTER_NAME: $(git log -1 "$GITHUB_SHA" --pretty="%cN")
# COMMIT_SUBJECT: $(git log -1 "$GITHUB_SHA" --pretty="%s")
# COMMIT_MESSAGE: $(git log -1 "$GITHUB_SHA" --pretty="%b")

if [ -z "$2" ]; then
  echo -e "WARNING!!\nYou need to pass the WEBHOOK_URL environment variable as the second argument to this script.\nFor details & guide, visit: https://github.com/DS-Homebrew/discord-webhooks" && exit
fi

echo -e "[Webhook]: Sending webhook to Discord...\\n";

REPO=$(cut -d/ -f2 <<< $GITHUB_REPOSITORY)
REF=$(cut -d/ -f3 <<< $GITHUB_REF)

case $1 in
  "success" )
    EMBED_COLOR=3066993
    STATUS_MESSAGE="succeded"
    DESCRIPTION="[\`$COMMIT_HASH\`](https://github.com/$GITHUB_REPOSITORY/releases/tag/git) $COMMIT_SUBJECT - $AUTHOR_NAME"
    ;;

  "failure" )
    EMBED_COLOR=15158332
    STATUS_MESSAGE="failed"
    ;;

  * )
    EMBED_COLOR=0
    STATUS_MESSAGE="status unknown"
    ;;
esac

WEBHOOK_DATA='{
  "username": "GitHub Actions",
  "avatar_url": "https://raw.githubusercontent.com/Universal-Team/discord-webhooks/master/github-logo.png",
  "embeds": [
    {
      "color": '$EMBED_COLOR',
      "title": "['$REPO':'$REF'] '${GITHUB_SHA:0:7}' build '"$STATUS_MESSAGE"'",
      "url": "https://github.com/'$GITHUB_REPOSITORY'/commit/'$GITHUB_SHA'",
      "description": "'"$DESCRIPTION"'",
      "image": {
        "url": "'$IMAGE'"
      }
    }
  ]
}'

(curl --fail --progress-bar -A "Github-Actions-Webhook" -H Content-Type:application/json -H X-Author:k3rn31p4nic#8383 -d "$WEBHOOK_DATA" "$2" \
  && echo -e "\\n[Webhook]: Successfully sent the webhook.") || echo -e "\\n[Webhook]: Unable to send webhook."
