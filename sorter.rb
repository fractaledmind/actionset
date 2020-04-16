require 'test/unit'
require 'date'

class Sorter
  def initialize(*instructions)
    @defaults = {
      direction: :ascending,
      nils: :small,
      accessor: :itself,
      case_sensitive: true,
      normalized: false,
      natural: false
    }
    @instructions = instructions.map do |instruction|
      @defaults.merge(instruction)
    end
  end

  def sort(array)
    array.sort_by do |item|
      @instructions.map do |instruction|
        raw_value             =   access_value(from: item, at: instruction[:accessor])
        processed_value       =   process_value(from: raw_value, given: instruction)
        numeric_value         =   numeric_value(from: processed_value)
        direction_multiplier  =   direction_multiplier(given: instruction[:direction])
        nils_multiplier       =   nils_multiplier(given: instruction[:nils])

        # p({ raw_value: raw_value, processed_value: processed_value, numeric_value: numeric_value, direction_multiplier: direction_multiplier, nils_multiplier: nils_multiplier })

        if numeric_value.nil?                           # [1, 0] [-1, 0]
          [direction_multiplier * nils_multiplier, 0]
        else                                            # [0, n] [0, -n]
          [0, numeric_value * direction_multiplier]
        end                                             # [-1, 0] [0, -n] [0, n] [1, 0]
      end
    end
  end

  private

  def access_value(from:, at:)
    path = at.to_s.split('.')
    path.reduce(from) do |object, signal|
      break nil unless object.respond_to? signal

      object.public_send(signal)
    end
  end

  def process_value(from:, given:)
    return from                     unless from.is_a?(String) || from.is_a?(Symbol)
    return from.downcase            unless given[:case_sensitive]
    return normalize(from) + from   if given[:normalized]
    return segment(from)            if given[:natural]

    from
  end

  def numeric_value(from:)
    return from   if from.is_a?(Numeric)
    return 1      if from == true
    return 0      if from == false

    if from.is_a?(String) || from.is_a?(Symbol)
      string_to_numeric_value(from)
    elsif from.is_a?(Date)
      time_to_numeric_value(Time.new(from.year, from.month, from.day, 0o0, 0o0, 0o0, 0))
    elsif from.respond_to?(:to_time)
      time_to_numeric_value(from.to_time)
    elsif from.respond_to?(:map)
      segment_array_to_numeric_value(from)
    else
      from
    end
  end

  def direction_multiplier(given:)
    return -1 if given == :descending

    1
  end

  def nils_multiplier(given:)
    return -1 if given == :small

    1
  end

  def string_to_numeric_value(string)
    string                                          # "aB09ü""
      .chars                                        # ["a", "B", "0", "9", "ü"]
      .map { |char| char.ord.to_s.rjust(3, '0') }   # ["097", "066", "048", "057", "252"]
      .insert(1, '.')                               # ["097", ".", "066", "048", "057", "252"]
      .reduce(&:concat)                             # "097.066048057252"
      .to_r                                         # (24266512014313/250000000000)
  end

  def time_to_numeric_value(time) # https://stackoverflow.com/a/30604935/2884386
    time                                            # 2000-01-01 00:00:00 +0000
      .utc                                          # 2000-01-01 00:00:00 UTC
      .to_f                                         # 946684800.0
      .*(1000)                                      # 946684800000.0
      .round                                        # 946684800000
  end

  def segment_array_to_numeric_value(segments)
    segments                                        # ["a", 12, "b", 34, "c"]
      .map { |x| x.is_a?(Numeric) ? x : x.ord }     # [97, 12, 98, 34, 99]
      .map { |n| (n + 1).to_s.rjust(3, '0') }       # ["098", "013", "099", "035", "100"]
      .insert(1, '.')                               # ["098", ".", "013", "099", "035", "100"]
      .join                                         # "098.013099035100"
      .to_r                                         # (980130990351/10000000000)
  end

  def normalize(string) # https://github.com/grosser/sort_alphabetical
    string                                          # "Äaáäßs"
      .unicode_normalize(:nfd)                      # "Äaáäßs"
      .downcase(:fold)                              # "äaáässs"
      .chars                                        # ["a", "̈", "a", "a", "́", "a", "̈", "s", "s", "s"]
      .select { |c| c =~ /[[:ascii:]]/ }            # ["a", "a", "a", "a", "s", "s", "s"]
      .join                                         # "aaaasss"
  end

  def segment(string) # https://stackoverflow.com/a/15170063/2884386
    string                                          # "a12b34c"
      .scan(/\d+|\D/)                               # ["a", "12", "b", "34", "c"]
      .map { |a| a =~ /\d+/ ? a.to_i : a }          # ["a", 12, "b", 34, "c"]
  end
