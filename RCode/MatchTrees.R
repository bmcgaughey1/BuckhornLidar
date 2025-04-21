# code to match lidar-derived trees to stem maps
#
source("Rcode/FileSystem.R")

library(terra)

# set up some things for FUSION commands
outputFolder <- paste0(dataFolder, "StemMaps/")

# make sure output folder exists
if (!dir.exists(outputFolder)) {dir.create(outputFolder)}

# load lidar-derived trees
lt <- vect(paste0(dataFolder, "FUSIONProcessing/trees/trees.shp"))

# grid trees and lidar trees must be this close to "match"
bufferRadius <- c(0.5, 0.75, 1.0, 1.25)

blockNum <- 2

# set the block number (1-4)...loop to do all 4 blocks
for (blockNum in 1:4) {
  #blockNum <- 1
  
  # load grid trees for block
  bt <- vect(paste0(outputFolder, "ShiftedBlock", blockNum, "Trees.shp"))
  
  mt <- data.frame()
  
  for (level in 1:length(bufferRadius)) {
    # only want the live grid trees...no extra trees
    # ******* check this!! may want extra trees between rows if not cut
    lbt <- subset(bt, bt$Live == TRUE & bt$Filler == FALSE & bt$Extra == FALSE)
    
    # buffer grid trees
    lbtBuffered <- buffer(lbt, bufferRadius[level])
    
    # intersect lidar trees (points) with buffers (polygons)
    it <- intersect(lbtBuffered, lt)
    
    # compute distance from lidar tree to stem map tree
    it$dist <- sqrt((it$HighPtX - it$X) ^ 2 + (it$HighPtY - it$Y) ^ 2)
    
    # get list of Tag values for duplicates
    dupTags <- it$Tag[duplicated(it$Tag)]
    
    # keep closest tree
    it <- sort(it, c("Tag", "dist"))
    
    # remove all rows that are duplicated...because the list is sorted on distance,
    # the closest matching point will be kept
    it <- it[!duplicated(it$Tag), ]
  
    # mark these trees with confidence level...related to buffer size used for intersection
    it$confidenceLevel <- level
    
    # join with grid trees
    if (level == 1)
      mt <- it
    else
      mt <- rbind(mt, it)
    
    # update the stem map to drop trees that were matched
    bt <- bt[!bt$Tag %in% mt$Tag, ]
  }  

  writeVector(mt, paste0(outputFolder, "MatchedBlock", blockNum, "Trees.shp"), overwrite = TRUE)
  
  # re-read stem map
  bt <- vect(paste0(outputFolder, "ShiftedBlock", blockNum, "Trees.shp"))
  
  # get stems NOT matched
  bt <- bt[!bt$Tag %in% mt$Tag, ]
  bt <- subset(bt, bt$Live == TRUE & bt$Filler == FALSE & bt$Extra == FALSE)
  
  writeVector(bt, paste0(outputFolder, "NOT_MatchedBlock", blockNum, "Trees.shp"), overwrite = TRUE)
}
