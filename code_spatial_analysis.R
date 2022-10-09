## Author : Khush Patel , drpatelkhush@gmail.com

#To install INLA
#install.packages("INLA",repos=c(getOption("repos"),INLA="https://inla.r-inla-download.org/R/stable"), dep=TRUE)

### library
library(maptools)
library(RColorBrewer)
library(classInt)
library(rgdal)
library(readxl)
library(tmap)
library(dplyr)
tmap_mode("view")
library(tidyverse)
library(spdep)
library(INLA)
library(ggplot2)
library(sf)
library(sp)
library(spdep)
library(rgeos)
library(tmap)
library(tmaptools)
library(spgwr)
library(grid)
library(gridExtra)
library(maptools)


options(prompt="R> ", digits=2, scipen=999)

#Preparing the data
TX_county <- readOGR(dsn="Datasets/TX_county", "TX_county", verbose = F)
cases_tx <- read.csv("Datasets/dataset_for_modeling_imputed.csv")
TX_county@data$myID <- 1:nrow(TX_county@data)
TX_county@data <- merge(TX_county@data, cases_tx, by.x="NAME", by.y="name")
TX_county@data <- TX_county@data[order(TX_county@data$myID),]

################################  PART 1 : Plotting  ##########################################################

#Plotting the number of Cases
tm_shape(TX_county) + tm_polygons("Cases", n=8, style="quantile", title="Colorectal Cancer cases 2009-2018")

#Plotting population at risk
tm_shape(TX_county) + tm_polygons("Population.at.Risk", n=8, style="quantile", title="Population at Risk (2009-2018)")

#Plotting crude case rate
tm_shape(TX_county) + tm_polygons("Crude.Rate", n=8, style="quantile", title="Crude Case Rate (per 100,000) (2009-2018)")

#PLotting age adjusted rate
#https://seer.cancer.gov/seerstat/tutorials/aarates/step3.html
tm_shape(TX_county) + tm_polygons("Age.adjusted.Rate", n=8, style="quantile", title="Age adjusted Case Rate (per 100,000) (2009-2018)")

#Plotting Expected counts for each county
tm_shape(TX_county) + tm_polygons("expected_count", n=8, style="quantile", title="Expected Counts")

#Plotting Standardized Incidence Ratio
TX_county@data$SMR =  TX_county@data$Ageadjustedcase / TX_county@data$expected_count
tm_shape(TX_county) + tm_polygons("SMR", n=8, style="quantile", title="Standardized Incidence Ratio")

################################   PART 2:  Model development         ########################################

TX_county <- readOGR(dsn="Datasets/TX_county", "TX_county", verbose = F)
cases_tx <- read.csv("Datasets/dataset_for_modeling_imputed.csv")
TX_county@data$myID <- 1:nrow(TX_county@data)
TX_county@data <- merge(TX_county@data, cases_tx, by.x="NAME", by.y="name")
TX_county@data <- TX_county@data[order(TX_county@data$myID),]

#Reading the data
df =TX_county@data

#Storing smr as a seperate variable
smr <-  df$smr

###Fitting a simple Poisson model and later Quasi Poisson model to check overdispersion. 
###Poisson
mod_poisson <- glm(Y~ offset(log(E)) + Hispanic + White + African_american  + Bachelor_Degree + smoking, dat=df, family = poisson)
summary(mod_poisson)

mod_quasipoisson <- glm(Y~offset(log(E)) + Hispanic + White + African_american + Bachelor_Degree + smoking, dat=df, family = quasipoisson)
summary(mod_quasipoisson)

##Using inla to develop Bayesian Poisson model
formula <- Y~Hispanic + White + African_american +  Bachelor_Degree + smoking
mod_Bayesian_poisson <- inla(formula, family='poisson', data=df, E=E, control.predictor = list(compute=TRUE),
                          verbose=TRUE,   control.compute = list(cpo=TRUE, dic=TRUE, waic=TRUE))
summary(mod_Bayesian_poisson)
mod_Bayesian_poisson$summary.fitted.values 

##County level random effects model iid
df$idareav <- 1:254
formula <- Y~Hispanic + White + African_american + Bachelor_Degree + smoking+ f(idareav, model = 'iid')  
res <-  inla(formula, family = 'poisson', data=df, E=E, control.predictor = list(compute=TRUE) , control.compute = list(cpo=TRUE, dic=TRUE, waic=TRUE))
res$summary.random
summary(res)
res$summary.random$idareav$mean 

g <- inla.read.graph(filename="map_hw1.adj")
formula <- Y ~ Hispanic + White + African_american  + Bachelor_Degree + smoking + f(idareau, model="besag", graph=g,  scale.model=TRUE) + f(idareav, model="iid") 
df$idareau <- 1:254

res2 <- inla(formula, family="poisson", data=df, E=E, control.predictor = list(compute=TRUE), control.compute = list(cpo=TRUE, dic=TRUE, waic=TRUE))
summary(res2)

