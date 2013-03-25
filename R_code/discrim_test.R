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

source('create_design_matrix.R')

#--------------
# Generate design matrix

m_films <- c('Inception','Twilight','Fight Club','The Matrix','Zoolander') # names of the divisive films.
n_pred_films <- 48
out <- create_design_matrix(m_films,n_pred_films,n_records = 1000)

#---------------
# use this to predict quality in random forest:
X <- out$X
y <- out$y_qual

rf <- randomForest(x=X, y=y, ntree=100, mtry=(ceiling(ncol(X)/3)), sampsize = ceiling(nrow(X)/3), nodesize = 2)

# predict y values:
y_hat <- rf$predicted

# plot y against predicted:
qplot(y,y_hat,alpha=.3) + scale_x_continuous(limits=c(0,100)) + scale_y_continuous(limits=c(0,100))

#----------------
# are we doing better than the mean? 

# calculate random forest mse:
print(mean((y - y_hat)^2))

