## import data file and sort.
# TSAW

rm(list=ls())

library(plyr)

#-------- 
# import ratings
ratings_data <- read.csv(file=paste(getwd(),'/raw_data/ratings.csv',sep=""),header=TRUE)

ratings_summary <- ddply(ratings_data,.(film_id),summarise,N=length(rewatchability_rating),av_quality=mean(quality_rating),av_rewatch=mean(rewatchability_rating))

#-------
# import films
films_data <- read.csv(file=paste(getwd(),'/raw_data/films.csv',sep=""),header=TRUE)

# add film names to ratings summary frame:
temp <- subset(films_data,select=c('film_id','title'))
ratings_summary <- merge(ratings_summary,temp,by='film_id')

# order by most rated:
ratings_summary <- ratings_summary[order(-ratings_summary$N, -ratings_summary$av_quality, -ratings_summary$av_rewatch),]

#-------
# import users
users_data <- read.csv(file=paste(getwd(),'/raw_data/users.csv',sep=""),header=TRUE)

#-------
# import friendships
friendships_data <- read.csv(file=paste(getwd(),'/raw_data/friendships.csv',sep=""),header=TRUE)

#-------
# save binaries:
save(ratings_summary,ratings_data,file=paste(getwd(),'/r_data/ratings_summary.RData',sep=""))

