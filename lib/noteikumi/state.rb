class Noteikumi
  class State
    attr_reader :items, :results, :processed_by, :engine
    attr_writer :mutable

    def initialize(engine, logger)
      @items = {}
      @results = []
      @processed_by = []
      @engine = engine
      @logger = logger
      @results = []
      @mutable = true
    end

    def each_result
      @results.each do |result|
        yield(result)
      end
    end

    def add_result(result)
      @results << result
    end

    def had_failures?
      @results.map {|r| r.error?}.include?(true)
    end

    def items_by_type(type)
      @items.find {|i, v| v.is_a?(type)} || []
    end

    def has_item_of_type?(type)
      !items_by_type(type).empty?
    end

    def mutable?
      !!@mutable
    end

    def record_rule(rule)
      @processed_by << rule
    end

    def include?(item)
      @items.include?(item)
    end
    alias_method :has?, :include?

    # sets the value of an item without checking if it's already set
    #
    # @param item [Symbol] the name of the item being stored
    # @param value [Object] the item to store
    # @return [Object] the item being stored
    # @raise [StandardError] when the state is not mutable
    def set(item, value)
      raise("State is not mustable") unless mutable?

      @items[item] = value
    end
    alias_method :[]=, :set

    def delete(item)
      raise("State is not mustable") unless mutable?

      @items.delete(item)
    end

    def add(item, value)
      raise("State is not mustable") unless mutable?
      raise("Already have item %s" % item) if has?(item)

      set(item, value)
    end

    def get(item)
      @items[item]
    end
    alias_method :[], :get
  end
end
