class Array
  def sum
    self.inject(0.0) { |sum,element| sum + element }
  end

  def mean
    return nil if self.size == 0
    sum / self.size
  end
end