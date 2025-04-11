# full workflow
#
# Packages: terra, fusionwrapr (https://github.com/bmcgaughey1/fusionwrapr)
# ***** You must have FUSION installed and configured (see page 61 in FUSION 
#       manual for details about modifying the PATH environment variable
#       and setting environment variable to force use of 64-bit programs).
#
# You may get some warning related to GDAL plugins...they can be ignored
#
# the GeospatialData.R file has code to read the files from UC Davis and the GPS
# points from Connie. Not really needed in the data preparation but I did use the 
# UC Davis stem map to check my entries for tag numbers (although it doesn't have
# all trees...no dead or cut trees). I also had to adjust the alignment of the UC
# Davis points to match my new stem maps.
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
# Connie mentioned that the plot diagram shows the location of these points
# relative to the study area but I think the points are actually near trees
# and not the plot corner (1.8 m west and south of LL corner tree)
#
# only need to run once...maybe not at all
# Jacob confirmed that lat-lon in Connie's file should be EPSG:6318
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
#
# I manually checked border tree tag numbers for error...all good!
source("Rcode/CompareTags.R")

# match lidar-derived trees to stem maps
# ideally, there is a match for each tree from the stem maps and no lidar trees where
# a tree was cut or died. the matching code checks for both conditions and reports
# discrepencies
source("Rcode/MatchTrees.R")

# use file of recent measurements to add heights
source("Rcode/AddMeasurements.R")
