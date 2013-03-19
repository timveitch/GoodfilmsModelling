require 'test/unit'
require 'tmpdir'
require 'app/gf_data_structures'
require 'app/gf_data_set'
require 'app/divisiveness/divisive_films_validator'

class TcDivisiveFilmsValidator < Test::Unit::TestCase
  def setup


  end

  def teardown

  end

  def test_get_data_set
    film1 = GfFilm.new
    film1.film_id = 1

    film2 = GfFilm.new
    film2.film_id = 2

    user = GfUser.new

    rating1 = GfRating.new
    rating1.film = film1
    rating1.quality_rating        = 80
    rating1.rewatchability_rating = 70
    rating1.user = user

    rating2 = GfRating.new
    rating2.film = film2
    rating2.quality_rating        = 30
    rating2.rewatchability_rating = 40
    rating2.user = user

    user.ratings = [rating1, rating2]

    data_set = GfDataSet.new([film1,film2], [], [rating1,rating2], [user])
    output = DivisiveFilmsValidator.get_data_set(data_set, [film1])

    assert_equal(1, output.size, '1 record')
    record = output.first

    assert_equal(1,  record[:b_is_film_2], 'is film 2')
    assert_equal(30, record[:a_quality_rating], 'quality rating')
    assert_equal(40, record[:a_rewatch_rating], 'rewatch rating')

    assert_equal(80, record[:c_quality_1], 'quality of film 1')
    assert_equal(70, record[:c_rewatch_1], 'rewatch of film 1')
  end

end