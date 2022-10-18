
## Setup
# Please activate the following packages for the following data analysis.
my_packages <- c("readr", "ggplot2", "nortest", "grid", "gridExtra", "cowplot", "plyr", "dplyr", "QuantPsyc", "ggpubr", "ggsignif", "ggsci", "FSA", "dunn.test", "knitr", "base", "car", "RDocumentation", "onewaytests", "olsrr", "ggstatsplot", "PMCMRplus", "boot", "schoRsch", "dplyr", "ez", "nlme", "lsmeans", "lme4", "MCMCglmm", "rstatix", "lmerTest", "ggfortify", "lattice", "stringr", "reshape2", "pander", "foreach", "bestNormalize", "Hmisc", "pastecs", "RColorBrewer", "reshape2", "viridis", "scales", "devtools", "shadow", "nlme", 'pscl', 'aod', "MASS", "wesanderson", "moments", "pgirmess", "Rcpp", "lmerTest", "report", "emmeans", "multcomp", "remotes", "performance", "see", "parameters", "correlation", "insight", "e1071", "ggExtra", "hrbrthemes", "GGally", "tidyverse", "patchwork", "igraph", "ggraph", "colormap", "ggridges", "lawstat", "sm", "psycho", "rstanarm","modelbased", "emmeans", "modelbased")
library(easypackages)
#packages(my_packages) # install packages if necessary
libraries(my_packages) # load all packages
rm(my_packages)

##  Data upload and data check
# The current section loads and preprocesses the data set for the descriptive and inferential analysis later on.
# Load the data set and rename the coloumns
# Please consider to write down your path where you store the data!
dforiginal <- read_delim("~/Desktop/trajectory.txt", "\t", escape_double = FALSE, col_names = FALSE, trim_ws = TRUE)

colnames(dforiginal) <- c('id', 'session', 'trial', 'walkertype', 'translating', 'articulating', 'facing', 'headingdeg', 'headingestimate','headingerror', 'mousex', 'mx', 'my', 'leftright', 'tangent', 'radius', 'gravel')

# data prep
data <- subset(dforiginal, gravel == 0)
data$condition <- 1 # static condition
data$condition[data$translating == 1 & data$articulating == 1] <- 2 # natural walking condition
data$condition[data$translating == 1 & data$articulating == 0] <- 3 # only translation condition
data$condition[data$translating == 0 & data$articulating == 1] <- 4 # only articulation condition

data <- data[c("id", "session", "trial", "gravel", "condition", "facing", "headingdeg", "leftright", "tangent", "radius")]

data$curvature <- (1/data$radius)*data$leftright*(-1) #negative values of leftright indicate curvature to the right.
data$tangentdeg <- (data$tangent*180/pi)
data$error <- data$tangentdeg*data$leftright
# calculate heading error
data$instantaneousheading <- data$headingdeg+data$error


# calculating error in facing:
df <- subset(data, gravel == 0)
for (i in unique(df$id)) {
  for (j in unique(df$condition)) {
      temp <- subset(df, id == i & condition == j)
      error <- round(temp$error[temp$facing == 90] - temp$error[temp$facing == -90],3)
      error <- round(mean(error),3)
      condition <- j
      id <- i
      assign(paste("temp", i, j, sep=''), data.frame(error, condition, id))
      rm(temp)
  }
}
list_of_dataframes = do.call("list", mget(grep("temp", ls(), value=T)))
errorinfacing <- bind_rows(list_of_dataframes, .id = "column_label")
errorinfacing <- errorinfacing[-1]
rm(list = ls(list_of_dataframes), condition, id, i, j, error, list_of_dataframes, df)

# calculating curvature in facing:
df <- subset(data, gravel == 0)
for (i in unique(df$id)) {
  for (j in unique(df$condition)) {
      temp <- subset(df, id == i & condition == j)
      curvature <- round(temp$curvature[temp$facing == 90] - temp$curvature[temp$facing == -90],3)
      curvature <- round(mean(curvature),3)
      condition <- j
      id <- i
      assign(paste("temp", i, j, sep=''), data.frame(curvature, condition, id))
      rm(temp)
  }
}
list_of_dataframes = do.call("list", mget(grep("temp", ls(), value=T)))
curvatureinfacing <- bind_rows(list_of_dataframes, .id = "column_label")
curvatureinfacing <- curvatureinfacing[-1]
rm(list = ls(list_of_dataframes), condition, id, i, j, curvature, list_of_dataframes, df)




# calculate coordinates for mean trajectory that can be later used to recreate the average sketched trajectory (trajectory_heading_plots.m)
# calculating error in facing:
df <- subset(data, gravel == 0)
for (i in unique(sort(df$id))){
  for (j in unique(df$facing)) {
    for (k in unique(df$condition)) {
      temp <- subset(df, id == i & facing == j & condition == k)
      instantaneousheading <- round(mean(temp$instantaneousheading),3)
      curvature <- round(mean(temp$curvature),3)
      radius <- round(mean(temp$radius),3)
      tangent <- round(mean(temp$tangent),3)
      trueheading <- round(mean(temp$headingdeg),3)
      error <- round(mean(temp$error),3)
      condition<- k
      facing <- j
      id <- i
      assign(paste("temp", i, j, k, sep=''), data.frame(radius, tangent, trueheading, instantaneousheading, curvature, condition, facing, error, id))
      rm(temp)
    }
  }
}
list_of_dataframes = do.call("list", mget(grep("temp", ls(), value=T)))
trajectory <- bind_rows(list_of_dataframes, .id = "column_label")
trajectory <- trajectory[-1]
rm(list = ls(list_of_dataframes), condition, facing, id, i, j, k, radius, error, tangent, trueheading, instantaneousheading, curvature, list_of_dataframes, df)
trajectory$leftright <- sign(trajectory$curvature)
trajectory$leftright[trajectory$leftright == 0] <- 1
matlabexport <- data.frame(trajectory$facing, trajectory$radius, trajectory$tangent, trajectory$leftright*(-1), trajectory$trueheading, trajectory$id, trajectory$condition)
write.table(matlabexport, "/Applications/MATLAB/rdata.txt", sep ="\t", row.names = FALSE, col.names = FALSE)
rm(matlabexport)
