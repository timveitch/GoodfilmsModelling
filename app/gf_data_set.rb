class GfDataSet
  attr_reader :films, :friendships, :ratings, :users
  def initialize(films,friendships,ratings,users)
    @films        = films
    @friendships  = friendships
    @ratings      = ratings
    @users        = users
  end

  def keep_only_n_top_rated_films(n)
    puts "removing all but top #{n} rated films"
    # sort in descending order of number of ratings
    films_ordered_by_num_ratings = @films.sort { |film_a,film_b| film_b.ratings.size <=> film_a.ratings.size }
    cut_off = films_ordered_by_num_ratings[n-1].ratings.size

    @films.delete_if { |film| film.ratings.size < cut_off }
    @ratings.delete_if { |rating| rating.film.ratings.size < cut_off }
    @users.each { |user|
      user.delete_ratings_if { |rating| rating.film.ratings.size < cut_off }
    }
  end

  def get_film_with_id(id)
    @films_by_id ||= {}
    return @films_by_id[id] unless @films_by_id.empty?

    @films.each { |film| @films_by_id[film.film_id] = film }
    return @films_by_id[id]
  end

  def get_rating_pairs()
    puts 'Getting rating pairs'
    puts @users.map(&:class).uniq.inspect
    rating_pairs = @users.map { |user|
          # remove case where rating_a == rating_b, and also, only keep each pair of films once
      user.ratings.map { |rating_a|
        user.ratings.map { |rating_b|
          # (when film_id for a is less than b)
          next if rating_a.film.film_id >= rating_b.film.film_id
          [rating_a, rating_b]
        }.compact
      }
    }.flatten(2)

    rating_pairs
  end
end