end

# - - -

class TestIntegerSorter < Test::Unit::TestCase
  def setup
    integer_array = (0..9).to_a

    @random_integer_array = integer_array.shuffle
  end

  def test_sort_integers_in_ascending_order
    assert_equal(
      Sorter.new(direction: :ascending).sort(@random_integer_array),
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    )
  end

  def test_sort_integers_in_descending_order
    assert_equal(
      Sorter.new(direction: :descending).sort(@random_integer_array),
      [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    )
  end
end

class TestIntegerWithNilsSorter < Test::Unit::TestCase
  def setup
    integer_array = (0..9).to_a
    nil_array = [nil]

    @random_integer_array_with_nil = (
      integer_array +
      nil_array
    ).shuffle
  end

  def test_sort_integers_in_ascending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :ascending, nils: :small).sort(@random_integer_array_with_nil),
      [nil, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    )
  end

  def test_sort_integers_in_ascending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :ascending, nils: :large).sort(@random_integer_array_with_nil),
      [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, nil]
    )
  end

  def test_sort_integers_in_descending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :descending, nils: :small).sort(@random_integer_array_with_nil),
      [9, 8, 7, 6, 5, 4, 3, 2, 1, 0, nil]
    )
  end

  def test_sort_integers_in_descending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :descending, nils: :large).sort(@random_integer_array_with_nil),
      [nil, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0]
    )
  end
end

class TestBooleanSorter < Test::Unit::TestCase
  def setup
    boolean_array = [true, false]

    @random_boolean_array = boolean_array.shuffle
  end

  def test_sort_booleans_in_ascending_order
    assert_equal(
      Sorter.new(direction: :ascending).sort(@random_boolean_array),
      [false, true]
    )
  end

  def test_sort_booleans_in_descending_order
    assert_equal(
      Sorter.new(direction: :descending).sort(@random_boolean_array),
      [true, false]
    )
  end
end

class TestBooleanWithNilsSorter < Test::Unit::TestCase
  def setup
    boolean_array = [true, false]
    nil_array = [nil]

    @random_boolean_array_with_nil = (
      boolean_array +
      nil_array
    ).shuffle
  end

  def test_sort_booleans_in_ascending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :ascending, nils: :small).sort(@random_boolean_array_with_nil),
      [nil, false, true]
    )
  end

  def test_sort_booleans_in_ascending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :ascending, nils: :large).sort(@random_boolean_array_with_nil),
      [false, true, nil]
    )
  end

  def test_sort_booleans_in_descending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :descending, nils: :small).sort(@random_boolean_array_with_nil),
      [true, false, nil]
    )
  end

  def test_sort_booleans_in_descending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :descending, nils: :large).sort(@random_boolean_array_with_nil),
      [nil, true, false]
    )
  end
end

