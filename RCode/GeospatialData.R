# explore geospatial data
#
# After looking at these files, they appear to be related to the seed source
# locations for the trial and not the actual trial site.
library(terra)
library(mapview)

source("Rcode/FileSystem.R")

# the geopackage files Connie sent turned out to be related to the out planning
# sites...
# read convex hull
vector_layers(convexHullFile)
ch <- vect(convexHullFile)
plot(ch)
mapview(ch)

# read stem plots
vector_layers(stemPlotFile)
sp <- vect(stemPlotFile)
plot(sp)
mapview(sp)

# read GPS points from Connie
gps <- read.csv(paste0(dataFolder, "2024JavadpointsCAHBuckhornPlus.csv"), stringsAsFactors = FALSE)
gps$lat <- gsub("N ", "", gps$Latitude)
gps$lat <- as.double(gsub("°", "", gps$lat))
gps$lon <- gsub("W ", "", gps$Longitude)
gps$lon <- as.double(gsub("°", "", gps$lon))
gps$lon <- -gps$lon

# drop jammer1
gps <- gps[gps$Site != "jammer1",]

# pull off lat-lon
df <- data.frame(gps$Site, gps$lon, gps$lat)
v <- vect(df, geom=c("gps.lon", "gps.lat"), crs = "EPSG:4326", keepgeom = TRUE)
mapview(v)

pv <- project(v, "EPSG:26910")
mapview(pv)
crs(pv)

# write to file
writeVector(pv, paste0(outputFolder, "GPS_pts.shp"), overwrite = TRUE)
