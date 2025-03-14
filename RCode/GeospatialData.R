# explore geospatial data
#
# After looking at these files, they appear to be related to the seed source
# locations for the trial and not the actual trial site.
library(terra)
library(mapview)

source("Rcode/FileSystem.R")

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

crowns <- vect("H:/Buckhorn2/Buckhorn2_Finals/FUSIONProcessing/Trees/crowns.shp")
plot(crowns)
