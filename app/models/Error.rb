class Error
  class << self
    def all
      [
        {
          id: :model_error,
        },
        {
          id: :params_error,
        }
      ]
    end

    def find(error_id)
      all.find do |err|
        err[:id] == error_id
      end
    end
  end

end
