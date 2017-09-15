# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :foos, force: true do |t|
    t.binary      :binary
    t.boolean     :boolean
    t.date        :date
    t.datetime    :datetime
    t.decimal     :decimal
    t.float       :float
    t.integer     :integer
    t.string      :string
    t.text        :text

    t.references  :assoc,    null: false
    t.timestamps             null: false
  end

  create_table :assocs, force: true do |t|
    t.binary      :binary
    t.boolean     :boolean
    t.date        :date
    t.datetime    :datetime
    t.decimal     :decimal
    t.float       :float
    t.integer     :integer
    t.string      :string
    t.text        :text

    t.timestamps null: false
  end
end
