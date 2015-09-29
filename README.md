# Software Challenge Client

This gem includes everything to build a client for the coding
competition [Software-Challenge](http://www.software-challenge.de).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'software_challenge_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install software_challenge_client

## Usage

See the example client in the example directory.

You can execute the example client by entering

```console
ruby main.rb
```

in a shell (while being in the example directory). Note that the
software_challenge_client gem needs to be installed for this to work and a
server waiting for a manual client has to be running.

## Development

After checking out the repo, run `bin/setup` to install
dependencies. Then, run `rake false` to run the tests. You can also
run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake
install`.

### Releasing

To release a new version, update the version number in
`lib/software_challenge_client/version.rb` and update RELEASES.md. Then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/CAU-Kiel-Tech-Inf/socha_ruby_client. This project
is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the
[Contributor Covenant](contributor-covenant.org) code of conduct.
