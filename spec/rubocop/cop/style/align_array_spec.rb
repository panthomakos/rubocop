# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::AlignArray do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/AlignArray' => cop_config,
                        'Style/IndentationWidth' => {
                          'Width' => 2
                        })
  end

  context 'no configuration' do
    let(:cop_config) { {} }

    it 'finds alignment mistakes' do
      inspect_source(cop, ['array = [',
                           '  a,',
                           '   b]'])
      expect(cop.offenses).to_not be_empty
    end

    it 'does not find indentation mistakes' do
      inspect_source(cop, ['array = [',
                           '   a,',
                           '   b]'])

      expect(cop.offenses).to be_empty
    end
  end

  context 'EnforcedStyle is align' do
    let(:cop_config) { { 'EnforcedStyle' => 'align' } }

    it 'registers an offense for misaligned array elements' do
      inspect_source(cop, ['array = [',
                           '  a,',
                           '   b,',
                           '  c,',
                           '   d',
                           ']'])
      expect(cop.messages).to eq(['Align the elements of an array ' \
                                  'literal if they span more than ' \
                                  'one line.'] * 2)
      expect(cop.highlights).to eq(%w(b d))
    end

    it 'accepts aligned array keys' do
      inspect_source(cop, ['array = [',
                           '  a,',
                           '  b,',
                           '  c,',
                           '  d',
                           ']'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts single line array' do
      inspect_source(cop, 'array = [ a, b ]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts several elements per line' do
      inspect_source(cop, ['array = [ a, b,',
                           '          c, d ]'])
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects alignment' do
      new_source = autocorrect_source(cop, ['array = [',
                                            '  a,',
                                            '   b,',
                                            '  c,',
                                            ' d',
                                            ']'])
      expect(new_source).to eq(['array = [',
                                '  a,',
                                '  b,',
                                '  c,',
                                '  d',
                                ']'].join("\n"))
    end

    it 'does not auto-correct array within array with too much indentation' do
      original_source = ['[:l1,',
                         '  [:l2,',
                         '',
                         '    [:l3,',
                         '     [:l4]]]]']
      new_source = autocorrect_source(cop, original_source)
      expect(new_source).to eq(['[:l1,',
                                ' [:l2,', # Corrected
                                '',
                                '   [:l3,', # Not corrected
                                '    [:l4]]]]'].join("\n"))
    end

    it 'does not auto-correct array within array with too little indentation' do
      original_source = ['[:l1,',
                         '[:l2,',
                         '',
                         '  [:l3,',
                         '   [:l4]]]]']
      new_source = autocorrect_source(cop, original_source)
      expect(new_source).to eq(['[:l1,',
                                ' [:l2,', # Corrected
                                '',
                                '   [:l3,', # Not corrected
                                '    [:l4]]]]'].join("\n"))
    end

    it 'auto-corrects only elements that begin a line' do
      original_source = ['array = [:bar, {',
                         '         whiz: 2, bang: 3 }, option: 3]']
      new_source = autocorrect_source(cop, original_source)
      expect(new_source).to eq(original_source.join("\n"))
    end

    it 'does not indent heredoc strings in autocorrect' do
      original_source = ['var = [',
                         "       { :type => 'something',",
                         '         :sql => <<EOF',
                         'Select something',
                         'from atable',
                         'EOF',
                         '       },',
                         "      { :type => 'something',",
                         '        :sql => <<EOF',
                         'Select something',
                         'from atable',
                         'EOF',
                         '      }',
                         ']']
      new_source = autocorrect_source(cop, original_source)
      expect(new_source).to eq(['var = [',
                                "       { :type => 'something',",
                                '         :sql => <<EOF',
                                'Select something',
                                'from atable',
                                'EOF',
                                '       },',
                                "       { :type => 'something',",
                                '         :sql => <<EOF',
                                'Select something',
                                'from atable',
                                'EOF',
                                '       }',
                                ']'].join("\n"))
    end
  end

  context 'EnforcedStyle is with_fixed_indentation' do
    let(:cop_config) { { 'EnforcedStyle' => 'with_fixed_indentation' } }

    it 'registers an offense for misindented array elements' do
      inspect_source(cop, ['array = [',
                           '  a,',
                           '   b,',
                           '  c,',
                           'd',
                           ']'])
      expect(cop.messages).to eq(['Indent the elements of an array ' \
                                  'literal if they span more than ' \
                                  'one line.'] * 2)
      expect(cop.highlights).to eq(%w(b d))
    end

    it 'accepts indented array keys' do
      inspect_source(cop, ['array = [',
                           '  a,',
                           '  b,',
                           '  c,',
                           '  d',
                           ']'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts single line array' do
      inspect_source(cop, 'array = [ a, b ]')
      expect(cop.offenses).to be_empty
    end

    it 'accepts several elements per line' do
      inspect_source(cop, ['array = [ a, b,',
                           '  c, d ]'])
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects indentation' do
      new_source = autocorrect_source(cop, ['array = [',
                                            '    a,',
                                            '   b,',
                                            '  c,',
                                            ' d',
                                            ']'])
      expect(new_source).to eq(['array = [',
                                '  a,',
                                '  b,',
                                '  c,',
                                '  d',
                                ']'].join("\n"))
    end

    it 'auto-corrects indentation in arrays within methods calls' do
      new_source = autocorrect_source(cop, ['method([',
                                            '    a,',
                                            '   b,',
                                            '  c,',
                                            ' d',
                                            '])'])
      expect(new_source).to eq(['method([',
                                '  a,',
                                '  b,',
                                '  c,',
                                '  d',
                                '])'].join("\n"))
    end

    it 'does not auto-correct array within array with too much indentation' do
      original_source = ['[:l1,',
                         ' [:l2,',
                         '',
                         '   [:l3,',
                         '     [:l4]]]]']
      new_source = autocorrect_source(cop, original_source)
      expect(new_source).to eq(['[:l1,',
                                '  [:l2,', # Corrected
                                '',
                                '    [:l3,', # Not corrected
                                '      [:l4]]]]'].join("\n"))
    end

    it 'does not auto-correct array within array with too little indentation' do
      original_source = ['[:l1,',
                         '[:l2,',
                         '',
                         '    [:l3,',
                         '      [:l4]]]]']
      new_source = autocorrect_source(cop, original_source)
      expect(new_source).to eq(['[:l1,',
                                '  [:l2,', # Corrected
                                '',
                                '      [:l3,', # Not corrected
                                '        [:l4]]]]'].join("\n"))
    end

    it 'auto-corrects only elements that begin a line' do
      original_source = ['array = [:bar, {',
                         '         whiz: 2, bang: 3 }, option: 3]']
      new_source = autocorrect_source(cop, original_source)
      expect(new_source).to eq(original_source.join("\n"))
    end

    it 'does not indent heredoc strings in autocorrect' do
      original_source = ['var = [',
                         "  { :type => 'something',",
                         '    :sql => <<EOF',
                         'Select something',
                         'from atable',
                         'EOF',
                         '  },',
                         "  { :type => 'something',",
                         '    :sql => <<EOF',
                         'Select something',
                         'from atable',
                         'EOF',
                         '  }',
                         ']']
      new_source = autocorrect_source(cop, original_source)
      expect(new_source).to eq(['var = [',
                                "  { :type => 'something',",
                                '    :sql => <<EOF',
                                'Select something',
                                'from atable',
                                'EOF',
                                '  },',
                                "  { :type => 'something',",
                                '    :sql => <<EOF',
                                'Select something',
                                'from atable',
                                'EOF',
                                '  }',
                                ']'].join("\n"))
    end
  end
end
