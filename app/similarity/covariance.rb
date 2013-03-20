require 'app/ruby_extensions/array'

class Covariance

  attr_reader :covariance, :covariance_z_score, :sample_size

  def initialize(covariance,covariance_z_score,sample_size)
    @covariance         = covariance
    @covariance_z_score = covariance_z_score
    @sample_size        = sample_size
  end

  def self.create_from_data(xs,ys)
    raise('xs and ys are not of equal size!') if xs.size != ys.size
    mean_x = xs.mean
    mean_y = ys.mean

    products  = xs.zip(ys).map { |x,y| (x - mean_x) * (y - mean_y) }
    create_from_products(products)
  end

  def self.create_from_products(products)
    covariance = products.mean

    variance_of_products_x = products.map { |product_x| (product_x - covariance)**2 }.sum / (products.size - 1)
    covariance_z_score = covariance / Math.sqrt(variance_of_products_x / products.size)

    Covariance.new(covariance, covariance_z_score, products.size)
  end
end