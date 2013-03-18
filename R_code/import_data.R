## import data file and sort.
# TSAW

rm(list=ls())

library(plyr)

#-------- 
# import ratings
ratings_data <- read.csv(file=paste(getwd(),'/raw_data/ratings.csv',sep=""),header=TRUE)

rating_summary <- ddply(ratings_data,.(film_id),summarise,N=length(rewatchability_rating))

# save binaries:
save(ratings_data,file=paste(getwd(),'/r_data/ratings.RData',sep=""))

#-------
# import films
films_data <- read.csv(file=paste(getwd(),'/raw_data/films.csv',sep=""),header=TRUE)

#-------
# import users
users_data <- read.csv(file=paste(getwd(),'/raw_data/users.csv',sep=""),header=TRUE)

#-------
# import friendships
friendships_data <- read.csv(file=paste(getwd(),'/raw_data/friendships.csv',sep=""),header=TRUE)



