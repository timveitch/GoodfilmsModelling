require 'app/gf_data_catalogue'

def get_fields_from_header(file)
  fields = nil
  File.open(file, 'r') { |input|
    fields = input.readline.strip.split(',').map(&:to_sym)
  }
  fields
end

film_fields = get_fields_from_header(FILMS_DATA_FILE)
film_fields += [:ratings]

GfFilm        = Struct.new(*film_fields) {
  def self.integer_fields
    return %w{film_id year total_interactinos total_enqueues total_ratings rt_critics_score
              rt_audience_score runtime}.map(&:to_sym)
  end
}

friendship_fields = get_fields_from_header(FRIENDSHIPS_DATA_FILE)

GfFriendship  = Struct.new(*friendship_fields) {
  def self.integer_fields
    return %w{follower_id followee_id}.map(&:to_sym)
  end
}

rating_fields = get_fields_from_header(RATINGS_DATA_FILE)
rating_fields += [:user,:film]

GfRating      = Struct.new(*rating_fields) {
  def self.integer_fields
    return %w{user_id	film_id	quality_rating	rewatchability_rating	enqueued_before_rating}.map(&:to_sym)
  end
}

user_fields = get_fields_from_header(USERS_DATA_FILE)
user_fields += [:ratings]

GfUser        = Struct.new(*user_fields) {
  def self.integer_fields
    return %w{user_id total_interactions total_enqueues total_ratings}.map(&:to_sym)
  end
}
