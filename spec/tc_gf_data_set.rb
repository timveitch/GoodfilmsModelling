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

  def test_get_film_pairs
    user1 = GfUser.new
    user2 = GfUser.new

    film1 = GfFilm.new; film1.film_id = 1
    film2 = GfFilm.new; film2.film_id = 2
    film3 = GfFilm.new; film3.film_id = 3

    rating1 = GfRating.new; rating1.film = film1
    rating2 = GfRating.new; rating2.film = film2
    rating3 = GfRating.new; rating3.film = film3

    user1.ratings = [rating1,rating2,rating3]
    user2.ratings = [rating1,rating2]

    gf_data_set = GfDataSet.new([film1,film2,film3],[],[rating1,rating2,rating3],[user1,user2])

    pairs = gf_data_set.get_rating_pairs()
    assert_equal(4, pairs.size, 'number of pairs')
    assert_equal([2], pairs.map(&:size).uniq, 'all pairs')

    {[rating1,rating2] => 2,
     [rating2,rating3] => 1,
     [rating1,rating3] => 1}.each { |test_pair, count|
      assert_equal(count, pairs.select { |pair| pair == test_pair }.size, "number of times pair #{test_pair.inspect} appears")
    }
  end
end