# frozen_string_literal: true

require_relative '../../enumerable_set_instruction'

class ActiveSet
  module Filtering
    module Enumerable
      class SetInstruction < EnumerableSetInstruction
        def set_item
          return @set_item if defined? @set_item

          @set_item = @set.find(&:present?)
        end

        def attribute_instance
          return set_item if @attribute_instruction.associations_array.empty?
          return @attribute_model if defined? @attribute_model

          @attribute_model = @attribute_instruction
                             .associations_array
                             .reduce(set_item) do |obj, assoc|
            obj.public_send(assoc)
          end
        end

        def attribute_class
          attribute_instance&.class
        end
      end
    end
  end
end
