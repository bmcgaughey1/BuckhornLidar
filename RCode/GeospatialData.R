# explore geospatial data
#
# When I initially looked at the stem plot file, I thought it was study areas.
# Clarification from Connie and Derek Young at UC Davis confirmed that it had stem 
# locations. However, they don't line up well with the lidar.
library(terra)
library(mapview)

source("Rcode/FileSystem.R")

# read convex hull
vector_layers(convexHullFile)
ch <- vect(convexHullFile)
ch <- ch[ch$PLOT == "Buckhorn",]
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

# pull off lat-lon...assume this is EPSG:4326 but don't know for sure
# Jacob confirmed this should be EPSG:6318
df <- data.frame(gps$Site, gps$lon, gps$lat)
v <- vect(df, geom=c("gps.lon", "gps.lat"), crs = "EPSG:6318", keepgeom = TRUE)
mapview(v)

# project to WGS84 UTM10
pv <- project(v, "EPSG:32610")
mapview(pv)
crs(pv)

# write to file
writeVector(pv, paste0(dataFolder, "GPS_pts.shp"), overwrite = TRUE)
