# Musik88

Hey 👋

Welcome to this awesome project. Since you're here, I assume you love music like I do. So, turn it up!

## Tech stack

This is a `Ruby on Rails` 6 application with several dependencies. 

1. Sidekiq for background job.
2. Redis for in-memory database. This one is only used by the Sidekiq for now.
3. PostgreSQL for the database.
4. Yarn for the frontend.
5. yt-dlp to download youtube to audio.

`yt-dlp` needs the `ffmpeg`:

Make sure you have the latest version for yt-dlp:
sudo yt-dlp -U

After that you can solve this problem by installing the missing ffmpeg.

Ubuntu and debian:
sudo apt-get install ffmpeg

macOS:
brew install ffmpeg

Windows:
choco install ffmpeg
```

Several recommendation to running this project in one's development machine:

1. Recommended ruby version mamager is `rbenv`.
2. Use Ruby in the `.ruby-version` file.
3. Progress.app client is recommended.
4. Use `nvm` to manage your Node version. Use Node version in the `.nvmrc` file.
5. User Postbird app to manage your PostgreSQL.
6. Use `mkcert` for local certificates.

## Sidekiq

We use Sidekiq for background task management. Run local sidekiq: `bundle exec sidekiq`

## Running local development

1. Clone the app.
2. Install Ruby with the `rbenv`.
3. Run `bundle install`.
4. Copy the `master.key` file from the server. Make sure you've uploaded your key so you can ssh to the box.
```bash
scp deploy@musik88.com:apps/musik88-web/config/master.key config/master.key
```
5. Create a `musik88_com_development` database.
6. Run `rails db:migrate`.
7. Run `yarn install`.
8. Run `rails s`.

### Database

1. Dump db from production with the command from the ssh server: pg_dump -h localhost -U dbuser -Fc dbname > dbname.dump
2. Download the dump file: scp deploy@musik88.com:apps/path-to-dump-file.dump
3. Import to your local db: pg_restore -c -d musik88_com_development musik88_com_production.dump

There's a known issue with the db production and development about the meta table. If one's copy the db content from production, update the local schema migration table by adding a new row with the content from the schema.rb

## Issues found

Fix libv8

1. bundle config build.libv8 --with-system-v8
gem install pg -v '1.2.3' -- --with-pg-config=/Applications/Postgres.app/Contents/Versions/14/bin/pg_config


### Mac M1 Chip

Avoid opening your terminal using Rosetta, it will make things messier.

rbenv 3.0.2 Mac M1

```bash
$ export SDKROOT="$(xcrun -show-sdk-path -sdk macosx)" # because the /usr/bin/clang shim automatically set it
$ export RUBY_CONFIGURE_OPTS="CC=$(xcrun -f clang)"
$ rbenv install 3.1.3
```

# Issue with openssl
OPENSSL_CFLAGS=-Wno-error=implicit-function-declaration RUBY_CONFIGURE_OPTS=--with-readline-dir="$(brew --prefix readline)" rbenv install 3.0.6 --verbose

## Use local `.env` file
Provide sets of environment variables to run this app locally. 


## Application documentation

### Follow me

This feature based on the infamous Michael Hart RoR tutorials: https://3rd-edition.railstutorial.org/book/following_users

### JWT


https://enlear.academy/how-to-create-a-rails-6-api-with-devise-jwt-46fa35085e85
https://tergell.medium.com/rails-devise-jwt-tutorial-b5d5b03d9040

### Mailers

During the development, any mailer wil be handled by the `letter_opener` gem. To preview emails, visit `https://localhost:3001/rails/mailers/` during development.

## Test

### Run test

bundle exec rake test
