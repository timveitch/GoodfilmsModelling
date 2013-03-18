require 'app/gf_data_catalogue'

def create_struct_from_file_header(file,extra_fields = [])
  fields = nil
  File.open(file, 'r') { |input|
    fields = input.readline.strip.split(',').map(&:to_sym)
  }
  Struct.new(*(fields+extra_fields))
end

GfFilm        = create_struct_from_file_header(FILMS_DATA_FILE,[:ratings]) {
  def self.integer_fields
    return %w{film_id year total_interactinos total_enqueues total_ratings rt_critics_score
              rt_audience_score runtime}.map(&:to_sym)
  end
}

GfFriendship  = create_struct_from_file_header(FRIENDSHIPS_DATA_FILE) {
  def self.integer_fields
    return %w{follower_id followee_id}.map(&:to_sym)
  end
}

GfRating      = create_struct_from_file_header(RATINGS_DATA_FILE, [:user,:film]) {
  def self.integer_fields
    return %w{user_id	film_id	quality_rating	rewatchability_rating	enqueued_before_rating}.map(&:to_sym)
  end
}

GfUser        = create_struct_from_file_header(USERS_DATA_FILE,[:ratings]) {
  def self.integer_fields
    return %w{user_id total_interactions total_enqueues total_ratings}.map(&:to_sym)
  end
}
