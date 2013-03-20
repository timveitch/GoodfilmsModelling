require 'test/unit'
require 'app/similarity/covariance'

class TcCovariance < Test::Unit::TestCase
  def setup

  end

  def teardown

  end

  def test_covariance
    xs = [1,2,3,4,5]
    ys = [5,4,3,2,1]

    covariance = Covariance.create_from_data(xs,ys)
    assert_equal(-2.0,        covariance.covariance,                  'covariance')
    assert_in_delta(-2.39046, covariance.covariance_z_score, 0.00001, 'covariance z score')
    assert_equal(5,           covariance.sample_size,                 'sample size')
  end
end