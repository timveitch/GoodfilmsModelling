## Cluster most rated films using archetypes.
# TSAW

rm(list=ls())

library(archetypes)

load(paste(getwd(),'/r_data/ratings_summary.RData',sep=""))

n_films <- 500
sub_dat <- ratings_summary[1:n_films,] # assumes that ratings_summary is ordered by N.

#-------------------
# perform archetype analysis on top n rated films with k archetypes.

dat <- subset(sub_dat,select=c('av_quality','av_rewatch'))
dat <- as.matrix(dat)

a <- archetypes(dat, k = 4)
xyplot(a, dat, chull = chull(dat))
xyplot(a, dat, adata.show = TRUE)

coeffs <- coef(a) # the loading of each data point on each archetype.

#-------------------
# Hrm. this doesn't work in the way I thought. Doesn't necessarily find actual data points... could be used to re-express the 2D data into 4D... not sure if this helps...