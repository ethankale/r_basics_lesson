#######################
# Learning about R 
# August 7, 2019
# Instructor: Nat Kale
#######################

# Reading an R script ----------------------------------------

# Anything with a hash in front of it, meaning one of these -> # is a comment.
#   R doesn't evaluate comments; you use them to help yourself and others
#   understand your code.

# A comment line that starts and ends with four hashes - #### - or ends with 
#   at least four dashes, is a section title.

# A Section Title ----

#### Another Section Title ####

# Use sections to break up your script.
# Everything else is code.

# In RStudio, you can use the tiny arrow to the left of a section title
#   to hide the section.  Try it now!

# Try not to use more than 80 characters on a line.  Nothing bad will happen,
#   but your scripts will get harder to read.

# Command Line Basics ----------------------------------------

# Use ctrl+enter to the single line of code your cursor is on.  
#   Ctrl+alt+b to run up to your cursor.
#   Ctrl+alt+r to run the whole script (not recommended right now!)

# Basic math
1+1
3*2

# Built in functions and constants
sqrt(9)
pi
exp(1)
log(10)
2^5

# Order of operations
1+2*3
(1+2)*3

# Variables
a <- 2*5
b <- 7+2
c <- a*b

a
b
c

# You *can* assign variables using = , but R users usually use the arrow.
# Variable names should be meaningful.  

# It would be a good idea to use the tidyverse style guide for naming things:
#   (https://style.tidyverse.org/syntax.html#object-names)
#   Short version - letters and numbers, whole words, connected by _ 

velocity_fps  <- 3.5
area_sqft     <- 4.5
discharge_cfs <- velocity_fps * area_sqft

# Getting help

?pi

# Objects; or, Special R Thingies -----------------------------

# Lists, sometimes called Vectors (when they're numbers)
arbitrary_list      <- c(4, 6, 1, 44)
sequence_of_numbers <- seq(2, 10, 2)
repeated_number     <- rep(5.2, 8)
repeated_list       <- rep(arbitrary_list, 5)

# Information about vectors
length(repeated_number)
min(arbitrary_list)
max(arbitrary_list)
mean(arbitrary_list)
median(arbitrary_list)

summary(repeated_list)
quantile(repeated_list, .95)

# Vector math
arb_list_doubled  <- arbitrary_list * 2
arb_and_seq       <- arbitrary_list + sequence_of_numbers

# The last command gave a *warning*, but not an error.  There is an output,
#   but there's also something you should pay attention to.

# Why does the arb_and_seq vector look like it does?

# Matrices
arbitrary_matrix <- matrix(repeated_number, 2)
arbitrary_matrix * 3

# Let's put a few things we've learned together
another_matrix   <- matrix(rep(c(1,2,3,4),2),2)

# Matrix math
arbitrary_matrix * another_matrix

# Subsetting
another_matrix[1]

# [Column, Row] - it's backwards, but since you more frequently subset
#   columns than rows, it kind of makes sense
another_matrix[,1]
another_matrix[1,]

# Break and review

# Dataframes (data.frame) -------------------------------------

# Dataframes are what you'll be mostly working with.
data(iris)

summary(iris)
head(iris)
colnames(iris)

nrow(iris)
ncol(iris)
length(iris)

# [Row, Column] - yes it's different from matrices.  No I don't know why.
# Columns have names, so subsetting can be a little different
iris$Sepal.Length
iris[,"Sepal.Length"] 
iris[,1]

# Factors
iris$Species
species_num  <- as.numeric(iris$Species)
species_char <- as.character(iris$Species)

species_num
species_char

# Basic plotting ------------------------------------

# with() temporarly "attaches" a dataset, so that you can refer
#   to the columns directly, as if they were regular lists, without
#   typing in the name of the dataset every time
with(iris, plot(x = Sepal.Length, y = Sepal.Width))

?plot

# Fun with plotting options!
with(iris, plot(Sepal.Length, Sepal.Width, type="l"))
with(iris, plot(Sepal.Length, Sepal.Width, pch=4))
with(iris, plot(Sepal.Length, Sepal.Width, pch="?"))
with(iris, plot(Sepal.Length, Sepal.Width, pch="+",
                main = "Iris", xlab = "Sepal Length", ylab = "Sepal Width"))

# Play around a little, try different settings, and plotting
#   different columns

