# code to build CHM and do tree segmentation
#
########## You must have FUSION installed and configured (environment variable
########## set for install folder) to use this code!!
#
source("Rcode/FileSystem.R")

library(terra)
library(fusionwrapr)

# UAS-lidar can produce very high resolution CHMs. However, this results
# in too much detail and tree segmentation suffers. From precious projects, I have
# found that 0.5m resolution with a 3by3 moving window average filter works
# well and produces useable tree objects

# set up some things for FUSION commands
outputFolder <- paste0(dataFolder, "FUSIONProcessing/")

# *****************************************************************************
# *****************************************************************************
# build CSM and CHM, do segmentation and compute metrics for Tree Approximate Objects (TAOs)
# *****************************************************************************
# *****************************************************************************
# header things for batch file
batchFile <- paste0(outputFolder, "DoCHMandTrees.bat")

# set default behavior for commands...basically telling the fusionwrapr package to create a
# batch file instead of running the commands directly.
setGlobalCommandOptions(runCmd = FALSE, saveCmd = TRUE, echoCmd = FALSE, cmdFile = batchFile)

# make sure we have the folder for the batch file
verifyFolder(dirname(batchFile))

# write comment...omit the blank line before the comment
addToCommandFile(paste0("Processing for: ", dataFolder), addLine = FALSE, cmdClear = TRUE)

# set the log file and clear it
useLogFile(paste0(outputFolder, "Processing.log"), logClear = TRUE)

# add comment
addToCommandFile("Start of processing commands")

# create ground model...already have these for all areas in ground folder
# however, the naming for the models isn't consistent

# create CSM and CHM
# Resolution and smoothing with the canopy surfaces have a major effect on the segmentation
# behavior.
CanopyModel(paste0(outputFolder, "CSM/CSM.dtm")
            , 0.5
            , "M"
            , "M"
            , 1
            , 10
            , 2
            , 2
            , paste0(lidarDataFolder, "*.laz")
            , smooth = 3
            , peaks = FALSE
            , class = "~7,18"
)

CanopyModel(paste0(outputFolder, "CHM/CHM.dtm")
            , 0.5
            , "M"
            , "M"
            , 1
            , 10
            , 2
            , 2
            , paste0(lidarDataFolder, "*.laz")
            , ground = FUSION_DTMFile
            , smooth = 3
            , peaks = FALSE
            , class = "~7,18"
)

# run segmentation to produce normalized TAO clips
# omit the ground points (class 2)
TreeSeg(paste0(outputFolder, "CHM/CHM.dtm")
        , 2
        , paste0(outputFolder, "Trees/trees_normalized.csv")
        , shape = TRUE
        , ptheight = TRUE
        #, points = paste0(lidarDataFolder, "*.laz")
        , class = "~2"
        , clipfolder = paste0(outputFolder, "Trees/TAOpts_normalized")
        , ground = FUSION_DTMFile
        , comment = "Create normalized TAO point clips"
        , projection = prjFile
)

useLogFile("")

# run the batch file
runCommandFile()

# convert CSM and CHM to TIF format
csm <- readDTM(paste0(outputFolder, "CSM/CSM.dtm"), type = "terra", epsg = 26910)
chm <- readDTM(paste0(outputFolder, "CHM/CHM.dtm"), type = "terra", epsg = 26910)

# options for GDAL TIFF writer
gdalOptions <- c("TFW=YES", "PHOTOMETRIC=RGB")

writeRaster(csm, paste0(outputFolder, "CSM/CSM.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(chm, paste0(outputFolder, "CHM/CHM.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
