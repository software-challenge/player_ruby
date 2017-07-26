# encoding: UTF-8
# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
directories %w(lib lib/software_challenge_client spec)
# the following seems to cause problems in certain ruby versions:
# directories %w(lib lib/software_challenge_client spec).select do |d|
#   Dir.exist?(d) ? d : UI.warning("Directory #{d} does not exist")
# end

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

# This group allows to skip running RuboCop when RSpec failed.
group :red_green_refactor, halt_on_fail: true do
  guard :rspec, cmd: 'rspec', all_after_pass: true, all_on_start: true do
    watch(%r{^lib/software_challenge_client/(.+)\.rb$}) do |match|
      spec_file = "spec/#{match[1]}_spec.rb"
      if File.exist?(spec_file)
        spec_file # run spec belonging to the file which was changed
      else
        'spec' # run all specs
      end
    end
    watch(%r{^spec/.+_spec\.rb$}) # no block means the matched file is returned

    watch('lib/software_challenge_client.rb') { 'spec' }
    watch('spec/spec_helper.rb') { 'spec' }
  end

  # guard :rubocop, all_on_start: false do
  #   # This never includes external ruby files because of the
  #   # directory constraint at the top of this file:
  #   watch(/.*.rb/)
  # end
end
