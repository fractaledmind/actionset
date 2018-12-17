# frozen_string_literal: true

# rubocop:disable Style/AsciiComments
# Returns a Numeric for `value` that respects sort-order
# can be used in Enumerable#sort_by
#
# transform_to_sortable_numeric(1)
# => 1
# transform_to_sortable_numeric('aB09ü')
# => (24266512014313/250000000000)
# transform_to_sortable_numeric(true)
# => 1
# transform_to_sortable_numeric(Date.new(2000, 12, 25))
# => 977720400000

# rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
def transform_to_sortable_numeric(value)
  # https://www.justinweiss.com/articles/4-simple-memoization-patterns-in-ruby-and-one-gem/#and-what-about-parameters
  @sortable_numeric ||= Hash.new do |h, key|
    h[key] = if key.is_a?(Numeric)
               key
             elsif key == true
               1
             elsif key == false
               0
             elsif key.is_a?(String) || key.is_a?(Symbol)
               key
                 .to_s                                         # 'aB09ü'
                 .split('')                                    # ["a", "B", "0", "9", "ü"]
                 .map { |char| char.ord.to_s.rjust(3, '0') }   # ["097", "066", "048", "057", "252"]
                 .insert(1, '.')                               # ["097", ".", "066", "048", "057", "252"]
                 .reduce(&:concat)                             # "097.066048057252"
                 .to_r                                         # (24266512014313/250000000000)
             elsif key.respond_to?(:to_time)
               # https://stackoverflow.com/a/30604935/2884386
               (key.to_time.to_f * 1000).round
             else
               key
             end
  end
  @sortable_numeric[value]
end
# rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
# rubocop:enable Style/AsciiComments
