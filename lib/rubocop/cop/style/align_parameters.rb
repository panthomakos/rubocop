# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # Here we check if the parameters on a multi-line method call are
      # aligned.
      class AlignParameters < Cop
        include AutocorrectAlignment
        include AlignmentOptions

        ALIGN_MSG = 'Align the parameters of a method call if they span ' \
          'more than one line.'

        INDENT_MSG = 'Indent the parameters of a method call if they span ' \
          'more than one line.'

        def on_send(node)
          _receiver, method, *args = *node

          return if method == :[]=
          return if args.size <= 1

          check_alignment(args, base_column(node, args))
        end

        private

        def target_method_lineno(node)
          if node.loc.selector
            node.loc.selector.line
          else
            # l.(1) has no selector, so we use the opening parenthesis instead
            node.loc.begin.line
          end
        end
      end
    end
  end
end
