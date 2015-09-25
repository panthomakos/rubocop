# encoding: utf-8

module RuboCop
  module Cop
    # This module provides alignment offsets and offense messages based on the
    # EnforcedStyle specified in the cop.
    #
    # EnforcedStyles:
    #
    # * align - will align each parameter with the first in the list
    # * with_fixed_indentation - will align each parameter based on the
    #   configured indentation width
    module AlignmentOptions
      def message(*_args)
        fixed_indentation? ? self.class::INDENT_MSG : self.class::ALIGN_MSG
      end

      private

      def fixed_indentation?
        cop_config && cop_config['EnforcedStyle'] == 'with_fixed_indentation'
      end

      def base_column(node, children)
        if fixed_indentation?
          lineno = target_method_lineno(node)
          line = node.loc.expression.source_buffer.source_line(lineno)
          indentation_of_line = /\S.*/.match(line).begin(0)
          indentation_of_line + configured_indentation_width
        else
          children.first.loc.column
        end
      end

      def target_method_lineno(node)
        node.loc.begin.line
      end
    end
  end
end
