# encoding: UTF-8

# Read http://betterspecs.org/ for suggestions writing good specs.

# Needed when chaining matchers. expect(...).not_to raise_error().and .. is not
# allowed.
RSpec::Matchers.define_negated_matcher :not_raise_error, :raise_error

# matcher to make game rule specs nicer to read
RSpec::Matchers.define :be_valid_to do |what, *args|
  match do |actual|
    actual.send('is_valid_to_' + what.to_s, *args) == true
  end
end
RSpec::Matchers.define_negated_matcher :not_be_valid_to, :be_valid_to

include GameStateHelpers

RSpec.describe GameRules do

  subject { GameRules }
  let(:gamestate) { GameState.new }

  context 'when a player is on start field' do
    before { state_from_string!('r0 C C C Cb C C C C C C C C G', gamestate) }

    it { is_expected.to not_be_valid_to(:fall_back, gamestate) }
    it { is_expected.to not_be_valid_to(:exchange_carrots, gamestate, 10) }
    it { is_expected.to not_be_valid_to(:play_eat_salad, gamestate) }
    it {
      # note that the distance to the next carrot field is its index because player is on field 0
      distance = gamestate.next_field_by_type(FieldType::CARROT, 0).index
      is_expected.to be_valid_to(:advance, gamestate, distance)
    }
  end
end
