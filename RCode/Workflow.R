# full workflow
#
# Packages: terra, fusionwrapr (https://github.com/bmcgaughey1/fusionwrapr)
# ***** You must have FUSION installed and configured (see page 61 in FUSION 
#       manual for details about modifying the PATH environment variable).
#
# You may get some warning related to GDAL plugins...they can be ignored
#
# I also ran into some cases where the GetSurfaceValues() function complained
# about not being able to open a temporary file. Not sure what is happening. I
# exited R-Studio, restarted an things ran fine.
#
# the GeospatialData.R file has code to read the files from UC Davis and the GPS
# points from Connie. Not really needed in the data preparation but I did use the 
# UC Davis stem map to check my entries for tag numbers (although it doesn't have
# all trees...no dead or cut trees)
#
# convert ground model to FUSION format
source("Rcode/ConvertDTM.R")

# Build CSM, CHM and tree objects
# check in file for the setting of buildFUSIONProducts...this controls creation of CHMs
source("Rcode/CHMandTrees.R")

# process image bands
source("Rcode/CompositeImages.R")

# map image book
source("Rcode/PlotBook.R")

# geopackage files from US Davis with stem locations...doesn't line up well with lidar
# GeospatialData.R only displays these files...no manipulation
#
# GPS points from Connie...mainly used to check alignment
# only need to run once...maybe not at all
#source("Rcode/GeospatialData.R")

# build stem maps...brute force with hard-coded tree info
source("Rcode/BlockandPlotDiagrams.R")

# refine the alignment of the stem maps
source("Rcode/RefineAlignment.R")

# adjust UC Davis stem map to match grid
source("Rcode/AdjustUCDavisMap.R")

# compare tag labels between grid and UC Davis stem map...does not check border tree tags
# look for Block#Errors.shp files to indicate errors...if not present, no errors detected
# error message is also printed to console
source("Rcode/CompareTage.R")
