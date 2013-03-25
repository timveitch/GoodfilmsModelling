library(doSNOW)
library(snowfall) #for parallel processing

cross.validate = function(x,y,ready_model,prediction_function,num_folds,seed) {
  cluster <- makeCluster(num_folds, type = "SOCK")
  registerDoSNOW(cluster)
  
  getDoParWorkers()
  getDoParName()
  getDoParVersion()
  
  set.seed(seed)
  
  folds <- sample(rep(seq_len(num_folds), length.out=nrow(x)))
  
  predictions <- rep(0, nrow(x))
  
  fold_predictions <- foreach(fold = 1:num_folds) %dopar% {
    training_ids = which(folds!=fold)
    training_x   = x[training_ids,]
    training_y   = y[training_ids]
    
    test_x       = x[which(folds==fold),]
    
    model <- ready_model(training_x,training_y)
    return(prediction_function(model,test_x))
  }
  
  for (fold in 1:num_folds) {
    predictions[which(folds==fold)] = fold_predictions[[fold]]
  }
  
  stopCluster(cluster)
  return(predictions)
}
