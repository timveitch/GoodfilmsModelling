require 'test/unit'
require 'app/gf_data_structures'

class TcGfDataStructures < Test::Unit::TestCase
  def setup

  end

  def teardown

  end

  def test_user_ratings
    rating1 = GfRating.new
    rating1.quality_rating        = 80
    rating1.rewatchability_rating = 90

    rating2 = GfRating.new
    rating2.quality_rating        = 50
    rating2.rewatchability_rating = 20

    user = GfUser.new
    user.ratings = [rating1,rating2]

    assert_equal(65, user.mean_quality_rating, 'mean quality rating')
    assert_equal(55, user.mean_rewatch_rating, 'mean rewatch rating')

    user.delete_ratings_if { |rating|
      rating.quality_rating == 50
    }

    assert_equal(80, user.mean_quality_rating, 'mean quality rating')
    assert_equal(90, user.mean_rewatch_rating, 'mean rewatch rating')

  end
end