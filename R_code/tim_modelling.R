# IO --------------------------------------------------------
base_dir   <- "D:\\Goodfilms\\sandpit\\"
processed_data_dir <- paste(base_dir, "Data", sep = "\\")
data_dir   <- data_dir #paste(base_dir, "Data", sep = "\\")
output_dir <- data_dir #paste(base_dir, "Models",    sep = "\\") 

training_file <- paste(data_dir, "training.csv", sep = "\\")
test_file     <- paste(data_dir, "testing.csv", sep = "\\")

set.seed(42424242)

training  <- read.csv(training_file)
#testing_x <- read.csv(test_file)

#predictor_scores <- read.csv(paste(processed_data_dir, "predictor_scores.csv", sep = "\\"))[,c("predictors","predictor_scores")]

#training <- cbind(training, training[,"D27"])
#testing  <- cbind(testing, testing[,"D27"])


# DATA SETUP
theTarget   <- 'Activity'
targetIndex <- which(names(training) == theTarget)

training_x <- training[,-targetIndex]
training_y <- training[,targetIndex]


#predictor_threshold <- 1776

#predictors <- paste("D",predictor_scores[1:predictor_threshold,"predictors"],sep = "")
#training_data <- training[,predictors]
#training_data <- cbind(training_data, training[,targetIndex])
#names(training_data)[length(names(training_data))] = "Activity"

#targetIndex <- which(names(training_data) == theTarget)
#testing_data  <- testing[,predictors]


#var_string = predictors[1]
#for (p in predictors[2:length(predictors)]) { var_string <- paste(var_string, p, sep = "+")}
#theFormula <- as.formula(paste(theTarget, var_string, sep = "~"))

# PRINCIPAL COMPONENTS TRANSFORMATION
#pca <- prcomp(training_x, scale = TRUE)

num_principal_components = 100
predictors <- paste("Z", 1:num_principal_components, sep = "")

training_x_norm <- as.data.frame(scale(training_x, pca$center, pca$scale))
testing_x_norm  <- as.data.frame(scale(testing_x, pca$center, pca$scale))

training_z        <- as.data.frame(as.matrix(training_x_norm) %*% pca$rotation[,1:num_principal_components])
names(training_z) <- predictors

training_data <- cbind(training_x, training_z, training_y)
names(training_data)[length(names(training_data))] = theTarget
targetIndex <- length(names(training_data))

testing_z <- as.data.frame(as.matrix(testing_x_norm) %*% pca$rotation[,1:num_principal_components])
names(testing_z) <- predictors
testing_data     <- cbind(testing_x, testing_z)

# SETTINGS --------------------------------------------------

numLoops <- 4
threads  <- 4
numFolds <- 4


# MODEL SETTINGS --------------------------------------------
models <- c('gbm')

upper_bound <- 0.99999999
lower_bound <- 0.00000001

LOGIT_TRANSFORM = FALSE

# GBM
GBM_TREE_BLOCK = 100
GBM_EXCESS_TREES = 300
GBM_SHRINKAGE       = 0.01
GBM_DEPTH           = 10
GBM_MINOBS          = 20
GBM_DISTRIBUTION    = "bernoulli"
GBM_BAGFRACTION     = 0.6
# RF
RF_TREES      <- 200
RF_NODESIZE   <- 2
RF_SAMPLESIZE <- 0.7 * nrow(training_data)
RF_MTRY       <- max(floor((ncol(training_data)-1)/10), 1)

# NEURAL NET
HIDDEN_NEURONS = 1
NNET_LINOUT <- FALSE


# LIBRARIES
library(foreach)
library(doSNOW)
library(snowfall) #for parallel processing
library(rlecuyer)
library(randomForest)
library(gbm)
library(earth)
library(glmnet)
library(nnet)
library(e1071)
library(neuralnet)

# PARALLELISATION
cluster <- makeCluster(threads, type = "SOCK")
registerDoSNOW(cluster)

