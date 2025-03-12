# code to convert DTMs from .tif to .dtm format. Uses the fusionwrapr package
# to convert terra SpatRasters into FUSION (PLANS) .dtm format
#
# Data are in UTM zone 10 with XY and elevations in meters (EPSG:26910)
#
# Source file names (.tif) are in FileSystem.R
source("Rcode/FileSystem.R")

library(terra)
library(fusionwrapr)

d <- rast(DTMFile)
writeDTM(d, FUSION_DTMFile, xyunits = "m", zunits = "m", coordsys = 2, zone = 10, horizdatum = 2, vertdatum = 2)
