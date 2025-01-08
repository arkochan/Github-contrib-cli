# GitHub Contribution Streak Tracker

A simple Bash script to track and display GitHub contribution streaks and today's contributions.

## Features:
- Show current contribution streak.
- Display today's contributions with emojis or text (optional).
- Supports different command-line arguments for customization.
- Provides easy-to-read outputs with numbers.

## Usage:
```bash
./contribution-streak.sh [OPTIONS]
```

## Options: 
 
- `--streak` Show the current contribution streak.
 
- `--contrib` Show today's contributions.
 
- `--no-text` Remove text descriptions and show only numbers.
 
- `--no-emoji` Remove emojis and show only numbers.
 
- `--help` Show this help message.

## Example Usage: 
 
- **Default Output:** 

```bash
./contribution-streak.sh
```
 
  - **Output:** 

```yaml
Current Streak: 9 days 🔥
Today's Contributions: 5 🟢
```
 
- **Without Emojis:** 

```bash
./contribution-streak.sh --no-emoji
```
 
  - **Output:** 

```yaml
Current Streak: 9 days
Today's Contributions: 5
```
 
- **Only Streak:** 

```bash
./contribution-streak.sh --streak
```
 
  - **Output:** 

```sql
Current Streak: 9 days 🔥
```
 
- **Only Contributions Today:** 

```bash
./contribution-streak.sh --contrib
```
 
  - **Output:** 

```mathematica
Today's Contributions: 5 🟢
```

## Requirements: 
 
- `gh CLI` installed and authenticated.


---
