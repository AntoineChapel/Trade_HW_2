library(fixest)


df = read.csv("Detroit.csv", header = TRUE)

tic = Sys.time()
gravity_ols = feols(log(flows) ~ log(distance_Google_miles) | home_ID + work_ID, df)
tac = Sys.time()

print(gravity_ols)
print(paste("Time elapsed: ", tac - tic, " seconds"))

etable(gravity_ols, file = "regtable1_R.tex", 
       title = "Gravity Model in R with fixest", tex = TRUE)


tic2 = Sys.time()
gravity_pois = fepois(flows ~ log(distance_Google_miles) | home_ID + work_ID, df)
tac2 = Sys.time()

print(gravity_pois)
print(paste("Time elapsed: ", tac2 - tic2, " seconds"))

etable(gravity_pois, file = "regtable2_R.tex", 
       title = "Poisson Gravity Model in R with fixest", tex = TRUE)
