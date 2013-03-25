## exploratory plots of data set.
# TSAW

rm(list=ls())

library(ggplot2)

load(paste(getwd(),'/r_data/ratings_summary.RData',sep=""))

#---------------------------
# plot average ratings of n most rated films.

n_films <- 500

dat <- ratings_summary[1:n_films,] # assumes that ratings_summary is ordered by N.

fig <- ggplot(dat,aes(x=av_quality,y=av_rewatch)) 
fig <- fig + geom_point() 
# fig <- fig + geom_text(aes(label=title))
fig <- fig + scale_x_continuous(limits=c(0,100)) + scale_y_continuous(limits=c(0,100))
fig