class TestTimeSorter < Test::Unit::TestCase
  def setup
    time_array = [
      Time.new(2000, 0o1, 0o1, 0o0, 0o0, 0o0, 0),
      Time.new(2000, 0o1, 0o1, 10, 10, 10, 0),
      Time.new(2010, 12, 0o1, 0o0, 0o0, 0o0, 0),
      Time.new(2010, 12, 0o1, 10, 10, 10, 0)
    ]

    @random_time_array = time_array.shuffle
  end

  def test_sort_times_in_ascending_order
    assert_equal(
      Sorter.new(direction: :ascending).sort(@random_time_array),
      [
        Time.new(2000, 0o1, 0o1, 0o0, 0o0, 0o0, 0),
        Time.new(2000, 0o1, 0o1, 10, 10, 10, 0),
        Time.new(2010, 12, 0o1, 0o0, 0o0, 0o0, 0),
        Time.new(2010, 12, 0o1, 10, 10, 10, 0)
      ]
    )
  end

  def test_sort_times_in_descending_order
    assert_equal(
      Sorter.new(direction: :descending).sort(@random_time_array),
      [
        Time.new(2010, 12, 0o1, 10, 10, 10, 0),
        Time.new(2010, 12, 0o1, 0o0, 0o0, 0o0, 0),
        Time.new(2000, 0o1, 0o1, 10, 10, 10, 0),
        Time.new(2000, 0o1, 0o1, 0o0, 0o0, 0o0, 0)
      ]
    )
  end
end

class TestTimeWithNilsSorter < Test::Unit::TestCase
  def setup
    time_array = [
      Time.new(2000, 0o1, 0o1, 0o0, 0o0, 0o0, 0),
      Time.new(2000, 0o1, 0o1, 10, 10, 10, 0),
      Time.new(2010, 12, 0o1, 0o0, 0o0, 0o0, 0),
      Time.new(2010, 12, 0o1, 10, 10, 10, 0)
    ]
    nil_array = [nil]

    @random_time_array_with_nil = (
      time_array +
      nil_array
    ).shuffle
  end

  def test_sort_times_in_ascending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :ascending, nils: :small).sort(@random_time_array_with_nil),
      [
        nil,
        Time.new(2000, 0o1, 0o1, 0o0, 0o0, 0o0, 0),
        Time.new(2000, 0o1, 0o1, 10, 10, 10, 0),
        Time.new(2010, 12, 0o1, 0o0, 0o0, 0o0, 0),
        Time.new(2010, 12, 0o1, 10, 10, 10, 0)
      ]
    )
  end

  def test_sort_times_in_ascending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :ascending, nils: :large).sort(@random_time_array_with_nil),
      [
        Time.new(2000, 0o1, 0o1, 0o0, 0o0, 0o0, 0),
        Time.new(2000, 0o1, 0o1, 10, 10, 10, 0),
        Time.new(2010, 12, 0o1, 0o0, 0o0, 0o0, 0),
        Time.new(2010, 12, 0o1, 10, 10, 10, 0),
        nil
      ]
    )
  end

  def test_sort_times_in_descending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :descending, nils: :small).sort(@random_time_array_with_nil),
      [
        Time.new(2010, 12, 0o1, 10, 10, 10, 0),
        Time.new(2010, 12, 0o1, 0o0, 0o0, 0o0, 0),
        Time.new(2000, 0o1, 0o1, 10, 10, 10, 0),
        Time.new(2000, 0o1, 0o1, 0o0, 0o0, 0o0, 0),
        nil
      ]
    )
  end

  def test_sort_times_in_descending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :descending, nils: :large).sort(@random_time_array_with_nil),
      [
        nil,
        Time.new(2010, 12, 0o1, 10, 10, 10, 0),
        Time.new(2010, 12, 0o1, 0o0, 0o0, 0o0, 0),
        Time.new(2000, 0o1, 0o1, 10, 10, 10, 0),
        Time.new(2000, 0o1, 0o1, 0o0, 0o0, 0o0, 0)
      ]
    )
  end
end

class TestDateSorter < Test::Unit::TestCase
  def setup
    date_array = [
      Date.new(2000, 0o1, 0o1),
      Date.new(2000, 12, 12),
      Date.new(2010, 12, 0o1),
      Date.new(2010, 12, 12)
    ]

    @random_date_array = date_array.shuffle
  end

  def test_sort_dates_in_ascending_order
    assert_equal(
      Sorter.new(direction: :ascending).sort(@random_date_array),
      [
        Date.new(2000, 0o1, 0o1),
        Date.new(2000, 12, 12),
        Date.new(2010, 12, 0o1),
        Date.new(2010, 12, 12)
      ]
    )
  end

  def test_sort_dates_in_descending_order
    assert_equal(
      Sorter.new(direction: :descending).sort(@random_date_array),
      [
        Date.new(2010, 12, 12),
        Date.new(2010, 12, 0o1),
        Date.new(2000, 12, 12),
        Date.new(2000, 0o1, 0o1)
      ]
    )
  end
