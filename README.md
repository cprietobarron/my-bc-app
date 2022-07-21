# Channels Ruby App template

> Channels App template.

[![Ruby][ruby-badge]][ruby-url]
[![Rails][rails-badge]][rails-url]
[![PostgreSQL][psql-badge]][psql-url]
[![Redis][redis-badge]][redis-url]

## How to use

1. Create a new project using this template.
2. Change the module name in `config/application.rb` file. From `ChannelsRubyApp` to your app name.
3. Change `channel_prefix` in `config/cable.yml` file. From `channels_ruby_app*` to your app name.
4. Change `database` in `config/database.yml` file. From `channels_ruby_app_*` to your app name.
5. Change `channel_ruby_use_dev_token` in `config/feature_flags.yml`. Make sure to keep `_use_dev_token` suffix.
6. Create your .env file: `cp .env.template .env`
7. Run `bundle install`
8. Run `rails db:setup`

## How it was generated?

```bash
rails new -T -d postgresql --api channels-ruby-app
rails bundle install
rails generate annotate:install
rails generate rspec:install
```

<!-- Links -->
[ruby-badge]: https://img.shields.io/badge/ruby-3.1-blue?style=flat&logo=ruby&logoColor=CC342D&labelColor=white
[ruby-url]: https://www.ruby-lang.org/en/
[rails-badge]: https://img.shields.io/badge/rails-7.0-blue?style=flat&logo=ruby-on-rails&logoColor=CC0000&labelColor=white
[rails-url]: https://rubyonrails.org/
[psql-badge]: https://img.shields.io/badge/PostgreSQL-14-blue?style=flat&logo=postgresql&logoColor=336791&labelColor=white
[psql-url]: https://www.postgresql.org/download/
[redis-badge]: https://img.shields.io/badge/redis-6-blue?style=flat&logo=redis&logoColor=DC382D&labelColor=white
[redis-url]: https://redis.io/topics/quickstart
