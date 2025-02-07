#!/bin/bash

# Function to display help message
function show_help {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  --streak          Show the current contribution streak."
  echo "  --contrib         Show today's contributions."
  echo "  --no-text         Remove text descriptions and show only numbers."
  echo "  --no-emoji        Remove emojis and show only numbers."
  echo "  --help            Show this help message."
}

# Default values for options
show_streak=true
show_contrib=true
no_text=false
no_emoji=false

# Process the command-line arguments
for arg in "$@"; do
  case $arg in
  --streak)
    show_contrib=false
    ;;
  --contrib)
    show_streak=false
    ;;
  --no-text)
    no_text=true
    ;;
  --no-emoji)
    no_emoji=true
    ;;
  --help)
    show_help
    exit 0
    ;;
  *) ;;
  esac
done

github_username=$(git config user.name)

# Fetch contribution data using GitHub API
contributions_json=$(gh api graphql -F username=$github_username -f query='
query($username: String!) {
  user(login: $username) {
    contributionsCollection {
      contributionCalendar {
        weeks {
          contributionDays {
            contributionCount
            date
          }
        }
      }
    }
  }
}')

# Get today's date in YYYY-MM-DD format
today=$(date +"%Y-%m-%d")

# Parse today's contributions
todays_contributions=$(echo "$contributions_json" | jq -r --arg today "$today" '
  .data.user.contributionsCollection.contributionCalendar.weeks[].contributionDays[]
  | select(.date == $today)
  | .contributionCount
')

# Default to 0 if no contributions today
todays_contributions=${todays_contributions:-0}

# Parse all contribution days
contributions=$(echo "$contributions_json" | jq -r '
  .data.user.contributionsCollection.contributionCalendar.weeks[].contributionDays[]
  | [.date, .contributionCount] | @tsv
')

# Calculate streak
streak=0
current_date=$today

while true; do
  count=$(echo "$contributions" | grep -P "^$current_date\t" | cut -f2)
  count=${count:-0}

  if [ "$count" -gt 0 ]; then
    streak=$((streak + 1))
    current_date=$(date -I -d "$current_date - 1 day")
  else
    break
  fi
done

# Function to display the output based on the arguments provided
function display_output() {
  local streak_output=""
  local contrib_output=""
  local emoji_streak="🔥"
  local emoji_contrib_yes="🟢"
  local emoji_contrib_no="🔴"

  # Handle streak output
  if [ "$show_streak" == "true" ]; then
    if [ "$streak" -eq 0 ]; then
      streak_output="No active streak 😢"
    else
      streak_output="Current Streak: $streak days $emoji_streak"
    fi
  fi

  # Handle contribution output
  if [ "$show_contrib" == "true" ]; then
    if [ "$todays_contributions" -gt 0 ]; then
      contrib_output="Today's Contributions: $todays_contributions $emoji_contrib_yes"
    else
      contrib_output="No contributions today $emoji_contrib_no"
    fi
  fi

  # Remove emojis if specified
  if [ "$no_emoji" == "true" ]; then
    streak_output=${streak_output//[$emoji_streak😢]/}
    contrib_output=${contrib_output//[$emoji_contrib_yes$emoji_contrib_no]/}
  fi

  # Handle no_text mode
  if [ "$no_text" == "true" ]; then
    streak_output=${streak_output//Current Streak: /}
    streak_output=${streak_output//No active streak /}
    streak_output=${streak_output//days /}
    contrib_output=${contrib_output//Today\'s Contributions: /}
    contrib_output=${contrib_output//No contributions today/}

    # Early exit if both outputs exist
    if [ -n "$streak_output" ] && [ -n "$contrib_output" ]; then
      echo "${streak_output## } ${contrib_output## }"
      return 0
    fi
  fi

  # Output results
  [ -n "$streak_output" ] && echo "${streak_output## }"
  [ -n "$contrib_output" ] && echo "${contrib_output## }"
}

# Call the function to display the output based on options
display_output
