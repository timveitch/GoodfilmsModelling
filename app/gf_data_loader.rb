require 'app/gf_data_structures'
require 'app/gf_data_catalogue'
require 'app/gf_data_set'

class GfDataLoader
  def self.load_all
    films       = load_from_file(FILMS_DATA_FILE,       GfFilm)
    friendships = load_from_file(FRIENDSHIPS_DATA_FILE, GfFriendship)
    ratings     = load_from_file(RATINGS_DATA_FILE,     GfRating)
    users       = load_from_file(USERS_DATA_FILE,       GfUser)

    populate_add_ons(films,users,ratings)
    GfDataSet.new(films,friendships,ratings,users)
  end

  def self.load_from_file(file, struct)
    puts "Loading #{struct.to_s}s"
    File.open(file, 'r') { |input|
      input.readline
      input.readlines.map { |line|
        object = struct.new(*line.strip.split(','))
        struct.integer_fields.each { |field|
          object[field] = object[field].to_i
        }
        object
      }
    }
  end

  def self.populate_film_add_ons(films,ratings)
    ratings_by_film_id = ratings.group_by { |rating| rating.film_id }
    films.each { |film| film.ratings = ratings_by_film_id.fetch(film.film_id, []) }
  end

  def self.populate_user_add_ons(users, ratings)
    ratings_by_user_id = ratings.group_by { |rating| rating.user_id }
    users.each { |user| user.ratings = ratings_by_user_id.fetch(user.user_id, []) }
  end

  def self.populate_rating_add_ons(ratings,films,users)
    films_by_id = films.group_by { |film| film.film_id }
    users_by_id = users.group_by { |user| user.user_id }

    ratings.each { |rating|
      rating.user = users_by_id.fetch(rating.user_id, []).first
      rating.film = films_by_id.fetch(rating.film_id, []).first
    }
  end

  def self.populate_add_ons(films,users,ratings)
    populate_film_add_ons(films, ratings)
    populate_user_add_ons(users, ratings)
    populate_rating_add_ons(ratings,films,users)
  end
end