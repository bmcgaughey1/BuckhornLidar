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

# flag to control building of CSM, CHM, and tree objects
buildFUSIONProducts <- TRUE

if (buildFUSIONProducts) {
  # Do FUSION processing ----------------------------------------------------
  
  # build CSM and CHM, do segmentation
  
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
  
  # create an unsmoothe3d CHM. This will be used to assign elevations to trees
  # after segmentation. Smoothing reduces the height of the CHM slightly but smoothing
  # is necessary to prevent oversegmentation.
  CanopyModel(paste0(outputFolder, "CHM/CHM_NOT_smoothed.dtm")
              , 0.5
              , "M"
              , "M"
              , 1
              , 10
              , 2
              , 2
              , paste0(lidarDataFolder, "*.laz")
              , ground = FUSION_DTMFile
              , peaks = FALSE
              , class = "~7,18"
  )
  
  # run segmentation to produce normalized TAO clips
  # omit the ground points (class 2)
  # remove the points = ... line to just produce highpoints and crown polygons
  TreeSeg(paste0(outputFolder, "CHM/CHM.dtm")
          , 2
          , paste0(outputFolder, "Trees/trees_normalized.csv")
          , shape = TRUE
          , ptheight = TRUE
          , points = paste0(lidarDataFolder, "*.laz")
          , class = "~2"
          , clipfolder = paste0(outputFolder, "Trees/TAOpts_normalized")
          , ground = FUSION_DTMFile
          , comment = "Create normalized TAO point clips"
          , projection = prjFile
  )
  
  # compute limited set of metrics for both sets of TAOs
  # remove highpoint = TRUE and uncomment minht = and above = lines to produce full set of metrics
  # use rid=TRUE to parse tree number from end of point file name
  CloudMetrics(paste0(outputFolder, "/Trees/TAOpts_normalized/*.lda")
               , paste0(outputFolder, "/TAO_normalized_metrics.csv")
               , new = TRUE
               , highpoint = TRUE
               #, minht = 2.0
               #, above = 2.0
               , rid = TRUE
  )
  
  useLogFile("")
  
  # run the batch file
  runCommandFile()
}

# reset FUSION command environment so commands are run immediately
setGlobalCommandOptions(runCmd = TRUE)

# Sample heights for highpoints from unsmoothed CHM and tree clips ------------

# Heights for trees from the segmentation are slightly reduced due to smoothing
# the CHM. Use the XY location of the high point and an unsmoothed CHM to assign
# more accurate heights.
#
# An alternative approach that would produce the most accurate heights is to clip 
# points for each tree and get the height for the highest lidar point for each tree.
# This process is slow and requires more manipulation of the point clips.
#
# read shapefile for highpoints
highPoints <- vect(paste0(outputFolder, "Trees/trees_normalized_HighPoints.shp"))

# build data frame for ID, X, Y and "fix" the column labels
df <- data.frame(highPoints$BasinID, highPoints$GridHighX, highPoints$GridHighY)
colnames(df) <- c("BasinID", "X", "Y")

# get surface values for highpoint XY locations
dfns <- GetSurfaceValues(df, "X", "Y", "UnsmthHt", paste0(outputFolder, "CHM/CHM_NOT_smoothed.dtm"))

# read point cloud metrics
metrics <- read.csv(paste0(outputFolder, "/TAO_normalized_metrics.csv"), stringsAsFactors = FALSE)

# join point cloud highest point height to segmented trees. Join is needed because
# we typically don't get points for every tree object
dfns <- merge(dfns, metrics, by.x = "BasinID", by.y = "Identifier", all.x = TRUE)

# add UnsmthHt to shapefile attributes
# add point location and height to shapefile
highPoints$UnsmthHt <- dfns$UnsmthHt
highPoints$HighPtX <- dfns$High.point.X
highPoints$HighPtY <- dfns$High.point.Y
highPoints$HighPtHt <- dfns$High.point.elevation

# strip off original geometry (grid cell centers) and replace locations with high point XY
# this won't shift tree locations by much...at most the width of CHM cell (0.5m)
df <- as.data.frame(highPoints)
highPoints <- vect(df, geom = c("HighPtX", "HighPtY"), crs = crs(highPoints), keepgeom = TRUE)

# write new shapefile for high points
writeVector(highPoints, paste0(outputFolder, "Trees/trees.shp"), overwrite = TRUE)

# read shapefile for crown perimeters
crowns <- vect(paste0(outputFolder, "Trees/trees_normalized_Polygons.shp"))
crowns$UnsmthHt <- dfns$UnsmthHt
crowns$HighPtX <- dfns$High.point.X
crowns$HighPtY <- dfns$High.point.Y
crowns$HighPtHt <- dfns$High.point.elevation

# write new shapefile for crown perimeters
writeVector(crowns, paste0(outputFolder, "Trees/crowns.shp"), overwrite = TRUE)

# Convert surface files to TIF format -------------------------------------

# convert CSM and CHMs to TIF format
csm <- readDTM(paste0(outputFolder, "CSM/CSM.dtm"), type = "terra", epsg = 32610)
chm <- readDTM(paste0(outputFolder, "CHM/CHM.dtm"), type = "terra", epsg = 32610)
chmns <- readDTM(paste0(outputFolder, "CHM/CHM_NOT_smoothed.dtm"), type = "terra", epsg = 32610)

# options for GDAL TIFF writer
gdalOptions <- c("TFW=YES", "PHOTOMETRIC=RGB")

# write models to TIF using floating point values
writeRaster(csm, paste0(outputFolder, "CSM/CSM.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(chm, paste0(outputFolder, "CHM/CHM.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(chmns, paste0(outputFolder, "CHM/CHM_NOT_smoothed.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
