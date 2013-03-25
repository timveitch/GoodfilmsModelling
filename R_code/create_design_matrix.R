## create tim's design matrix: rating ~ dummy(f1...fn) + (r1...rm) + ... + 

create_design_matrix <- function(m_film_names,n_pred_films=10,n_records='all'){
  load(paste(getwd(),'/r_data/ratings_summary.RData',sep=""))
  
  n_frame <- ratings_summary[1:n_pred_films,] # picks top rated films to predict.
  
  # # code to draw a random sample of n_pred_films films from the top 1000 rated films:
  # n_frame <- ratings_summary[1:1000,] # assumes that ratings_summary is ordered by N.
  # sample n_pred_films of the top rated films to predict:
  # set.seed(12345)
  # sample_ind <- sample(1:nrow(n_frame),size=n_pred_films)
  # n_frame <- n_frame[sample_ind,]
  
  m_films <- m_film_names
  
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
  # merged_ratings <- merge(n_ratings, m_ratings, by = 'user_id')
  
  # what are each user's divisive film ratings, if available? Must be a nicer way to do this...
  user_ratings <- function(i){
    r_vec <- rep(-1,length=length(m_films)*2)
    for (j in 1:length(m_films)){
      # pull out each user's divisive film ratings, stick into columns
      this_qual <- m_ratings[m_ratings$user_id==users[i] & m_ratings$film_id==m_films_ind[j],'quality_rating']
      this_rewa <- m_ratings[m_ratings$user_id==users[i] & m_ratings$film_id==m_films_ind[j],'rewatchability_rating']
      if(any(m_ratings$user_id==users[i] & m_ratings$film_id==m_films_ind[j])) r_vec[j] <- this_qual
      if(any(m_ratings$user_id==users[i] & m_ratings$film_id==m_films_ind[j])) r_vec[j + length(m_films)] <- this_rewa
    }
    this_row <- c(users[i],r_vec)
    return(this_row)
  }
  
  users <- unique(n_ratings$user_id)
  
  ifelse(n_records=='all',{n_use <- length(users)},{n_use <- n_records})
  
  divisive_mat <- sapply(1:n_use,user_ratings)
  divisive_mat <- t(divisive_mat)
  
  # create some named labels for divisive_mat columns:
  name_vec <- '0'
  for (i in 1:length(m_films)){
    name_vec[i] <- paste('qual_',i,sep="")
    name_vec[i + length(m_films)] <- paste('rewa_',i,sep="")
  }
  
  names(divisive_mat) <- c('user_id',name_vec)
  
  # stick these divisive film ratings back into n_matrix, based on user id:
  merged_ratings <- merge(n_ratings,divisive_mat,by = 'user_id')
  
  #-------------
  # create design matrix...
  
  # create design matrix of ~ dummy(f1... fn):
  n_matrix <- model.matrix(~ 0 + factor(merged_ratings$film_id))
  
  text_eval <- paste('m_matrix <- subset(merged_ratings, select = qual_1:rewa_',length(m_films),')',sep="")
  eval(parse(text=text_eval))
  
  X <- cbind(n_matrix, m_matrix)
  
  #---------------
  # use this to predict quality:
  
  y <- merged_ratings$quality_rating
  
  #---------------
  # output a list:
  out <- list(X = X, y_qual = merged_ratings$quality_rating, y_rewa = merged_ratings$rewatchability_rating)
  return(out)
}