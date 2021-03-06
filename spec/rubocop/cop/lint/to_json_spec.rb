# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ToJSON do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using `#to_json` without arguments' do
    expect_offense(<<~RUBY)
      def to_json
      ^^^^^^^^^^^  `#to_json` requires an optional argument to be parsable via JSON.generate(obj).
      end
    RUBY
  end

  it 'does not register an offense when using `#to_json` with arguments' do
    expect_no_offenses(<<~RUBY)
      def to_json(*_args)
      end
    RUBY
  end

  it 'autocorrects' do
    corrected = autocorrect_source(<<~RUBY)
      def to_json
      end
    RUBY
    expect(corrected).to eq(<<~RUBY)
      def to_json(*_args)
      end
    RUBY
  end
end