end

class TestDateWithNilsSorter < Test::Unit::TestCase
  def setup
    date_array = [
      Date.new(2000, 0o1, 12),
      Date.new(2000, 0o1, 0o1),
      Date.new(2010, 12, 0o1),
      Date.new(2010, 12, 12)
    ]
    nil_array = [nil]

    @random_date_array_with_nil = (
      date_array +
      nil_array
    ).shuffle
  end

  def test_sort_dates_in_ascending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :ascending, nils: :small).sort(@random_date_array_with_nil),
      [
        nil,
        Date.new(2000, 0o1, 0o1),
        Date.new(2000, 0o1, 12),
        Date.new(2010, 12, 0o1),
        Date.new(2010, 12, 12)
      ]
    )
  end

  def test_sort_dates_in_ascending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :ascending, nils: :large).sort(@random_date_array_with_nil),
      [
        Date.new(2000, 0o1, 0o1),
        Date.new(2000, 0o1, 12),
        Date.new(2010, 12, 0o1),
        Date.new(2010, 12, 12),
        nil
      ]
    )
  end

  def test_sort_dates_in_descending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :descending, nils: :small).sort(@random_date_array_with_nil),
      [
        Date.new(2010, 12, 12),
        Date.new(2010, 12, 0o1),
        Date.new(2000, 0o1, 12),
        Date.new(2000, 0o1, 0o1),
        nil
      ]
    )
  end

  def test_sort_dates_in_descending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :descending, nils: :large).sort(@random_date_array_with_nil),
      [
        nil,
        Date.new(2010, 12, 12),
        Date.new(2010, 12, 0o1),
        Date.new(2000, 0o1, 12),
        Date.new(2000, 0o1, 0o1)
      ]
    )
  end
end

class TestStringSorter < Test::Unit::TestCase
  def setup
    string_array = %w[a z A Z]

    @random_string_array = string_array.shuffle
  end

  def test_sort_strings_in_ascending_order
    assert_equal(
      Sorter.new(direction: :ascending).sort(@random_string_array),
      %w[A Z a z]
    )
  end

  def test_sort_strings_in_descending_order
    assert_equal(
      Sorter.new(direction: :descending).sort(@random_string_array),
      %w[z a Z A]
    )
  end
end

class TestStringInsensitiveSorter < Test::Unit::TestCase
  def setup
    string_array = %w[a A z Z]

    @random_string_array = string_array
  end

  def test_sort_strings_case_insensitively_in_ascending_order
    assert_equal(
      Sorter.new(direction: :ascending, case_sensitive: false).sort(@random_string_array),
      %w[a A z Z]
    )
  end

  def test_sort_strings_case_insensitively_in_descending_order
    assert_equal(
      Sorter.new(direction: :descending, case_sensitive: false).sort(@random_string_array),
      %w[z Z a A]
    )
  end
end

class TestStringWithNilsSorter < Test::Unit::TestCase
  def setup
    string_array = %w[a z A Z]
    nil_array = [nil]

    @random_string_array_with_nil = (
      string_array +
      nil_array
    ).shuffle
  end

  def test_sort_strings_in_ascending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :ascending, nils: :small).sort(@random_string_array_with_nil),
      [nil, 'A', 'Z', 'a', 'z']
    )
  end

  def test_sort_strings_in_ascending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :ascending, nils: :large).sort(@random_string_array_with_nil),
      ['A', 'Z', 'a', 'z', nil]
    )
  end

  def test_sort_strings_in_descending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :descending, nils: :small).sort(@random_string_array_with_nil),
      ['z', 'a', 'Z', 'A', nil]
    )
  end

  def test_sort_strings_in_descending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :descending, nils: :large).sort(@random_string_array_with_nil),
      [nil, 'z', 'a', 'Z', 'A']
    )
  end
