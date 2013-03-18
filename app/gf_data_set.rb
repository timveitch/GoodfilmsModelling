class GfDataSet
  attr_reader :films, :friendships, :ratings, :users
  def initialize(films,friendships,ratings,users)
    @films        = films
    @friendships  = friendships
    @ratings      = ratings
    @users        = users
  end
end