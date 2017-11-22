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
`software_challenge_client` gem needs to be installed for this to work and a
server waiting for a manual client has to be running.

## Documentation

Code documentation can be generated using YARD in the project root (source code
needs to be checked out and `bundle` has to be executed,
see [Installation](#installation)):

```console
yard
```

After generation, the docs can be found in the `doc` directory. Start at
`index.html`.

Documentation for the latest source can also be found
on
[rubydoc.info](http://www.rubydoc.info/github/CAU-Kiel-Tech-Inf/socha_ruby_client).

When updating the docs, you may use

```console
yard server --reload
```

or inside a docker container

```console
yard server --reload --bind 0.0.0.0
```

to get a live preview of them at [http://localhost:8808](http://localhost:8808).

## Development

After checking out the repo, run `bin/setup` to install
dependencies. Then, run `rspec` to run the tests. You can also
run `bin/console` for an interactive prompt that will allow you to
experiment.

To install this gem onto your local machine, run `bundle exec rake
install`.

To develop inside a docker container, make sure you have Docker installed and execute
`develop.sh`.

### Specs

The gem is tested using RSpec. To run all tests, execute `rspec`. When
developing, you may use Guard to execute tests when files change. To do this,
execute `guard`. Tests will then be automatically run when you change a file.

### Linting

Linting by rubocop is included in the guard config. It is run when all specs
pass.

### Releasing

To release a new version, update the version number in
`lib/software_challenge_client/version.rb` and update RELEASES.md.

Then run `bundle exec rake release`, which will create a git tag for the
version, push git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org). You may also use the `release.sh` script
which executes `bundle exec rake release` in a suitable docker container.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/CAU-Kiel-Tech-Inf/socha_ruby_client. This project
is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the
[code of conduct](CODE_OF_CONDUCT.md) (from
[Contributor Covenant](http://contributor-covenant.org)).
