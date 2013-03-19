class GfDataSet
  attr_reader :films, :friendships, :ratings, :users
  def initialize(films,friendships,ratings,users)
    @films        = films
    @friendships  = friendships
    @ratings      = ratings
    @users        = users
  end

  def keep_only_n_top_rated_films(n)
    # sort in descending order of number of ratings
    films_ordered_by_num_ratings = @films.sort { |film_a,film_b| film_b.ratings.size <=> film_a.ratings.size }
    cut_off = films_ordered_by_num_ratings[n-1].ratings.size

    @films.delete_if { |film| film.ratings.size < cut_off }
    @ratings.delete_if { |rating| rating.film.ratings.size < cut_off }
    @users.each { |user|
      user.ratings.delete_if { |rating| rating.film.ratings.size < cut_off }
    }
  end

  def get_film_with_id(id)
    @films_by_id ||= {}
    return @films_by_id[id] unless @films_by_id.empty?

    @films.each { |film| @films_by_id[film.film_id] = film }
    return @films_by_id[id]
  end
end