source("random_forest.R")
source("cross_validation.R")

my_data = read.csv("D:\\Goodfilms\\sandpit\\test_data.csv")


targets   = c("a_quality_rating","a_rewatch_rating")

all_names = colnames(my_data)
x_names   = all_names[all_names != targets]



num_records = 50000

x = my_data[seq(num_records),x_names]

ready.random.forest = configure.random.forest(300,50,5000,2,FALSE)

for (target in targets) {
  y = my_data[seq(num_records),c(target)]  
  
  predictions = cross.validate(x,y,ready.random.forest,random.forest.predict,2,123123)
  
  plot(y,predictions)
  
  errors = predictions - y
  squared_error = mean(errors * errors)
  print(squared_error)
}
