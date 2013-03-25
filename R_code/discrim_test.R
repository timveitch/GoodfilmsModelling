## Validation script for prediction. Predict n film ratings from m "divisive" films.
#
# TSAW & TRV

# Random Forests predicting rating from dummy coded new films (n) and rating to m divisive films:

# rating ~ dummy(f1...fn) + (r1...rm) + ... + 
# each row of this data is a single person's rating for a single film.

rm(list=ls())

library(randomForest)
library(reshape2)
library(ggplot2)
library(plyr)


load(paste(getwd(),'/r_data/ratings_summary.RData',sep=""))

n_films <- 10
n_frame <- ratings_summary[1:n_films,] # picks top rated films to predict.

# # code to draw a random sample of n_films films from the top 1000 rated films:
# n_frame <- ratings_summary[1:1000,] # assumes that ratings_summary is ordered by N.
# sample n_films of the top rated films to predict:
# set.seed(12345)
# sample_ind <- sample(1:nrow(n_frame),size=n_films)
# n_frame <- n_frame[sample_ind,]

m_films <- c('Inception','Twilight','Fight Club','The Matrix','The Room') # names of the divisive films.

# find film ids for these:
m_films_ind <- 0
m_frame <- data.frame()
for (i in 1:length(m_films)){
  m_films_ind[i] <- ratings_summary$film_id[ratings_summary$title==m_films[i]]
  m_frame <- rbind(m_frame,ratings_summary[ratings_summary$title==m_films[i],])
}

# check that none of the m_films fall into the n_frame set; remove if they do.
for (i in 1:length(m_films)){
  n_frame <- n_frame[n_frame$film_id!=m_films_ind[i],]
}

#------------
# merge ratings data in for n_ and m_ frames so that we now have individual ratings for each person.

n_ratings <- merge(n_frame,ratings_data,by = 'film_id')
m_ratings <- merge(m_frame,ratings_data,by = 'film_id')

# now merge these together for each user, including NAs:
merged_ratings <- merge(n_ratings, m_ratings, by = 'user_id')

# create design matrix of ~ dummy(f1... fn):
n_matrix <- model.matrix(~ 0 + factor(pred_frame$film_id))

#-------------
# devisive film design matrix:
# There is undoubtedly a nicer vectorised way to do this.
m_array <- data.frame()
for (i in 1:length(m_films)){
  m_array <- rbind(m_array,ratings_summary[ratings_summary$film_id==m_films_ind[i],])
  # not sure why these weren't working in vector form - only returning two matches??
}

m_vals <- model.matrix(~ 0 + m_array$quality + m_array$rewatch)
m_vals_rep <- rep(matrix(m_vals,nrow=1),times=nrow(n_matrix))
m_vals_mat <- matrix(m_vals_rep,nrow=nrow(n_matrix),ncol=length(m_films)*2,byrow=TRUE)

#---------------
# add m devisive film ratings to dummy codes for n_films:
X <- cbind(n_matrix,m_vals_mat)

#---------------
# use this to predict quality in random forest:

y <- pred_frame$quality_rating

rf <- randomForest(x=X, y=y, ntree=500, mtry=(ncol(X) - 5))

# predict y values:
y_hat <- rf$predicted

# plot y against predicted:
qplot(y,y_hat) + scale_x_continuous(limits=c(0,100)) + scale_y_continuous(limits=c(0,100))
