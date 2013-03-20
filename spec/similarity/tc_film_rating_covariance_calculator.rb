require 'test/unit'
require 'app/gf_data_structures'
require 'app/similarity/film_rating_covariance_calculator'

class TcFilmRatingCovarianceCalculator < Test::Unit::TestCase
  def setup

  end

  def teardown

  end

  def test_covariance
    film_a_ratings = (1..5).map { |index|
      rating = GfRating.new()
      rating.quality_rating        = index
      rating.rewatchability_rating = index * 2

      rating
    }

    film_b_ratings = (1..5).map { |index|
      rating = GfRating.new()
      rating.quality_rating        = 6  - index
      rating.rewatchability_rating = 12 - index * 2

      rating
    }

    quality_covariance = FilmRatingCovarianceCalculator.get_quality_covariance(film_a_ratings, film_b_ratings)
    rewatch_covariance = FilmRatingCovarianceCalculator.get_rewatch_covariance(film_a_ratings, film_b_ratings)

    assert_equal(-2, quality_covariance.covariance, 'quality_covariance')
    assert_equal(-8, rewatch_covariance.covariance, 'rewatch_covariance')

  end

  def get_within_user_covariance

  end
end