TX_county@data$RR <- res2$summary.fitted.values[, 'mean']

tm_shape(TX_county) + tm_polygons("RR", n=8, style="quantile", title="RR for Colorectal Cancer")

spplot(TX_county, as.table=TRUE, c("smr", "RR"))

##waic
mod_Bayesian_poisson$waic$waic   #Bayesian model waic
res$waic$waic # Model with County level random effects
res2$waic$waic # MOdel with Additional county level random effects

marginal <- inla.smarginal(res2$marginals.fixed$Bachelor_Degree)
marginal <- data.frame(marginal)
ggplot(marginal, aes(x = x, y = y)) + geom_line() +
  labs(x = expression(beta[1]), y = "Density") +
  geom_vline(xintercept = 0, col = "royalblue") + theme_bw() +
  geom_vline(xintercept=-2.248, col="magenta")

##Exceedance probabilities
marg <- res2$marginals.fitted.values[[1]]
1 - inla.pmarginal(q=2, marginal = marg)

options(prompt="R> ", digits=2, scipen=999)



#Preparing the data
TX_county <- readOGR(dsn="Datasets/TX_county", "TX_county", verbose = F)
cases_tx <- read.csv("Datasets/dataset_for_modeling_imputed.csv")
TX_county@data$myID <- 1:nrow(TX_county@data)
TX_county@data <- merge(TX_county@data, cases_tx, by.x="NAME", by.y="name")
TX_county@data <- TX_county@data[order(TX_county@data$myID),]
df =TX_county@data

glimpse <-  TX_county@data 

tm_shape(TX_county) + 
  tm_fill("Y",
          palette = "Reds", 
          style = "quantile", 
          title = "Age adjusted cases") +
  tm_borders(alpha=.4)  

##Find queen neighbors

neighbours <- poly2nb(TX_county)
neighbours

#PLotting Queen neighbor links

plot(TX_county, border = 'lightgrey')
plot(neighbours, coordinates(TX_county), add=TRUE, col='red')

#Find rook neighbors

neighbours2 <- poly2nb(TX_county, queen = FALSE)
neighbours2

plot(TX_county, border = 'lightgrey')
plot(neighbours2, coordinates(TX_county), add=TRUE, col='blue')

#Rook vs Queen
plot(TX_county, border = 'lightgrey')
plot(neighbours, coordinates(TX_county), add=TRUE, col='red')
plot(neighbours2, coordinates(TX_county), add=TRUE, col='blue')

#Global spatial autocorrelation
listw <- nb2listw(neighbours2)
listw

#Global Moran test
globalMoran <- moran.test(TX_county@data$Y, listw)
globalMoran

#Local Moran

#Moran scatterplot

moran <- moran.plot(TX_county@data$Y, listw = nb2listw(neighbours2, style = "W"))

#Computing local Moran

local <- localmoran(TX_county@data$Y, listw = nb2listw(neighbours2, style = "W"))

##Ii: local moran statistic /  E.Ii: expectation of local moran statistic
# Var.Ii: variance of local moran statistic /Z.Ii: standard deviate of local moran statistic
#Pr(): p-value of local moran statistic

#PLotting local Moran
moran.map <- cbind(TX_county, local)
tm_shape(moran.map) +
  tm_fill(col = "Ii",
          style = "quantile",
          title = "local moran statistic") 

##Plot LISA clusters
quadrant <- vector(mode="numeric",length=nrow(local))

# centers the variable of interest around its mean
m.qualification <- TX_county@data$Y - mean(TX_county@data$Y)   

# centers the local Moran's around the mean
m.local <- local[,1] - mean(local[,1])    

# significance threshold
signif <- 0.05 

# builds a data quadrant
quadrant[m.qualification >0 & m.local>0] <- 4  
quadrant[m.qualification <0 & m.local<0] <- 1      
quadrant[m.qualification <0 & m.local>0] <- 2
quadrant[m.qualification >0 & m.local<0] <- 3
quadrant[local[,5]>signif] <- 0   

# plot in r
brks <- c(0,1,2,3,4)
colors <- c("white","blue",rgb(0,0,1,alpha=0.4),rgb(1,0,0,alpha=0.4),"red")
plot(TX_county,border="lightgray",col=colors[findInterval(quadrant,brks,all.inside=FALSE)])
box()
legend("bottomleft", legend = c("insignificant","low-low","low-high","high-low","high-high"),
       fill=colors,bty="n")

#Fit a OLS model
CRC_LM <- lm(Y~ Hispanic + White + African_american + Poverty + Bachelor_Degree + smoking, data = df) 
summary(CRC_LM)


##Fit a sptial model
CRC_LAG <- lagsarlm(Y~ offset(log(E)) + Hispanic + White + African_american + Poverty + Bachelor_Degree + smoking, data = df, listw)  #creates a spatial lag model (SAR)
summary(CRC_LAG)
