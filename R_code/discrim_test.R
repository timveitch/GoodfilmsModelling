## Validation script for prediction. Predict n film ratings from m "divisive" films.
#
# TSAW & TRV

# Random Forests predicting rating from dummy coded new films (n) and rating to m exemplar films:

# rating ~ dummy(f1...fn) + (r1...rm) + ... + 

rm(list=ls())

library(randomForest)
library(reshape2)
library(ggplot2)


load(paste(getwd(),'/r_data/ratings_summary.RData',sep=""))

n_films <- 500
sub_dat <- ratings_summary[1:n_films,] # assumes that ratings_summary is ordered by N.

m_films <- c('Inception','Twilight','Fight Club','The Matrix','The Room') # names of the divisive films.

#---------------
# create design matrix to specification: ~ dummy(f1...fn) + (r1...rm) + ... + 

# There is undoubtably a better vectorised way to do this.
m_films_ind <- 0
n_array <- sub_dat
m_array <- data.frame()
for (i in 1:length(m_films)){
  m_films_ind[i] <- ratings_summary$film_id[ratings_summary$title==m_films[i]]
  
  n_array <- n_array[n_array$film_id!=m_films_ind[i],]
  m_array <- rbind(m_array,sub_dat[sub_dat$film_id==m_films_ind[i],])
  # not sure why these weren't working in vector form - only returning two matches??
}

# m_vals <- model.matrix(~ 0 + m_array$quality + m_array$rewatch)
m_vals <- model.matrix(~ 0 + m_array$quality)

m_vals_rep <- rep(matrix(m_vals,nrow=1),times=nrow(n_array))
m_vals_mat <- matrix(m_vals_rep,nrow=nrow(n_array),ncol=length(m_films)*2,byrow=TRUE)

X <- model.matrix(~ 0 + factor(n_array$film_id))

# add m devisive film ratings to dummy codes for n_films:
X <- cbind(X,m_vals_mat)

#---------------
# use this to predict quality in random forest:

y <- n_array$quality

rf <- randomForest(x=X, y=y, ntree=500, mtry=495)

# predict y values:
y_hat <- rf$predicted

# plot y against predicted:
qplot(y,y_hat) + scale_x_continuous(limits=c(0,100)) + scale_y_continuous(limits=c(0,100))
