# frozen_string_literal: true

require 'active_support/core_ext/array/wrap'

# Returns a flat hash where all nested keys are flattened into an array of keys.
#
#   hash = { key: 'value', nested: { key: 'nested_value' }, array: [0, 1, 2] }
#   flatten_keys_of(hash)
#   => { [:key]=>"value", [:nested, :key]=>"nested_value", [:array]=>[0, 1, 2] }
#
# Can also pass a Proc to change how nested keys are flattened:
#   flatten_keys_of(hash, flattener: ->(*keys) { keys.join('.') })
#   => { "key"=>"value", "nested.key"=>"nested_value", "array"=>[0, 1, 2] }
#   flatten_keys_of(hash, flattener: ->(*keys) { keys.join('-') })
#   => { "key"=>"value", "nested-key"=>"nested_value", "array"=>[0, 1, 2] }
#   flatten_keys_of(hash, flattener: ->(*keys) { keys.map(&:to_s).reduce { |memo, key| memo + "[#{key}]" } })
#   => { "key"=>"value", "nested[key]"=>"nested_value", "array"=>[0, 1, 2] }
#
# Can also determine if array values should be flattened as well:
#   hash = { person: { age: '28', siblings: ['Tom', 'Sally'] } }
#   flatten_keys_of(hash, flatten_arrays: true)
#   => { [:key]=>"value", [:nested, :key]=>"nested_value", [:array, 0]=>0, [:array, 1]=>1, [:array, 2]=>2 }
#   flatten_keys_of(hash, flattener: ->(*keys) { keys.join('.') }, flatten_arrays: true)
#   => { "key"=>"value", "nested.key"=>"nested_value", "array.0"=>0, "array.1"=>1, "array.2"=>2 }

# refactored from https://stackoverflow.com/a/23861946/2884386
def flatten_keys_of(input, keys = [], output = {}, flattener: ->(*k) { k }, flatten_arrays: false)
  if input.is_a?(Hash)
    input.each do |key, value|
      flatten_keys_of(
        value,
        keys + Array.wrap(key),
        output,
        flattener: flattener,
        flatten_arrays: flatten_arrays
      )
    end
  elsif input.is_a?(Array) && flatten_arrays
    input.each_with_index do |value, index|
      flatten_keys_of(
        value,
        keys + Array.wrap(index),
        output,
        flattener: flattener,
        flatten_arrays: flatten_arrays
      )
    end
  else
    return output.merge!(flattener.call(*keys) => input)
  end

  output
end
