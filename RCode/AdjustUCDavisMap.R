# code to refine alignment of UC Davis stem map...used to check tag numbers
# in the data I created
#
library(terra)

source("Rcode/FileSystem.R")

# set up some things for FUSION commands
outputFolder <- paste0(dataFolder, "StemMaps/")

# read stem plots...from UC-Davis
allTrees <- vect(stemPlotFile)

# add projected XY as columns
df <- crds(allTrees, df = TRUE)
allTrees$X <- df$x
allTrees$Y <- df$y

# select buckhorn trees
allTrees <- subset(allTrees, allTrees$SITE == "Buckhorn")

# select trees based on columns numbers to split into blocks
# this is needed because block 1 offset is different from blocks 2-4
b1Trees <- subset(allTrees, allTrees$COL < 13)
b2Trees <- subset(allTrees, allTrees$COL >= 13 & allTrees$COL < 25)
b3Trees <- subset(allTrees, allTrees$COL >= 25 & allTrees$COL < 37)
b4Trees <- subset(allTrees, allTrees$COL >= 37 & allTrees$COL < 49)

# build list of blocks to make use in loop easier
UCDTrees <- list(b1Trees, b2Trees, b3Trees, b4Trees)

# for block 1, tag 7709 is SW tree
# for block 2, tag 3520 is SW tree
# for block 3, tag 5147 is SW tree
# for block 4, tag 8735 is SW tree
SWtags <- c("7709", "3520", "5147", "8735")

# rotations...measured in ArcPro after first run through this code with no rotation
# by measuring the angle between a column in the UCDavis stem map and the corresponding
# column in the new stem maps
doRotation <- TRUE
angles <- c(2.15, 0.88, 0.43, 0.0)

# set the block number (1-4)...loop to do all 4 blocks
for (blockNum in 1:4) {
  #blockNum <- 2

  # read new stem map trees for block
  bt <- vect(paste0(outputFolder, "ShiftedBlock", blockNum, "Trees.shp"))
  
  # find SW corner trees in maps
  UCDt <- UCDTrees[[blockNum]]
  UCDSWt <- subset(UCDt, UCDt$TAG == SWtags[[blockNum]])
  
  bSWt <- subset(bt, bt$Tag == SWtags[[blockNum]])
  
  # compute offset
  ox <- bSWt$X - UCDSWt$X
  oy <- bSWt$Y - UCDSWt$Y
  
  # shift UC Davis block map and write to file
  st <- shift(UCDTrees[[blockNum]], ox, oy)
  
  if (doRotation) {
    st <- spin(st, angles[[blockNum]], UCDSWt$X + ox, UCDSWt$Y + oy)
  }
  
  # replace XY with new locations
  xy <- geom(st, df = TRUE)
  st$X <- xy$x
  st$Y <- xy$y
  
  writeVector(st, paste0(outputFolder, "ShiftedUCD", blockNum, "Trees.shp"), overwrite = TRUE)
}
