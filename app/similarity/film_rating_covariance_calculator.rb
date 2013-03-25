require File.dirname(__FILE__) + '/covariance'

class FilmRatingCovarianceCalculator
  def self.get_quality_covariance(film_a_ratings, film_b_ratings)
    xs,ys = [film_a_ratings, film_b_ratings].map { |ratings|
      ratings.map { |film_rating| film_rating.quality_rating }
    }
    return Covariance.create_from_data(xs,ys)
  end

  def self.get_rewatch_covariance(film_a_ratings, film_b_ratings)
    xs,ys = [film_a_ratings, film_b_ratings].map { |ratings|
      ratings.map { |film_rating| film_rating.rewatchability_rating }
    }
    return Covariance.create_from_data(xs,ys)
  end

  def self.get_within_user_quality_covariance(film_a_ratings, film_b_ratings)
    products = film_a_ratings.zip(film_b_ratings).map { |film_a_rating,film_b_rating|
      mean_user_rating = film_a_rating.user.mean_quality_rating
      (film_a_rating.quality_rating - mean_user_rating) *
      (film_b_rating.quality_rating - mean_user_rating)
    }
    return Covariance.create_from_products(products)
  end

  def self.get_within_user_rewatch_covariance(film_a_ratings, film_b_ratings)
    products = film_a_ratings.zip(film_b_ratings).map { |film_a_rating,film_b_rating|
      mean_user_rating = film_a_rating.user.mean_rewatch_rating
      (film_a_rating.rewatchability_rating - mean_user_rating) *
      (film_b_rating.rewatchability_rating - mean_user_rating)
    }
    return Covariance.create_from_products(products)
  end

end