end

class TestStringInsensitiveWithNilsSorter < Test::Unit::TestCase
  def setup
    string_array = %w[a z A Z]
    nil_array = [nil]

    @random_string_array_with_nil = (
      string_array +
      nil_array
    )
  end

  def test_sort_strings_case_insensitively_in_ascending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :ascending, nils: :small, case_sensitive: false).sort(@random_string_array_with_nil),
      [nil, 'a', 'A', 'z', 'Z']
    )
  end

  def test_sort_strings_case_insensitively_in_ascending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :ascending, nils: :large, case_sensitive: false).sort(@random_string_array_with_nil),
      ['a', 'A', 'z', 'Z', nil]
    )
  end

  def test_sort_strings_case_insensitively_in_descending_order_with_nils_small
    assert_equal(
      Sorter.new(direction: :descending, nils: :small, case_sensitive: false).sort(@random_string_array_with_nil),
      ['z', 'Z', 'a', 'A', nil]
    )
  end

  def test_sort_strings_case_insensitively_in_descending_order_with_nils_large
    assert_equal(
      Sorter.new(direction: :descending, nils: :large, case_sensitive: false).sort(@random_string_array_with_nil),
      [nil, 'z', 'Z', 'a', 'A']
    )
  end
end

class TestSimpleObjectSorter < Test::Unit::TestCase
  def setup
    obj = Struct.new(:bool, :int)
    boolean_array = [true, false]
    integer_array = (1..2).to_a

    @array_of_tuples_to_array_of_objs_transformer = ->(array) { array.map { |bool, int| obj.new(bool, int) } }
    @random_object_array = @array_of_tuples_to_array_of_objs_transformer.call(
      boolean_array.product(integer_array).shuffle
    )
  end

  def test_sort_object_bool_then_int_in_ascending_then_ascending_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool },
                 { direction: :ascending, accessor: :int })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, 1], [false, 2], [true, 1], [true, 2]]
      )
    )
  end

  def test_sort_object_bool_then_int_in_ascending_then_descending_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool },
                 { direction: :descending, accessor: :int })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, 2], [false, 1], [true, 2], [true, 1]]
      )
    )
  end

  def test_sort_object_bool_then_int_in_descending_then_ascending_order
    assert_equal(
      Sorter.new({ direction: :descending, accessor: :bool },
                 { direction: :ascending, accessor: :int })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[true, 1], [true, 2], [false, 1], [false, 2]]
      )
    )
  end

  def test_sort_object_bool_then_int_in_descending_then_descending_order
    assert_equal(
      Sorter.new({ direction: :descending, accessor: :bool },
                 { direction: :descending, accessor: :int })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[true, 2], [true, 1], [false, 2], [false, 1]]
      )
    )
  end

  def test_sort_object_int_then_bool_in_ascending_then_ascending_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :int },
                 { direction: :ascending, accessor: :bool })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, 1], [true, 1], [false, 2], [true, 2]]
      )
    )
  end

  def test_sort_object_int_then_bool_in_ascending_then_descending_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :int },
                 { direction: :descending, accessor: :bool })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[true, 1], [false, 1], [true, 2], [false, 2]]
      )
    )
  end

  def test_sort_object_int_then_bool_in_descending_then_ascending_order
    assert_equal(
      Sorter.new({ direction: :descending, accessor: :int },
                 { direction: :ascending, accessor: :bool })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, 2], [true, 2], [false, 1], [true, 1]]
      )
    )
  end

  def test_sort_object_int_then_bool_in_descending_then_descending_order
    assert_equal(
      Sorter.new({ direction: :descending, accessor: :int },
                 { direction: :descending, accessor: :bool })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[true, 2], [false, 2], [true, 1], [false, 1]]
      )
    )
  end
end

