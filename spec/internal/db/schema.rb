# frozen_string_literal: true

ActiveRecord::Schema.define do
  create_table :things, force: true do |t|
    t.binary      :binary
    t.boolean     :boolean
    t.date        :date
    t.datetime    :datetime
    t.decimal     :decimal, precision: 8, scale: 2
    t.float       :float
    t.integer     :integer
    t.string      :string
    t.text        :text
    t.time        :time

    t.references  :only
    t.timestamps null: false
  end

  create_table :onlies, force: true do |t|
    t.binary      :binary
    t.boolean     :boolean
    t.date        :date
    t.datetime    :datetime
    t.decimal     :decimal, precision: 8, scale: 2
    t.float       :float
    t.integer     :integer
    t.string      :string
    t.text        :text
    t.time        :time

    t.timestamps null: false
  end

  create_table :alots, force: true do |t|
    t.binary      :binary
    t.boolean     :boolean
    t.date        :date
    t.datetime    :datetime
    t.decimal     :decimal, precision: 8, scale: 2
    t.float       :float
    t.integer     :integer
    t.string      :string
    t.text        :text
    t.time        :time

    t.references  :thing
    t.timestamps null: false
  end

  create_table :relateds, force: true do |t|
    t.binary      :binary
    t.boolean     :boolean
    t.date        :date
    t.datetime    :datetime
    t.decimal     :decimal, precision: 8, scale: 2
    t.float       :float
    t.integer     :integer
    t.string      :string
    t.text        :text
    t.time        :time

    t.timestamps null: false
  end

  create_table :joints, force: true do |t|
    t.binary      :binary
    t.boolean     :boolean
    t.date        :date
    t.datetime    :datetime
    t.decimal     :decimal, precision: 8, scale: 2
    t.float       :float
    t.integer     :integer
    t.string      :string
    t.text        :text
    t.time        :time

    t.references  :thing
    t.references  :related
    t.timestamps null: false
  end

  create_table :stis, force: true do |t|
    t.string      :type
    t.binary      :binary
    t.boolean     :boolean
    t.date        :date
    t.datetime    :datetime
    t.decimal     :decimal, precision: 8, scale: 2
    t.float       :float
    t.integer     :integer
    t.string      :string
    t.text        :text
    t.time        :time

    t.timestamps null: false
  end

  create_table :polies, force: true do |t|
    t.binary      :binary
    t.boolean     :boolean
    t.date        :date
    t.datetime    :datetime
    t.decimal     :decimal, precision: 8, scale: 2
    t.float       :float
    t.integer     :integer
    t.string      :string
    t.text        :text
    t.time        :time

    t.references :polyable, polymorphic: true, index: true

    t.timestamps null: false
  end
end
