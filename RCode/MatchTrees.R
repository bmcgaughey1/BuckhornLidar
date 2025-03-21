# code to match lidar-derived trees to stem maps
#
source("Rcode/FileSystem.R")

library(terra)

# set up some things for FUSION commands
outputFolder <- paste0(dataFolder, "StemMaps/")

# load lidar-derived trees
lt <- vect(paste0(dataFolder, "FUSIONProcessing/trees/trees.shp"))

# grid trees and lidar trees must be this close to "match"
bufferRadius <- 1.0

# set the block number (1-4)...loop to do all 4 blocks
for (blockNum in 1:4) {
  #blockNum <- 1
  
  # load grid trees for block
  bt <- vect(paste0(outputFolder, "ShiftedBlock", blockNum, "Trees.shp"))
  
  # only want the live grid trees...no extra trees
  # ******* check this!! may want extra trees between rows if not cut
  lbt <- subset(bt, bt$Live == TRUE & bt$Filler == FALSE & bt$Extra == FALSE)
  
  # buffer grid trees
  lbtBuffered <- buffer(lbt, bufferRadius)
  
  # intersect lidar trees (points) with buffers (polygons)
  it <- intersect(lbtBuffered, lt)
  
  
  
  
  
  
  
  # compute mean distance in X and Y
  it$diffX <- it$X - it$HighPtX
  it$diffY <- it$Y - it$HighPtY
  mx <- mean(it$diffX)
  my <- mean(it$diffY)
  
  # shift all grid trees
  btShifted <- shift(bt, -mx, -my)
  
  # replace XY with new locations
  xy <- geom(btShifted, df = TRUE)
  btShifted$X <- xy$x
  btShifted$Y <- xy$y
  
  # write shifted grid trees
#  writeVector(btShifted, paste0(outputFolder, "ShiftedBlock", blockNum, "Trees.shp"), overwrite = TRUE)
}