class TestSimpleObjectWithNilsSorter < Test::Unit::TestCase
  def setup
    obj = Struct.new(:bool, :int)
    boolean_array = [true, false]
    integer_array = (1..2).to_a
    nil_array = [nil]
    boolean_integer_tuple_array = boolean_array.product(integer_array)
    boolean_nil_tuple_array = boolean_array.product(nil_array)
    nil_integer_tuple_array = nil_array.product(integer_array)

    @array_of_tuples_to_array_of_objs_transformer = ->(array) { array.map { |bool, int| obj.new(bool, int) } }
    @random_object_array_with_nil = @array_of_tuples_to_array_of_objs_transformer.call(
      boolean_integer_tuple_array +
      boolean_nil_tuple_array +
      nil_integer_tuple_array
    ).shuffle
  end

  def test_sort_object_bool_then_int_in_ascending_with_nils_small_then_ascending_with_nils_small_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool, nils: :small },
                 { direction: :ascending, accessor: :int, nils: :small })
            .sort(@random_object_array_with_nil),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[nil, 1], [nil, 2], [false, nil], [false, 1], [false, 2], [true, nil], [true, 1], [true, 2]]
      )
    )
  end

  def test_sort_object_bool_then_int_in_ascending_with_nils_large_then_ascending_with_nils_small_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool, nils: :large },
                 { direction: :ascending, accessor: :int, nils: :small })
            .sort(@random_object_array_with_nil),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, nil], [false, 1], [false, 2], [true, nil], [true, 1], [true, 2], [nil, 1], [nil, 2]]
      )
    )
  end

  def test_sort_object_bool_then_int_in_ascending_with_nils_small_then_ascending_with_nils_large_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool, nils: :small },
                 { direction: :ascending, accessor: :int, nils: :large })
            .sort(@random_object_array_with_nil),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[nil, 1], [nil, 2], [false, 1], [false, 2], [false, nil], [true, 1], [true, 2], [true, nil]]
      )
    )
  end

  def test_sort_object_bool_then_int_in_ascending_with_nils_large_then_ascending_with_nils_large_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool, nils: :large },
                 { direction: :ascending, accessor: :int, nils: :large })
            .sort(@random_object_array_with_nil),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, 1], [false, 2], [false, nil], [true, 1], [true, 2], [true, nil], [nil, 1], [nil, 2]]
      )
    )
  end
end

class TestNestedObjectSorter < Test::Unit::TestCase
  def setup
    assoc = Struct.new(:int)
    obj = Struct.new(:bool, :assoc)
    boolean_array = [true, false]
    integer_array = (1..2).to_a

    @array_of_tuples_to_array_of_objs_transformer = ->(array) { array.map { |bool, int| obj.new(bool, assoc.new(int)) } }
    @random_object_array = @array_of_tuples_to_array_of_objs_transformer.call(
      boolean_array.product(integer_array).shuffle
    )
  end

  def test_sort_nested_object_bool_then_int_in_ascending_then_ascending_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool },
                 { direction: :ascending, accessor: 'assoc.int' })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, 1], [false, 2], [true, 1], [true, 2]]
      )
    )
  end

  def test_sort_nested_object_bool_then_int_in_ascending_then_descending_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool },
                 { direction: :descending, accessor: 'assoc.int' })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, 2], [false, 1], [true, 2], [true, 1]]
      )
    )
  end

  def test_sort_nested_object_bool_then_int_in_descending_then_ascending_order
    assert_equal(
      Sorter.new({ direction: :descending, accessor: :bool },
                 { direction: :ascending, accessor: 'assoc.int' })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[true, 1], [true, 2], [false, 1], [false, 2]]
      )
    )
  end

  def test_sort_nested_object_bool_then_int_in_descending_then_descending_order
    assert_equal(
      Sorter.new({ direction: :descending, accessor: :bool },
                 { direction: :descending, accessor: 'assoc.int' })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[true, 2], [true, 1], [false, 2], [false, 1]]
      )
    )
  end

  def test_sort_nested_object_int_then_bool_in_ascending_then_ascending_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: 'assoc.int' },
                 { direction: :ascending, accessor: :bool })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, 1], [true, 1], [false, 2], [true, 2]]
      )
    )
  end

  def test_sort_nested_object_int_then_bool_in_ascending_then_descending_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: 'assoc.int' },
                 { direction: :descending, accessor: :bool })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[true, 1], [false, 1], [true, 2], [false, 2]]
      )
    )
  end

  def test_sort_nested_object_int_then_bool_in_descending_then_ascending_order
    assert_equal(
      Sorter.new({ direction: :descending, accessor: 'assoc.int' },
                 { direction: :ascending, accessor: :bool })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, 2], [true, 2], [false, 1], [true, 1]]
      )
    )
  end

  def test_sort_nested_object_int_then_bool_in_descending_then_descending_order
    assert_equal(
      Sorter.new({ direction: :descending, accessor: 'assoc.int' },
                 { direction: :descending, accessor: :bool })
            .sort(@random_object_array),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[true, 2], [false, 2], [true, 1], [false, 1]]
      )
    )
  end
