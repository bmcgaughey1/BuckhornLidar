# code to refine the alignment of the "perfect" planting grid 
# with the lidar-derived tree locations
#
# Basic idea is to match lidar trees and grid trees using a small search
# radius and then compute the average offset in locations. Apply this offset
# to shift the grid trees. This will keep the perfect grid but should give a 
# slightly better alignment.
#
# This assumes that the rotation angle I measured in ArcPro is correct...
#
library(terra)

source("Rcode/FileSystem.R")

# set up some things...
outputFolder <- paste0(dataFolder, "StemMaps/")

# load lidar-derived trees
lt <- vect(paste0(dataFolder, "FUSIONProcessing/trees/trees.shp"))

# grid trees and lidar trees must be this close to "match"
bufferRadius <- 0.5

# set the block number (1-4)...loop to do all 4 blocks
for (blockNum in 1:4) {
  #blockNum <- 1

  # load grid trees for block
  bt <- vect(paste0(outputFolder, "Block", blockNum, "Trees.shp"))
  
  # only want the live grid trees...no filler trees...no extra trees
  lbt <- subset(bt, bt$Live == TRUE & bt$Filler == FALSE & bt$Extra == FALSE)
  
  # buffer grid trees
  lbtBuffered <- buffer(lbt, bufferRadius)
  
  # intersect lidar trees with buffers
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
  writeVector(btShifted, paste0(outputFolder, "ShiftedBlock", blockNum, "Trees.shp"), overwrite = TRUE)
}
