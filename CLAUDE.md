# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

myKaraoke is a Ruby on Rails 7.1.6 karaoke playlist application with Spotify integration. Users create playlists, search songs via Spotify API, rate difficulty, and manage friendships.

**Stack**: Rails 7.1.6, Ruby 3.3.5, PostgreSQL, Bootstrap 5.3, Stimulus JS, Devise, Pundit, rspotify

## Common Commands

```bash
# Setup
bin/setup                         # Full dev environment setup (idempotent)
bin/rails db:seed                 # Seed with test users and Spotify songs

# Development
bin/rails server                  # Start server on localhost:3000
bin/rails console                 # Rails console

# Testing
bin/rails test                    # Run all tests
bin/rails test test/models/song_test.rb        # Single file
bin/rails test test/models/song_test.rb:15     # Single test by line number
bin/rails test:models             # Run model tests only
bin/rails test:system             # Run browser tests (Capybara/Selenium)

# Linting
bundle exec rubocop               # Check all files
bundle exec rubocop -A            # Auto-fix offenses

# Database
bin/rails db:migrate              # Run migrations
bin/rails db:schema:load          # Load schema from schema.rb
```

## Architecture

### Core Domain Models

- **User** → has_many Playlists, DifficultyRatings, Friendships (self-join)
- **Playlist** → belongs_to User, has_many Songs through PlaylistSongs (with position)
- **Song** → has ISRC (unique), spotify_id, difficulty_average, availability (JSONB)
- **DifficultyRating** → User rates a Song's difficulty level
- **Friendship** → Self-join (asker_id, receiver_id)
- **Favorite** → Polymorphic favoritor/favoritable (acts_as_favoritor gem)

### Key Patterns

**Authorization**: Pundit policies in `app/policies/`. ApplicationController enforces `after_action :verify_authorized` except for Devise/pages controllers.

**Spotify Integration**: `app/services/spotify_client.rb` singleton handles all Spotify API calls (search, auth, token refresh). User model stores OAuth tokens.

**Search**: pg_search gem for PostgreSQL full-text search on songs.

### Directory Structure

```
app/
├── controllers/    # 11 controllers, RESTful patterns
├── models/         # 7 models with ActiveRecord relationships
├── policies/       # Pundit authorization (8 policies)
├── services/       # SpotifyClient for external API
├── views/          # ERB templates, devise/ for auth
└── javascript/     # Stimulus controllers (swipe_controller.js for mobile)
```

## Configuration Notes

- `.env` contains Spotify API credentials (SPOTIFY_CLIENT_ID, SPOTIFY_CLIENT_SECRET)
- Test database: `my_karaoke_test` (parallel execution enabled)
- RuboCop configured with 120 char line limit, many style cops disabled
- PWA enabled with service worker at `/service_worker.js`

## Routes

- Root: `pages#landing`
- Home: `GET /home` → `pages#home`
- Playlists: Full CRUD with nested `playlist_songs`
- Songs: Show with nested `difficulty_ratings` and `favorites`
- Spotify OAuth: `/auth/spotify/callback`
