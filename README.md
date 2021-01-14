# Decidim::Castings

The gem has been developed by [Belighted](https://www.belighted.com/).

A [Decidim](https://github.com/decidim/decidim) module to cast a committee composition based on the list of people.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-castings"
```

And then execute:

```bash
$ bundle
$ bundle exec rails decidim_castings:install:migrations
$ bundle exec rails db:migrate
```

To keep the gem up to date, you can use the commands above to also update it.

Add partial rendering to the `app/views/layouts/decidim/admin/_header.html.erb`:
```
<%= render partial: "layouts/decidim/admin/castings" %>
```

## Testing

Create a dummy app in the `spec` dir:
```bash
$ DATABASE_USERNAME=<username> DATABASE_PASSWORD=<password>  bundle exec rake decidim:generate_external_test_app
$ cd spec/decidim_dummy_app
$ bundle exec rails decidim_castings:install:migrations
$ RAILS_ENV=test bundle exec rails db:migrate
```

Apply changes to decidim_dummy_app and provide configuration mentioned in [How to](#how-to-install) section.

Run tests:

```bash
bundle exec rspec spec
```

### Test code coverage

If you want to generate the code coverage report for the tests, you can use the SIMPLECOV=1
environment variable in the rspec command as follows:

```bash
$ SIMPLECOV=1 bundle exec rspec
```

This will generate a folder named coverage in the project root which contains the code coverage report.


## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
