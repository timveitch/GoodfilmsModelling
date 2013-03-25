

configure.random.forest = function(num_trees, m_try, sample_size, min_node_size, replace) {  
    return(function(x,y) {
      library(randomForest)
      return(randomForest( x         = x
                    ,y        = y
                    ,ntree    = num_trees
                    ,replace  = replace
                    ,nodesize = min_node_size
                    ,sampsize = sample_size
                    ,mtry     = m_try
      ))
    })
}

random.forest.predict = function(model,test_data) {
  return(predict(model,test_data))
}
