# frozen_string_literal: true

require 'active_support/core_ext/array/wrap'

# Returns a flat hash where all nested keys are collapsed into an array of keys.
#
#   hash = { person: { name: { first: 'Rob' }, age: '28' } }
#   flatten_keys_of(hash)
#   => { [:person, :name, :first]=>"Rob", [:person, :age]=>"28" }
#
# Can also pass a Proc to change how nested keys are collapsed:
#   flatten_keys_of(hash, flattener: ->(*keys) { keys.join('.') })
#   => { "person.name.first"=>"Rob", "person.age"=>"28" }
#   flatten_keys_of(hash, flattener: ->(*keys) { keys.join('-') })
#   => { "person-name-first"=>"Rob", "person-age"=>"28" }
#   flatten_keys_of(hash, flattener: ->(*keys) { keys.map(&:to_s).reduce { |memo, key| memo + "[#{key}]" } })
#   => { "person[name][first]"=>"Rob", "person[age]"=>"28" }

# refactored from https://stackoverflow.com/a/23861946/2884386
def flatten_keys_of(input, keys = [], output = {}, flattener: ->(*keys) { keys }, flatten_arrays: false)
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