end

class TestNestedObjectWithNilsSorter < Test::Unit::TestCase
  def setup
    assoc = Struct.new(:int)
    obj = Struct.new(:bool, :assoc)
    boolean_array = [true, false]
    integer_array = (1..2).to_a
    nil_array = [nil]
    boolean_integer_tuple_array = boolean_array.product(integer_array)
    boolean_nil_tuple_array = boolean_array.product(nil_array)
    nil_integer_tuple_array = nil_array.product(integer_array)

    @array_of_tuples_to_array_of_objs_transformer = ->(array) { array.map { |bool, int| obj.new(bool, assoc.new(int)) } }
    @random_object_array_with_nil = @array_of_tuples_to_array_of_objs_transformer.call(
      boolean_integer_tuple_array +
      boolean_nil_tuple_array +
      nil_integer_tuple_array
    ).shuffle
  end

  def test_sort_nested_object_bool_then_int_in_ascending_with_nils_small_then_ascending_with_nils_small_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool, nils: :small },
                 { direction: :ascending, accessor: 'assoc.int', nils: :small })
            .sort(@random_object_array_with_nil),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[nil, 1], [nil, 2], [false, nil], [false, 1], [false, 2], [true, nil], [true, 1], [true, 2]]
      )
    )
  end

  def test_sort_nested_object_bool_then_int_in_ascending_with_nils_large_then_ascending_with_nils_small_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool, nils: :large },
                 { direction: :ascending, accessor: 'assoc.int', nils: :small })
            .sort(@random_object_array_with_nil),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, nil], [false, 1], [false, 2], [true, nil], [true, 1], [true, 2], [nil, 1], [nil, 2]]
      )
    )
  end

  def test_sort_nested_object_bool_then_int_in_ascending_with_nils_small_then_ascending_with_nils_large_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool, nils: :small },
                 { direction: :ascending, accessor: 'assoc.int', nils: :large })
            .sort(@random_object_array_with_nil),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[nil, 1], [nil, 2], [false, 1], [false, 2], [false, nil], [true, 1], [true, 2], [true, nil]]
      )
    )
  end

  def test_sort_nested_object_bool_then_int_in_ascending_with_nils_large_then_ascending_with_nils_large_order
    assert_equal(
      Sorter.new({ direction: :ascending, accessor: :bool, nils: :large },
                 { direction: :ascending, accessor: 'assoc.int', nils: :large })
            .sort(@random_object_array_with_nil),
      @array_of_tuples_to_array_of_objs_transformer.call(
        [[false, 1], [false, 2], [false, nil], [true, 1], [true, 2], [true, nil], [nil, 1], [nil, 2]]
      )
    )
  end
end

