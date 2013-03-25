require File.dirname(__FILE__) + '/../gf_data_loader'
require File.dirname(__FILE__) + '/../similarity/film_rating_covariance_calculator'

time1 = Time.new

gf_data_set = GfDataLoader.load_all

top_n = 200

gf_data_set.keep_only_n_top_rated_films(top_n)
rating_pairs = gf_data_set.get_rating_pairs
puts "have #{rating_pairs.size} rating pairs"

rating_pairs_by_film_pair = rating_pairs.group_by { |rating_a,rating_b|
  [rating_a.film.film_id, rating_b.film.film_id]
}

puts "have #{rating_pairs_by_film_pair.size} film pairs"

File.open("D:/Goodfilms/sandpit/covariance_outputs_top_#{top_n}.csv", 'w') { |output_file|
  fields = %w{film_a film_b
              quality_covariance quality_covariance_z_score
              rewatch_covariance rewatch_covariance_z_score
              within_user_quality_covariance within_user_quality_covariance_z_score
              within_user_rewatch_covariance within_user_rewatch_covariance_z_score}

  output_file.puts fields.join(',')

  rating_pairs_by_film_pair.each { |(film_id_a, film_id_b), rating_pairs|

    film_a_ratings, film_b_ratings = [rating_pairs.map(&:first), rating_pairs.map(&:last)]

    quality_covariance = FilmRatingCovarianceCalculator.get_quality_covariance(film_a_ratings, film_b_ratings)
    rewatch_covariance = FilmRatingCovarianceCalculator.get_rewatch_covariance(film_a_ratings, film_b_ratings)

    within_user_quality_covariance = FilmRatingCovarianceCalculator.get_within_user_quality_covariance(film_a_ratings, film_b_ratings)
    within_user_rewatch_covariance = FilmRatingCovarianceCalculator.get_within_user_rewatch_covariance(film_a_ratings, film_b_ratings)

    output =  [film_a_ratings.first.film.title, film_b_ratings.first.film.title]
    output += [quality_covariance.covariance, quality_covariance.covariance_z_score]
    output += [rewatch_covariance.covariance, rewatch_covariance.covariance_z_score]

    output += [within_user_quality_covariance.covariance, within_user_quality_covariance.covariance_z_score]
    output += [within_user_rewatch_covariance.covariance, within_user_rewatch_covariance.covariance_z_score]

    output_file.puts output.join(',')

    second_output = [output[1],output[0],*output[2..-1]]
    output_file.puts second_output.join(',')
  }
}

time2 = Time.new

puts "Took #{time2 - time1} seconds"