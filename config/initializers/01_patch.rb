# http://goo.gl/iFYoJL

class Hash
  def dig(*path)
    if path.count == 1 && path.first.is_a?(String)
      path = path.first.split('.')
    end

    path.inject(self) do |hash, key|
      hash.is_a?(Hash) ? hash[key] : nil
    end
  end
end