class TestUnicodeStringSorter < Test::Unit::TestCase
  def test_sort_unicode_unaccented_strings_in_ascending_order
    assert_equal(
      Sorter.new(direction: :ascending, normalized: true).sort(%w[b a á ä o ó x ö í i c]),
      %w[a á ä b c i í o ó ö x]
    )
  end

  def test_sort_unicode_unaccented_strings_in_descending_order
    assert_equal(
      Sorter.new(direction: :descending, normalized: true).sort(%w[b a á ä o ó x ö í i c]),
      %w[x ö ó o í i c b ä á a]
    )
  end

  def test_sort_unicode_mixed_strings_in_ascending_order
    assert_equal(
      Sorter.new(direction: :ascending, normalized: true).sort(%w[AA AB ÄA]),
      %w[AA ÄA AB]
    )
  end

  def test_sort_unicode_mixed_strings_in_descending_order
    assert_equal(
      Sorter.new(direction: :descending, normalized: true).sort(%w[AA AB ÄA]),
      %w[AB ÄA AA]
    )
  end

  def test_sort_unicode_word_strings_in_ascending_order
    assert_equal(
      Sorter.new(direction: :ascending, normalized: true).sort(%w[hellö hello hellá]),
      %w[hellá hello hellö]
    )
  end

  def test_sort_unicode_word_strings_in_descending_order
    assert_equal(
      Sorter.new(direction: :descending, normalized: true).sort(%w[hellö hello hellá]),
      %w[hellö hello hellá]
    )
  end

  def test_sort_unicode_ligatures_strings_in_ascending_order
    assert_equal(
      Sorter.new(direction: :ascending, normalized: true).sort(%w[assb aßc assd]),
      %w[assb aßc assd]
    )
  end

  def test_sort_unicode_ligatures_strings_in_descending_order
    assert_equal(
      Sorter.new(direction: :descending, normalized: true).sort(%w[assb aßc assd]),
      %w[assd aßc assb]
    )
  end
end

class TestNaturalStringSorter < Test::Unit::TestCase
  def test_sort_basic_strings_in_ascending_order_naturally
    assert_equal(
      Sorter.new(direction: :ascending, natural: true).sort(%w[a10 a a20 a1b a1a a2 a0 a1]),
      %w[a a0 a1 a1a a1b a2 a10 a20]
    )
  end

  def test_sort_basic_strings_in_descending_order_naturally
    assert_equal(
      Sorter.new(direction: :descending, natural: true).sort(%w[a10 a a20 a1b a1a a2 a0 a1]),
      %w[a20 a10 a2 a1b a1a a1 a0 a]
    )
  end

  def test_sort_multiple_alphanum_segment_strings_in_ascending_order_naturally
    assert_equal(
      Sorter.new(direction: :ascending, natural: true).sort(%w[x2-g8 x8-y8 x2-y7 x2-y08]),
      %w[x2-g8 x2-y7 x2-y08 x8-y8]
    )
  end

  def test_sort_multiple_alphanum_segment_strings_in_descending_order_naturally
    assert_equal(
      Sorter.new(direction: :descending, natural: true).sort(%w[x2-g8 x8-y8 x2-y7 x2-y08]),
      %w[x8-y8 x2-y08 x2-y7 x2-g8]
    )
  end

  def test_sort_multiple_numeric_segment_strings_in_ascending_order_naturally
    assert_equal(
      Sorter.new(direction: :ascending, natural: true).sort(%w[1.2.3.2 1.2.3.10 1.2.3.1]),
      %w[1.2.3.1 1.2.3.2 1.2.3.10]
    )
  end

  def test_sort_multiple_numeric_segment_strings_in_descending_order_naturally
    assert_equal(
      Sorter.new(direction: :descending, natural: true).sort(%w[1.2.3.2 1.2.3.10 1.2.3.1]),
      %w[1.2.3.10 1.2.3.2 1.2.3.1]
    )
  end

  def test_sort_mixed_segment_strings_in_ascending_order_naturally
    assert_equal(
      Sorter.new(direction: :ascending, natural: true).sort(%w[a 10 a10 10a a10a a10.a a10.A 10.20a 10.20]),
      %w[10 10.20 10.20a 10a a a10 a10.A a10.a a10a]
    )
  end

  def test_sort_mixed_segment_strings_in_descending_order_naturally
    assert_equal(
      Sorter.new(direction: :descending, natural: true).sort(%w[a 10 a10 10a a10a a10.a a10.A 10.20a 10.20]),
      %w[a10a a10.a a10.A a10 a 10a 10.20a 10.20 10]
    )
  end
end

Test::Unit::AutoRunner.run
