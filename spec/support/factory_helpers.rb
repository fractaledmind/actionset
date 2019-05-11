# frozen_string_literal: true

module FactoryHelpers
  def guaranteed_unique_object_for(obj, options = {})
    factory_name = obj.class.name.underscore

    FactoryBot.create(factory_name,
                      **guaranteed_unique_attributes_for(obj),
                      **options)
  end

  def guaranteed_unique_attributes_for(obj)
    {}.tap do |h|
      h[:binary] = guaranteed_unique_string_for(obj.binary)
      h[:boolean] = !obj.boolean
      h[:date] = obj.date.next_day
      h[:datetime] = obj.datetime.next_day
      h[:decimal] = obj.decimal + 1
      h[:float] = obj.float + 1
      h[:integer] = obj.integer + 1
      h[:string] = guaranteed_unique_string_for(obj.string)
      h[:text] = obj.text.split.map {|w| guaranteed_unique_string_for(w) }.join(' ')
      h[:time] = obj.time.advance(hours: 1)
    end
  end

  def guaranteed_unique_string_for(string)
    string.codepoints.map(&:next).pack('U*')
  end
end