getDoParWorkers()
getDoParName()
getDoParVersion()

# FUNCTIONS -------------------------------------------------
# LOSS FUNCTION
loss_function <- function (actuals, predictions) {
	sum(-actuals * log(predictions) - (1-actuals) * log(1 - predictions)) / length(actuals)
}

utilities <- function(probabilities) { 
	log(probabilities / (1.0 - probabilities))
}
probabilities <- function(utilities) { 
	1.0 / (1.0 + exp(-utilities))
}

# REPORTING
#names(training)
#names(testing)



# MODELLING -------------------------------------------------

buildcases <- nrow(training)
scorecases <- nrow(testing)
pred_train <- vector(length=buildcases)
pred_test  <- vector(length=buildcases)
pred_score <- vector(length=scorecases)

pred_trainLoop <- vector(length=buildcases)
pred_testLoop  <- vector(length=buildcases)
pred_scoreLoop <- vector(length=scorecases)
actuals <- training_data[,targetIndex]

for (model_type in models) {
  output_prefix <- paste(model_type, numLoops, sep = "_")
  if (model_type == 'rf') {
	output_prefix <- paste(output_prefix, RF_TREES, RF_MTRY, sep="_")
  }
  if (model_type == 'gbm') {
	output_prefix <- paste(output_prefix, GBM_SHRINKAGE, GBM_DEPTH, sep = "_")
  }
  if (model_type == 'nnet') {
    output_prefix <- paste(output_prefix, HIDDEN_NEURONS, sep = "_")
  }
  
	test_errors <- vector(length=numLoops)
	train_errors <- vector(length=numLoops)
	
	pred_testLoop <- 0
	pred_trainLoop <- 0
	pred_scoreLoop <- 0

  for (loop in 1:numLoops) {
    set.seed(loop * 43764)
    id <- sample(rep(seq_len(numFolds), length.out=nrow(training)))
    
    # lapply over them:
    indicies <- lapply(seq_len(numFolds), function(a) list(
      test = which(id==a),
      train = which(id!=a)
      ))
    
    pred_train <- 0
    pred_test  <- 0
    pred_score <- 0 
	
    # ESTIMATE ----------------------------------
    if (model_type == 'rf') {
      allModels <- foreach(i = 1:numFolds) %dopar% {
				library(randomForest)
				
        set.seed(i * loop * 82142)
				return(randomForest(x= training_data[indicies[[i]]$train,-targetIndex],y=training_data[indicies[[i]]$train, targetIndex]
				,ntree=RF_TREES
				,replace=FALSE
				,nodesize=RF_NODESIZE
				,sampsize=RF_SAMPLESIZE
				,mtry=RF_MTRY
				))

			}
    }
    
    if (model_type == 'gbm'){
	
    	minError = 999999999
    	minErrorTrees = 0
    	minErrorModels = c()
      numBlocks = ceiling(numFolds / threads)
      allModels <- list()
      for (block in 1:numBlocks) {
        start = (block - 1)*threads + 1
        end   = min(block * threads, numFolds)
        
        blockModels <- foreach(i = start:end) %dopar% {  
          library(gbm)
          set.seed(i * loop * 42000)
          #build the first model
          model <- gbm.fit(
            x = training_data[indicies[[i]]$train,-targetIndex]
            ,y = training_data[indicies[[i]]$train,targetIndex]
            ,distribution = GBM_DISTRIBUTION
            ,n.trees = GBM_TREE_BLOCK
            ,shrinkage = GBM_SHRINKAGE
            ,interaction.depth = GBM_DEPTH
            ,n.minobsinnode = GBM_MINOBS
            ,bag.fraction = GBM_BAGFRACTION
            ,verbose = FALSE
            ,keep.data = TRUE)
          
          return(model)
        }
        allModels <- c(allModels,blockModels)
      }
    	
      
    	numTrees = GBM_TREE_BLOCK
      error_seq = c()
      tree_seq  = c()
      index = 1
    	while (numTrees < (minErrorTrees + GBM_EXCESS_TREES)) {
    	  numTrees = numTrees + GBM_TREE_BLOCK
    	  
        rv <- list()
        for (block in 1:numBlocks) {
          start = (block - 1)*threads + 1
          end   = min(block * threads, numFolds)
          
          block_rv <- foreach(i = start:end) %dopar% {
            model <- gbm.more(allModels[[i]], n.new.trees = GBM_TREE_BLOCK, data = training_data[indicies[[i]]$train,])
            
            cvPred <- predict.gbm(object=model, newdata=training_data[indicies[[i]]$test,-targetIndex], numTrees, type = "response")      
            cvPred <- pmin(pmax(cvPred,lower_bound),upper_bound)
            cvError <- loss_function(training_data[indicies[[i]]$test,targetIndex],cvPred)  
            
            return(list(model,cvError))
          }
          rv <- c(rv,block_rv)
        }
        
        errors = c()
    	  for(i in 1:numFolds) {
          allModels[[i]] = rv[[i]][[1]]
          errors[i] = rv[[i]][[2]]
    	  }
        rm(rv)
        meanError <- mean(errors)
        
        print(paste(numTrees, meanError, sep = " => "))
        if (meanError < minError) {
          minErrorModels <- allModels
          minError <- meanError
          minErrorTrees <- numTrees
        }
        error_seq[index] = meanError
        tree_seq[index]  = numTrees
        plot(tree_seq, error_seq)
        index = index + 1
    	}
	
      allModels = minErrorModels
    	
    }

    
    if (model_type == 'nnet') {
      
            
      allModels <- foreach(i = 1:numFolds) %dopar% {
        #library(nnet)
        #return(nnet(x=training_data[indicies[[i]]$train,],y=target_data[indicies[[i]]$train]
        #            ,size=HIDDEN_NEURONS
        #            ,linout=NNET_LINOUT
        #            ))
        library(neuralnet)
        return(neuralnet(formula=theFormula 
                        ,data=training_data[indicies[[i]]$train,]
                        ,hidden=HIDDEN_NEURONS
                        ,linear.output=NNET_LINOUT
                        ,threshold=0.01
                        ,likelihood=TRUE))
      }
    }
    if (model_type == 'lr') {
      allModels <- foreach(i = 1:numFolds) %dopar% {
				return(lm(theFormula, data=training[indicies[[i]]$train,]))
			}
    }
    
    if (model_type == 'bart') {
      library(bart)
      return(bart(training_data[indicies[[i]]$train,-targetIndex], training_data[indicies[[i]]$train,targetIndex], testing_data))
    }
    
    # VALIDATE ----------------------------------
    for(fold in 1:numFolds) {

	#cat("\nloop = ",loop,"fold = ",fold) 
	#flush.console() 
	
	#set the cases for this fold
	rows_train <- indicies[[fold]]$train
	rows_test  <- indicies[[fold]]$test

	#build the models
	model <- allModels[[fold]]
	
	#score up the models
			
	#linear regression
	if (model_type == 'lr'){
	  buildPred <- predict(model, training, type="response")
	  scorePred <- predict(model, testing,  type="response")
	}
		  
	if (model_type == 'rf'){
	  buildPred <- predict(model, training_data[,-targetIndex])
	  scorePred <- predict(model, testing_data)
	}

	if (model_type == 'gbm'){		
	  numtrees <- model$n.trees
        cat("\ntrees=",numtrees) 
	  buildPred <- predict.gbm(object=model, newdata=training_data[,-targetIndex], numtrees, type = "response")
	  scorePred <- predict.gbm(object=model, newdata=testing_data, numtrees, type = "response")
	}
  
	if (model_type == 'nnet'){
	  #buildPred <- predict(model,newdata=training_data,type='raw')
    buildPred <- compute(model,covariate = training_data[,-targetIndex])[[2]]
	  #buildPred <- (buildPred * targ_std) + targ_mean
	  
	  scorePred <- compute(model,covariate = testing_data)[[2]]
	  #scorePred <- (scorePred * targ_std) + targ_mean
	}
			
	buildPred <- pmin(pmax(buildPred,lower_bound),upper_bound)
	scorePred <- pmin(pmax(scorePred,lower_bound),upper_bound)

	if (LOGIT_TRANSFORM) {
		buildPred <- utilities(buildPred)
		scorePred <- utilities(scorePred)
	}

      z                    <- buildPred
	z[rows_test]         <- 0
	pred_train           <- pred_train + z
	pred_test[rows_test] <- buildPred[rows_test]
	pred_score           <- pred_score + scorePred
    }
		
    #average the predictions on the scoring set
    pred_score <- pred_score / numFolds
    pred_train <- pred_train / (numFolds - 1)
  	
    pred_trainLoop <- pred_trainLoop + pred_train
    pred_testLoop  <- pred_testLoop  + pred_test
    pred_scoreLoop <- pred_scoreLoop + pred_score
  	
  	
    #calculate the cv error	
    
    trainValues = 0
    testValues = 0

    if (LOGIT_TRANSFORM) {
	  trainValues = probabilities(pred_trainLoop / loop)
	  testValues  = probabilities(pred_testLoop / loop)
    }
    else {
	  trainValues = pred_trainLoop / loop
	  testValues  = pred_testLoop / loop
    }
    train_errors[loop] <- loss_function(actuals,trainValues)
    test_errors[loop]  <- loss_function(actuals,testValues)
  	
    #cat("\n set=",output_prefix,"mod=",model,"loop=",loop,"cv error=",test_errors[loop],"\n\n") 
  
    if(loop>1){
  	title <- paste(output_prefix,model_type,numLoops,'by',numFolds,'-fold cross validation',sep=' ')
  	plot(test_errors[1:loop],type='l',main = title , xlab = 'loop', ylab = paste(numFolds,'-fold cross validation error',sep=''),ylim = range(rbind(test_errors[1:loop],train_errors[1:loop])))
  	points(train_errors[1:loop],type='l',col='red')
    }
    print(test_errors)
  } # LOOP

  #the cross validation predictions
  trainValues = 0
  testValues = 0
  scoreValues = 0

  if (LOGIT_TRANSFORM) {
	trainValues = probabilities(pred_trainLoop / numLoops)
	testValues  = probabilities(pred_testLoop / numLoops)
      scoreValues = probabilities(pred_scoreLoop / numLoops)
  }
  else {
	trainValues = pred_trainLoop / numLoops
  	testValues  = pred_testLoop / numLoops
      scoreValues = pred_scoreLoop / numLoops
  }
	
	#the distribution shows there are negative values
	#hist(pred_trainLoop,breaks = 100)	
	#hist(pred_testLoop,breaks = 100)
	#plot(pred_trainLoop,pred_testLoop)
	#plot(train_errors,test_errors,type='p')
	
	#params <- paste(modname1,numloops,numfolds,sep="_")

	#############################################
	##write the leaderboard and cv sets to file
	#############################################
	basename <- paste(output_dir,paste(output_prefix, sep="_"),sep="\\")
	
	submission_cv <- cbind(seq(1,nrow(training)),actuals,testValues)
	colnames(submission_cv) <- c("row_id","actual","prediction")
	filename <- paste(basename,"_CV.csv",sep="")
	write.csv(submission_cv, file=filename, row.names = FALSE,quote = FALSE)
	
	
	submission_score <- cbind(scoreValues)
	colnames(submission_score) <- c("prediction")
	
	filename <- paste(basename,"_LB.csv",sep="")
	write.csv(submission_score, file=filename, row.names = FALSE,quote = FALSE)
}

stopCluster(cluster)
