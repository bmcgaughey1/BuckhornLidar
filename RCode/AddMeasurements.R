# code to add new measurements to tree records...not for all trees
#
source("Rcode/FileSystem.R")
library(terra)

# set up some things for FUSION commands
outputFolder <- paste0(dataFolder, "StemMaps/")

# read new measurement data...format is a little wonky with no quotation marks
# around values. Blank data in columns without quotes.
#
# file contains 2 sets of measurements first is 253 trees plus header row
# second is 29 "extra" trees...starts in row 256 (skip = 255) with header
newMeasurements <- read.csv("SupportingData/BuckhornEOYHeightsSpring25.csv"
                            , stringsAsFactors = FALSE
                            , colClasses = c("character","integer","integer","integer","integer",
                                             "character","integer","integer","integer","integer","integer","character")
                            , nrows = 253
)
newMeasurementsExtra <- read.csv("SupportingData/BuckhornEOYHeightsSpring25.csv"
                            , stringsAsFactors = FALSE
                            , colClasses = c("character","character","integer","integer","integer",
                                             "character","integer","integer","integer","integer","integer","character")
                            , skip = 255
)

# set the block number (1-4)...loop to do all 4 blocks
blockNum <- 1
for (blockNum in 1:4) {
  # read matched trees...no measurements
  mt <- vect(paste0(outputFolder, "MatchedBlock", blockNum, "Trees.shp"))
  
  # read shifted UCDavis trees...have older measurements
  uct <- vect(paste0(outputFolder, "ShiftedUCD", blockNum, "Trees.shp"))
  
  # join UCDavis measurements to matched lidar trees
  nt <- merge(mt, uct, by.x = "Tag", by.y = "TAG")
  
  # need to deal with the multiple stems in new measurements...
  
  @@@@@
}