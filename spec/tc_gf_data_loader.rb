require 'test/unit'
require 'tmpdir'
require 'app/gf_data_loader'

class TcGfDataLoader < Test::Unit::TestCase
  def setup
    @my_struct = Struct.new(:a,:b,:c,:d,:e) {
      def self.integer_fields
        [:a,:b]
      end
    }
    @tmp_file = File.join(Dir.tmpdir, 'temp.csv')
    File.open(@tmp_file, 'w') { |output|
      output.puts 'a,b,c,d'
      output.puts '1,2,3,4'
      output.puts '5,6,7,8'
    }
  end

  def teardown

  end

  def test_load_from_file
    objects = GfDataLoader.load_from_file(@tmp_file, @my_struct)
    assert_equal(2, objects.size, 'number of objects')
    assert_equal([1,2,'3','4',nil], objects.first.values, 'object 1 values')
  end

  def get_dummy_ratings
    rating_1 = GfRating.new
    rating_1.film_id = 10
    rating_1.user_id = 1

    rating_2 = GfRating.new
    rating_2.film_id = 10
    rating_2.user_id = 2

    [rating_1, rating_2]
  end

  def get_dummy_films
    film_1 = GfFilm.new
    film_1.film_id = 5

    film_2 = GfFilm.new
    film_2.film_id = 10

    [film_1,film_2]
  end

  def get_dummy_users
    user_1 = GfUser.new
    user_1.user_id = 1

    user_2 = GfUser.new
    user_2.user_id = 2
    [user_1,user_2]
  end

  def test_populate_film_add_ons
    ratings = get_dummy_ratings()
    films   = get_dummy_films()

    GfDataLoader.populate_film_add_ons(films,ratings)
    assert_equal([],     films.first.ratings, 'no ratings')
    assert_equal(ratings,films.last.ratings,  'ratings')
  end

  def test_populate_user_add_ons
    users   = get_dummy_users()
    ratings = get_dummy_ratings()
    GfDataLoader.populate_user_add_ons(users, ratings)

    assert_equal([ratings.first], users.first.ratings, 'rating')
    assert_equal([ratings.last],  users.last.ratings, 'rating')
  end

  def test_populate_rating_add_ons
    users   = get_dummy_users()
    ratings = get_dummy_ratings()
    films   = get_dummy_films()

    GfDataLoader.populate_rating_add_ons(ratings, films, users)

    assert_equal(films.last, ratings.first.film, 'film')
    assert_equal(films.last, ratings.last.film,  'film')

    assert_equal(users.first, ratings.first.user, 'user')
    assert_equal(users.last , ratings.last.user,  'user')
  end
end