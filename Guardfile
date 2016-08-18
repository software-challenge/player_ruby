# A sample Guardfile
# More info at https://github.com/guard/guard#readme

## Uncomment and set this to only include directories you want to watch
#directories %w(lib lib/software_challenge_client spec) \
# .select{|d| Dir.exists?(d) ? d : UI.warning("Directory #{d} does not exist")}

## Note: if you are using the `directories` clause above and you are not
## watching the project directory ('.'), then you will want to move
## the Guardfile to a watched dir and symlink it back, e.g.
#
#  $ mkdir config
#  $ mv Guardfile config/
#  $ ln -s config/Guardfile .
#
# and, you'll have to watch "config/Guardfile" instead of "Guardfile"

guard :rspec, cmd: 'rspec', all_after_pass: true, all_on_start: true do
  watch(%r{^lib/software_challenge_client/(.+)\.rb$}) do |match|
    spec_file = "spec/#{match[1]}_spec.rb";
    if File.exists?(spec_file)
      spec_file # run spec belonging to the file which was changed
    else
      'spec' # run all specs
    end
  end
  watch(%r{^spec/.+_spec\.rb$}) # no block means the matched file is returned (an run)

  watch('lib/software_challenge_client.rb') { 'spec' }
  watch('spec/spec_helper.rb')  { 'spec' }
end
