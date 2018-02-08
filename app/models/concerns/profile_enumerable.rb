module ProfileEnumerable
  module ClassMethods

  end

  module InstanceMethods
    def enumerable_item
      @enumerable_item
    end

    def set_enumerable_item(item)
      @enumerable_item = item
    end

    def method_missing(method_id, *args, &block)
      enumerable_item.send(method_id, *args, &block)
    end

    def respond_to?(method_id, include_private = false)
      enumerable_item.respond_to?(method_id, include_private)
    end
  end
    
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end