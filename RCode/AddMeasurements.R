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
blockNum <- 2
for (blockNum in 1:4) {
  # read matched trees...no measurements
  mt <- vect(paste0(outputFolder, "MatchedBlock", blockNum, "Trees.shp"))
  
  # read shifted UCDavis trees...have older measurements
  uct <- vect(paste0(outputFolder, "ShiftedUCD", blockNum, "Trees.shp"))
  
  # join UCDavis measurements to matched lidar trees...
  # all.x = TRUE keeps rows in mt that aren't in uct
  #
  # merging drops columns used for merge in y
  mt_uct <- merge(mt, uct, by.x = "Tag", by.y = "TAG", all.x = TRUE)
  mt_uctdf <- as.data.frame(mt_uct)
  colnames(mt_uctdf)
  
  # mt_uct24 has the matched trees with 2024 measurements...no others
  mt_uct24 <- merge(mt_uct, newMeasurements, by.x = c("Tag"), by.y = c("TAG"), all.x = FALSE)
  mt_uct24df <- as.data.frame(mt_uct24)
  colnames(mt_uct24df)
  
  # rows are duplicated in mt_uct24 when there are measurements for stem a and b in the newMeasurements
  
  # clean up columns...brute force
  mt_uct24df <- mt_uct24df[, c(25, 1:16, 19:24, 29:46, 54:59)]
  colnames(mt_uct24df) <- c(
    "SITE", "Tag", "Block", "Plot", "Row", "Col", "Live", "Border", "Filler",
    "Extra", "X", "Y", "BasinID", "GridHighX", "GridHighY", "GridCells", "GridMaxHt",
    "UnsmthHt", "HighPtX", "HighPtY", "HighPtHt", "dist", "confidence", "STEM", "PBD",
    "BD21", "PDBH", "DBH21", "PHT", "HT21", "FL21", "PCWA", "CWA21", "PCWB",
    "CWB21", "PCODE", "CODE21", "PCOMM", "COMM21", "X_Long", "Y_Lat", "DBH24", "HT21",
    "HT23", "HT24", "HTLC24", "COMMENT"
  )
  
  # clean up columns in full match dataset...should have done this before second merge
  mt_uctdf <- mt_uctdf[, c(25, 1:16, 19:24, 29:46)]
  colnames(mt_uctdf) <- c(
    "SITE", "Tag", "Block", "Plot", "Row", "Col", "Live", "Border", "Filler",
    "Extra", "X", "Y", "BasinID", "GridHighX", "GridHighY", "GridCells", "GridMaxHt",
    "UnsmthHt", "HighPtX", "HighPtY", "HighPtHt", "dist", "confidence", "STEM", "PBD",
    "BD21", "PDBH", "DBH21", "PHT", "HT21", "FL21", "PCWA", "CWA21", "PCWB",
    "CWB21", "PCODE", "CODE21", "PCOMM", "COMM21", "X_Long", "Y_Lat"
  )
}

t <- mt_uct24df$HT24 / 100 - mt_uct24df$HighPtHt
plot(mt_uct24df$HT24 / 100, mt_uct24df$HighPtHt)
points(mt_uct24df$HT24 / 100, mt_uct24df$UnsmthHt, col = "red")
points(mt_uct24df$HT24 / 100, mt_uct24df$GridMaxHt, col = "blue")
abline(0, 1)
