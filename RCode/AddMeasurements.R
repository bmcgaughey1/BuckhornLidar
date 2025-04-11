# code to add new measurements to tree records...not for all trees
#
source("Rcode/FileSystem.R")

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
