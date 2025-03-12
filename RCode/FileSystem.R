# code to set paths and filenames
#
# This structure is for the updated imagery processed with MetaShape
# delivered 01/24/2024. The lidar data are stored in a different file structure.
#
# I moved all of the OESF and ONF folders into a single folder just to make
# things a bit easier
#
# folder names and drive letters are specific to my computer. Most necessary changes
# will be handled by changing dataFolder. However, the DTM conversion logic has
# full file names so they will need to be changed as well.
#
# I made some corrections to file names...see notes.txt in extras. There
# are also some inconsistencies in the folder structure for plot_8_9_14 with
# separate folders for Plot_8_9 and Plot_14.
#
dataFolder <- "H:/Buckhorn2/Buckhorn2_Finals/"
lidarDataFolder <- paste0(dataFolder, "LiDAR/")
imageDataFolder <- paste0(dataFolder, "multiband_imagery/reflectance/")

imageFileBasename <- "Buckhorn2_reflectance_"

imageOutputFolder <- paste0(dataFolder, "CompositeImages/")

# these are the names used to identify the bands. The file names for the bands are formed
# using the imageFileBaseName + bandNames[n] + ".tif"
bandNames <- c(
    "red_band4"
  , "green_band2"
  , "blue_band1"
  , "nir_band6"
  , "rededge_band5"
  , "panchro_band3"
  , "lwir_band7"
)

DTMFile <- paste0(lidarDataFolder, "Buckhorn2_DTM.tif")
FUSION_DTMFile <- paste0(dataFolder, "ground/buckhorn2.dtm")

prjFile <- paste0(dataFolder, "UTM10.prj")

