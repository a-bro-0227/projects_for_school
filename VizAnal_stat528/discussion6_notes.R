library(ggplot2)

ggplot(data = iris, aes(x = Sepal.Length, y = Sepal.Width, colour = Species)) +
  geom_point()

ggplot(data = mpg, aes(x = cty, y = hwy)) +
  geom_bin2d()

temp <- read.csv("https://www.ncdc.noaa.gov/cag/global/time-series/globe/land_ocean/1/8/1880-2018.csv", stringsAsFactors = F, skip = 4)

ggplot(data = temp, aes(x = Year, y = Value)) + geom_col()
ggplot(data = temp, aes(x = Year, y = Value)) + geom_density2d()


sample(1:50, size = 1000, replace = T)
