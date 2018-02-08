module TrainHelper
  def train_final_params(hash)
    if hash['grade']
      hash.merge('grade' => hash['grade']&.map{|item|  item.to_i})
    else
      hash
    end
  end
end