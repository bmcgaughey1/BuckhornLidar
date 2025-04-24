# full workflow
#
# Packages: terra, fusionwrapr (https://github.com/bmcgaughey1/fusionwrapr)
# ***** You must have FUSION installed and configured (see page 61 in FUSION 
#       manual for details about modifying the PATH environment variable
#       and setting environment variable to force use of 64-bit programs).
#       You also need the laszip dlls from LAStools copied into the 
#       FUSION install folder to read/write LAZ files.
#
# You may get some warning related to GDAL plugins...they can be ignored
#
# the GeospatialData.R file has code to read the files from UC Davis and the GPS
# points from Connie. Not really needed in the data preparation but I did use the 
# UC Davis stem map to check my entries for tag numbers (although it doesn't have
# all trees...no dead or cut trees). I also had to adjust the alignment of the UC
# Davis points to match my new stem maps.
#
# The simplest way to get tree heights is to take the perfect grid of trees and 
# get the unsmoothed CHM height using a small neighborhood around the tree locations.
# This works for single leaders/tops but not trees with multiple tops. Alternatively, 
# you can clip a small circle of lidar points and get the height of the highest point.
# Both methods are accomplished by the SimpleMeasurements.R code. 
# ****** The point clipping is slow taking 6-7 hours to run for all blocks.
#
# The approach I originally started was to match lidar-derived tree tops to the
# perfect grid of trees (after adjusting the grid to get the best match with the
# lidar-derived trees). This is a good approach but won't necessarily get matches 
# for all grid trees as there are more lidar-derived trees than grid trees due to 
# oversegmentation. I "tuned" the CHM parameters to reduce oversegmentation but
# you still don't get a one-to-one match. We also have some trees with double
# leaders. Some are captured in the lidar trees but not many. This is likely due
# to the closeness of the two tops and might be improved with more work to refine
# the CHM.
#

# convert ground model to FUSION format
source("Rcode/ConvertDTM.R")

# Build CSM, CHM and tree objects
# check in file for the setting of buildFUSIONProducts...this controls creation of CHMs
# this is the code that uses the lidar point cloud
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
# Jacob Strunk confirmed that lat-lon in Connie's file should be EPSG:6318
#source("Rcode/GeospatialData.R")

# build stem maps...brute force with hard-coded tree info
source("Rcode/BlockandPlotDiagrams.R")

# refine the alignment of the stem maps
source("Rcode/RefineAlignment.R")

# adjust UC Davis stem map to match grid
source("Rcode/AdjustUCDavisMap.R")

# !@#$%^&*()
# merge grid trees with measurement file to get all measurements in one place
# measurement file should be the same trees as UCD stem map but this needs checked
# measurement file: SupportingData/Buckhorn21_multipletops.csv
#
# ***** problem is that the UCD trees don't have any STEM=b records
# also noticed that the STEM column in UCD gpkg file has a leading space in some
# records...also has one record with " d" in STEM column











# compare tag labels between grid and UC Davis stem map...does not check border tree tags
# look for Block#Errors.shp files to indicate errors...if not present, no errors detected
# error message is also printed to console
#
# I manually checked border tree tag numbers for error...all good!
#
# This code shouldn't be needed again unless something changes in CHMandTrees.R.
#source("Rcode/CompareTags.R")

# produce "simple" measurements using the CHM and point cloud along with the 
# adjusted tree grid. No matching with lidar-derived trees.
#
# check in the code for the setting of doHighPoints and useShiftedTrees to control
# whether point clipping to get high point heights is performed and the use of the 
# shifted grid of trees (shifted to better match lidar-derived trees).
source("Rcode/SimpleMeasurements.R")

# match lidar-derived trees to stem maps
# ideally, there is a match for each tree from the stem maps and no lidar trees where
# a tree was cut or died. the matching code checks for both conditions and reports
# discrepencies
source("Rcode/MatchTrees.R")

# use file of recent measurements to add heights and produce final CSV files
# these files only have trees with recent measurements that were matched to lidar trees
source("Rcode/AddMeasurements.R")

# merge measurement files for each block into single files
source("Rcode/MergeMeasurements.R")
