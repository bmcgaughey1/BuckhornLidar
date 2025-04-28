# code to add new measurements to tree records...not for all trees
#
source("Rcode/FileSystem.R")
library(terra)

# set up some things for FUSION commands
inputFolder <- paste0(dataFolder, "StemMaps/")
outputFolder <- paste0(dataFolder, "FINALData/")

# make sure output folder exists
if (!dir.exists(outputFolder)) {dir.create(outputFolder)}

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
#blockNum <- 2
for (blockNum in 1:4) {
  # read matched trees...no measurements
  mt <- vect(paste0(inputFolder, "MatchedBlock", blockNum, "Trees.shp"))
  
  # read shifted UCDavis trees...have older measurements
  #uct <- vect(paste0(inputFolder, "ShiftedUCD", blockNum, "Trees.shp"))
  
  # join UCDavis measurements to matched lidar trees...
  # all.x = TRUE keeps rows in mt that aren't in uct
  #
  # merging drops columns used for merge in y
  #mt_uct <- merge(mt, uct, by.x = "Tag", by.y = "TAG", all.x = TRUE)
  #mt_uctdf <- as.data.frame(mt_uct)
  #colnames(mt_uctdf)

  # mt_uct24 has the matched trees with 2024 measurements...no others
  mt_uct24 <- merge(mt, newMeasurements, by.x = c("Tag"), by.y = c("TAG"), all.x = TRUE)
  mt_uct24df <- as.data.frame(mt_uct24)
  #colnames(mt_uct24df)
  
  # rows are duplicated in mt_uct24 when there are measurements for stem a and b in the newMeasurements
  
  # not all blocks have stems with new measurements
  if (nrow(mt_uct24)) {
    # clean up columns...brute force
    # mt_uct24df <- mt_uct24df[, c(25, 1:16, 19:24, 29:46, 54:59)]
    mt_uct24df <- mt_uct24df[, c(12, 2, 3, 1, 13, 4:11, 14:33, 36:41, 47, 49:52)]
    #colnames(mt_uct24df)
    colnames(mt_uct24df) <- c(
      "SITE", "Block", "Plot", "Tag", "STEM", "Row", "Col", "Live", "Border", "Filler",
      "Extra", "X", "Y", "PBD","BD21", "PDBH", "DBH21", "PHT", "HT21", "FL21", "PCWA", "CWA21", "PCWB",
      "CWB21", "PCODE", "CODE21", "PCOMM", "COMM21", 
      "BasinID", "GridHighX", "GridHighY", "GridCells", "GridMaxHt",
      "UnsmthHt", "HighPtX", "HighPtY", "HighPtHt", "dist", "confidence", "DBH24", 
      "HT23", "HT24", "HTLC24", "COMMENT"
    )
    
    # # clean up columns in full match dataset...should have done this before second merge
    # mt_uctdf <- mt_uctdf[, c(25, 1:16, 19:24, 29:46)]
    # #colnames(mt_uctdf)
    # colnames(mt_uctdf) <- c(
    #   "SITE", "Tag", "Block", "Plot", "Row", "Col", "BD21", "PDBH", "DBH21", "PHT", "HT21", "FL21", "PCWA", "CWA21", "PCWB","Live", "Border", "Filler",
    #   "Extra", "X", "Y", "BasinID", "GridHighX", "GridHighY", "GridCells", "GridMaxHt",
    #   "UnsmthHt", "HighPtX", "HighPtY", "HighPtHt", "dist", "confidence", "STEM", "PBD",
    #   
    #   "CWB21", "PCODE", "CODE21", "PCOMM", "COMM21", "X_Long", "Y_Lat"
    # )
    
    # write merged data
    write.csv(mt_uct24df, paste0(outputFolder, "FINAL_Merged_Block", blockNum, "_Trees.csv"), row.names = F)
    
    # need to clean up the columns in the vector files
    #names(mt_uct24)
    #names(mt_uct)
    mt_uct24 <- mt_uct24[, c(12, 2, 3, 1, 13, 4:11, 14:33, 36:41, 47, 49:52)]
    #mt_uct24 <- mt_uct24[, c(25, 1:16, 19:24, 29:46, 54:59)]
    names(mt_uct24) <- c(
      "SITE", "Block", "Plot", "Tag", "STEM", "Row", "Col", "Live", "Border", "Filler",
      "Extra", "X", "Y", "PBD","BD21", "PDBH", "DBH21", "PHT", "HT21", "FL21", "PCWA", "CWA21", "PCWB",
      "CWB21", "PCODE", "CODE21", "PCOMM", "COMM21", 
      "BasinID", "GridHighX", "GridHighY", "GridCells", "GridMaxHt",
      "UnsmthHt", "HighPtX", "HighPtY", "HighPtHt", "dist", "confidence", "DBH24", 
      "HT23", "HT24", "HTLC24", "COMMENT"
    )

    # write merged points
    writeVector(mt_uct24, paste0(outputFolder, "FINAL_Merged_Block", blockNum, "_Trees.shp"), overwrite = T)
  }
}

# 
# t <- mt_uct24df$HT24 / 100 - mt_uct24df$HighPtHt
# plot(mt_uct24df$HT24 / 100, mt_uct24df$HighPtHt)
# points(mt_uct24df$HT24 / 100, mt_uct24df$UnsmthHt, col = "red")
# points(mt_uct24df$HT24 / 100, mt_uct24df$GridMaxHt, col = "blue")
# abline(0, 1)
