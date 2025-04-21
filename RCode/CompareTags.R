# code to compare tags entered for stem maps with UC Davis stem map
#
# NOTE: This does not check tags for border trees since these are not in the
# data from UC Davis
#
library(terra)

source("Rcode/FileSystem.R")

# set up some things for FUSION commands
outputFolder <- paste0(dataFolder, "StemMaps/")

# make sure output folder exists
if (!dir.exists(outputFolder)) {dir.create(outputFolder)}

# grid trees and UCD trees must be this close to "match"
bufferRadius <- 0.75

# set the block number (1-4)...loop to do all 4 blocks
for (blockNum in 1:4) {
  #blockNum <- 3

  # read new stem map trees for block
  bt <- vect(paste0(outputFolder, "ShiftedBlock", blockNum, "Trees.shp"))
  bt$gTAG <- as.integer(bt$Tag)
  
  # drop dead, border, and extra trees
  bt <- subset(bt, bt$Live == TRUE & bt$Extra == FALSE)
  
  # read UC Davis map for block
  UCDt <- vect(paste0(outputFolder, "ShiftedUCD", blockNum, "Trees.shp"))
  UCDt$TAG <- as.integer(UCDt$TAG)
  
  # buffer UCD trees
  UCDtBuffered <- buffer(UCDt, bufferRadius)
  
  # intersect grid trees with buffers
  it <- intersect(UCDtBuffered, bt)
  
  # compare tags
  match <- (it$TAG != it$gTAG)
  
  err <- subset(it, match)
  
  if (length(err) > 0) {
    writeVector(err, paste0(outputFolder, "Block", blockNum, "Errors.shp"), overwrite = TRUE)
    cat("Found errors in block", blockNum, "\n")
  } else {
    unlink(paste0(outputFolder, "Block", blockNum, "Errors.*"))
    cat("No errors in block", blockNum, "\n")
  }
}
