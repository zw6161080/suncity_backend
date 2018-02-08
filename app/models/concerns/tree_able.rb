module TreeAble
  module ClassMethods
    def to_tree
      hash_data = self.hash_tree
      self.hash_to_array_item(hash_data)
    end

    def hash_to_array_item(hash_data)
      hash_data.map do |key, value|
        obj = {
          id: key.id,
          children: []
        }

        if value.any?
          obj[:children] = self.hash_to_array_item(value)
        end
        obj
      end
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
  end
end
