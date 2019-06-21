# frozen_string_literal: true

require 'active_support/core_ext/hash/reverse_merge'
require 'helpers/flatten_keys_of'
require 'active_set/attribute_instruction'
require 'active_set/filtering/operation'
require 'active_set/sorting/operation'
require 'active_set/paginating/operation'
require 'active_set/exporting/operation'

class ActiveSet
  include Enumerable

  class Configuration
    attr_accessor :on_asc_sort_nils_come

    def initialize
      @on_asc_sort_nils_come = :last
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.reset_configuration
    @configuration = Configuration.new
  end

  attr_reader :configuration, :set, :view, :instructions

  def initialize(set, view: nil, instructions: {}, configuration: {})
    @set = set
    @view = view || set
    @instructions = instructions
    @configuration = configuration
  end

  def each(&block)
    @view.each(&block)
  end

  # :nocov:
  def inspect
    "#<ActiveSet:#{object_id} @instructions=#{@instructions.inspect}>"
  end

  def ==(other)
    return @view == other unless other.is_a?(ActiveSet)

    @view == other.view
  end

  def method_missing(method_name, *args, &block)
    return @view.send(method_name, *args, &block) if @view.respond_to?(method_name)

    super
  end

  def respond_to_missing?(method_name, include_private = false)
    @view.respond_to?(method_name) || super
  end
  # :nocov:

  def filter(instructions_hash)
    filterer = Filtering::Operation.new(@view, instructions_hash)
    reinitialize(filterer.execute, :filter, filterer.operation_instructions)
  end

  def sort(instructions_hash)
    sorter = Sorting::Operation.new(@view, instructions_hash)
    reinitialize(sorter.execute, :sort, sorter.operation_instructions)
  end

  def paginate(instructions_hash)
    paginater = Paginating::Operation.new(@view, instructions_hash)
    reinitialize(paginater.execute, :paginate, paginater.operation_instructions)
  end

  def export(instructions_hash)
    exporter = Exporting::Operation.new(@view, instructions_hash)
    exporter.execute
  end

  private

  def reinitialize(processed_set, method, instructions)
    self.class.new(@set,
                   view: processed_set,
                   instructions: @instructions.merge(
                     method => instructions
                   ))
  end
end
