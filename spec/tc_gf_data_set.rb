require 'test/unit'
require 'app/gf_data_set'
require 'app/gf_data_structures'

class TcGfDataSet < Test::Unit::TestCase
  def setup

  end

  def teardown

  end

  def test_keep_only_n_top_rated_films
    film1 = GfFilm.new
    film2 = GfFilm.new
    film3 = GfFilm.new
    film4 = GfFilm.new
    film1.ratings = [GfRating.new]
    film2.ratings = [GfRating.new,GfRating.new]
    film3.ratings = [GfRating.new,GfRating.new]
    film4.ratings = [GfRating.new,GfRating.new,GfRating.new]

    user    = GfUser.new
    users   = [user]
    ratings = []

    films = [film1,film2,film3,film4]
    films.each { |film|
      ratings += film.ratings
      film.ratings.each { |rating|
        rating.film = film
        rating.user = user
        (user.ratings ||= []) << rating
      }
    }

    gf_data_set = GfDataSet.new(films, [], ratings, users)
    assert_equal(films, gf_data_set.films, "films == films")

    assert_equal(4, gf_data_set.films.size,               'films before cull')
    assert_equal(8, gf_data_set.ratings.size,             'ratings before cull')
    assert_equal(8, gf_data_set.users.first.ratings.size, 'user ratings before cull')

    gf_data_set.keep_only_n_top_rated_films(2)

    assert_equal(3, gf_data_set.films.size,               'films after cull')
    assert_equal(7, gf_data_set.ratings.size,             'ratings after cull')
    assert_equal(7, gf_data_set.users.first.ratings.size, 'user ratings after cull')
  end
end