# A different kind of plot.
#   Formulae are important in R.  They use the tilde, and they're in 
#   a specific format, like this: dependent_var ~ var_1.  We'll use them
#   more when we get to regression.
boxplot(Sepal.Length ~ Species, data = iris)

?boxplot

# Try making a boxplot of another column

# Break and review?

# Loading Libraries  -----------------------------------------
#install.packages("tidyverse")
#install.packages("dataRetrieval")

library(tidyverse)
library(dataRetrieval)

# dataRetrieval is a USGS package for downloading and using data from
#   NWIS, the USGS database for surface water, and a few other DBs too.

# Putting together what we've learned, we can pull some data and use it.
deschutes_nwis <- c(12080010, 12079000) # Two Deschutes NWIS sites

# To figure out how to use dataRetrieval, I googled it.
#   http://usgs-r.github.io/dataRetrieval/reference/readNWISstat.html

# This will only work with an internet connection...
deschutes_info <- readNWISstat(deschutes_nwis, 
                               parameterCd = c("00060"),
                               statReportType="annual")

summary(deschutes_info)

# ggplot2 is a really popular package, part of "tidyverse", for plotting.
#   "gg" stands for "grammar of graphics".
ggplot(deschutes_info, aes(x = year_nu, y = mean_va)) +
  geom_line() +
  geom_point() +
  facet_grid(ts_id ~ .) +
  labs(title = "Two Deschutes Gauges",
       subtitle = "Mean Annual Discharge",
       x = "",
       y = "Discharge, cfs") +
  theme_minimal() 

ggsave("c:/data/deschutes_plot.png",
       width = 7, height = 4)

# We can do boxplots with ggplot2, as well
ggplot(deschutes_info, aes(y = mean_va, group = ts_id)) +
  geom_boxplot() +
  facet_grid(. ~ ts_id) +
  labs(title = "Two Deschutes Gauges",
       subtitle = "Mean Annual Discharge",
       x = "",
       y = "Discharge, cfs") +
  scale_x_discrete(labels = c(unique(deschutes_info$site_no))) +
  theme_minimal() 

ggsave("c:/data/deschutes_boxplot.png",
       width = 7, height = 4)

# The "tidyverse" also includes a package called dplyr, which we can use
#   to perform some advanced data analysis

deschutes_summary <- deschutes_info %>%
  group_by(site_no) %>%
  summarize(max_cfs    = max(mean_va),
            min_cfs    = min(mean_va),
            median_cfs = median(mean_va),
            span       = paste0(min(year_nu), " - ", max(year_nu)),
            year_count = n())

deschutes_summary

# Regression! -----------------------------------------------------

# Let's start by looking at the Iris dataset again
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length)) +
  geom_point() +
  labs(title = "Iris Data",
       x = "Sepal Length (cm)",
       y = "Petal Length (cm)") +
  theme_minimal()

# Simple linear regression is accomplished with the lm() command
iris.lm <- with(iris, lm(Petal.Length ~ Sepal.Length))

summary(iris.lm)
plot(iris.lm)

# We can use the predict() function to figure out the estimated value
iris$Petal.Length.Predict <- predict(iris.lm, newdata = iris)

# Now that we have a prediction, let's plot the line
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length)) +
  geom_point() +
  geom_line(aes(x = Sepal.Length, y = Petal.Length.Predict)) +
  labs(title = "Iris Data",
       x = "Sepal Length (cm)",
       y = "Petal Length (cm)") +
  theme_minimal()

# Linear regression can take more than one independent variable; it can do a 
#   whole lot of things
iris.lm2 <- with(iris, lm(Petal.Length ~ Sepal.Length + Sepal.Width + Petal.Width))

summary(iris.lm2)

# Note that the R2 is a LOT better this time, and that all three of the 
#   independent variables are significant
iris$Petal.Length.Predict2 <- predict(iris.lm2, newdata = iris)


# Since there's no longer  a straight-line relationship between a single
#   independent variable and the dependent variable, we plot the points rather
#   than trying to plot a line.  Try that, Excel!
ggplot(iris, aes(x = Sepal.Length, y = Petal.Length)) +
  geom_point(aes(x = Sepal.Length, y = Petal.Length.Predict2),
              color = "red", shape = "x", size = 3) +
  geom_point() +
  labs(title = "Iris Data",
       x = "Sepal Length (cm)",
       y = "Petal Length (cm)") +
  theme_minimal()

