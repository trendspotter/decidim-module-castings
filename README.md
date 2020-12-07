# Decidim::Castings

The gem has been developed by [Belighted](https://www.belighted.com/).

A [Decidim](https://github.com/decidim/decidim) module to cast a committee composition based on the list of people.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "decidim-term_customizer"
```

And then execute:

```bash
$ bundle
$ bundle exec rails decidim_castings:install:migrations
$ bundle exec rails db:migrate
```

To keep the gem up to date, you can use the commands above to also update it.

Add js tags to the `app/views/layouts/decidim/admin/_header.html.erb`:
```
<%= javascript_include_tag "https://cdn.jsdelivr.net/npm/chart.js@2.9.3" %>
<%= javascript_include_tag "https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@0.7.0" %>
```

## License

See [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt).
