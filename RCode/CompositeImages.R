# code to create composite images for Buckhorn drone imagery
#
source("Rcode/FileSystem.R")

library(terra)

# new stretch function...just a wrapper around terra's stretch function that
# uses all cells and defaults to the 99.99 percentile instead of the maximum value
# to scale values from 0-255
stretchq <- function(
    x,
    maxq = 0.9999)
{
  invisible(terra::stretch(x, minq = 0.0, maxq = maxq, maxcell = dim(x)[1] * dim(x[2])))
}

# new stretch function to produce 16-bit values. I left this one so it uses the
# 99.9 percentile but scales from 0-65534 instead of 0-65535. ArcPro seemed to
# be treating values of 65535 as invalid.
stretch16 <- function (
    x,
    maxq = 0.999  # same as maximum value
)
{
  # check for maxq = 1.0...this is the maximum and it may be faster to compute
  # the maximum directly
  if (maxq == 1.0) {
    q <- terra::global(x, max, na.rm = TRUE)
  } else {
    # compute the quantile
    q <- terra::global(x, quantile, na.rm = TRUE, probs = c(maxq))
  }
  # q is a data frame so you have to add the subscripts to get the numeric value
  
  # truncate values to the target quantile value
  x <- terra::ifel(x > q[1,1], q[1,1], x)
  
  # do the linear stretch
  x <- x / q[1,1] * 65534
}

# alpha is used for some of the composite images defined in:
# Xie, Qiaoyun & Dash, Jadu & Huang, Wenjiang & Peng, Dailiang & Qin, Qiming &
# Mortimer, Hugh & Casa, Raffaele & Pignatti, Stefano & Laneve, Giovanni &
# Pascucci, Simone & Dong, Yingying & Ye, Huichun. (2018). Vegetation Indices
# Combining the Red and Red-Edge Spectral Information for Leaf Area Index
# Retrieval. IEEE Journal of Selected Topics in Applied Earth Observations and
# Remote Sensing. 11. 10.1109/JSTARS.2018.2813281.  
alpha <- 0.4

checkForFiles <- TRUE

# options for GDAL TIFF writer
gdalOptions <- c("TFW=YES", "PHOTOMETRIC=RGB")

# bitsPerPixel can be either 8 or 16. If 16, images won't read into FUSION
bitsPerPixel <- 8

dataType = "INT2U"
if (bitsPerPixel == 8)
  dataType = "INT1U"

# check to see if we already have the image set...only checks for a single file 
# and assumes other files are there (or not) if the one is there (or not)
if (checkForFiles) {
  if (file.exists(paste0(imageDataFolder, imageFileBasename, bandNames[1], ".tif")))
    stop("Images already exist!!")
}
  
imageFile <- paste0(imageDataFolder, imageFileBasename, bandNames[1], ".tif")
red <- rast(imageFile)
if (bitsPerPixel == 8) red <- stretchq(red) else red <- stretch16(red)

imageFile <- paste0(imageDataFolder, imageFileBasename, bandNames[2], ".tif")
green <- rast(imageFile)
if (bitsPerPixel == 8) green <- stretchq(green) else green <- stretch16(green)

imageFile <- paste0(imageDataFolder, imageFileBasename, bandNames[3], ".tif")
blue <- rast(imageFile)
if (bitsPerPixel == 8) blue <- stretchq(blue) else blue <- stretch16(blue)

imageFile <- paste0(imageDataFolder, imageFileBasename, bandNames[4], ".tif")
nir <- rast(imageFile)
if (bitsPerPixel == 8) nir <- stretchq(nir) else nir <- stretch16(nir)

imageFile <- paste0(imageDataFolder, imageFileBasename, bandNames[5], ".tif")
rededge <- rast(imageFile)
if (bitsPerPixel == 8) rededge <- stretchq(rededge) else rededge <- stretch16(rededge)

imageFile <- paste0(imageDataFolder, imageFileBasename, bandNames[6], ".tif")
panchro <- rast(imageFile)
if (bitsPerPixel == 8) panchro <- stretchq(panchro) else panchro <- stretch16(panchro)

imageFile <- paste0(imageDataFolder, imageFileBasename, bandNames[7], ".tif")
lwir <- rast(imageFile)
if (bitsPerPixel == 8) lwir <- stretchq(lwir) else lwir <- stretch16(lwir)

# use terra::shift to align imagery with lidar data. amount of shift determined by manual
# measurement in ArcPro for 4 corners of study area. this could be refined!!
#
# ****** Turns out the problem causing the apparent misalignment was an incorrect
#        assumption regarding CRS for data...seet dx and xy to 0
#dx <- -1.115
#dy <- 0.75
dx <- 0
dy <- 0
if (dx != 0 && dy != 0) {
  red <- shift(red, dx = dx, dy = dy)
  green <- shift(green, dx = dx, dy = dy)
  blue <- shift(blue, dx = dx, dy = dy)
  nir <- shift(nir, dx = dx, dy = dy)
  rededge <- shift(rededge, dx = dx, dy = dy)
  panchro <- shift(panchro, dx = dx, dy = dy)
  lwir <- shift(lwir, dx = dx, dy = dy)
}


#Xie, Qiaoyun & Dash, Jadu & Huang, Wenjiang & Peng, Dailiang & Qin, Qiming &
#Mortimer, Hugh & Casa, Raffaele & Pignatti, Stefano & Laneve, Giovanni &
#Pascucci, Simone & Dong, Yingying & Ye, Huichun. (2018). Vegetation Indices
#Combining the Red and Red-Edge Spectral Information for Leaf Area Index
#Retrieval. IEEE Journal of Selected Topics in Applied Earth Observations and
#Remote Sensing. 11. 10.1109/JSTARS.2018.2813281.  
rgb <- rast(list(red, green, blue))
fcnir <- rast(list(nir, red, green))
fcrededge <- rast(list(rededge, red, green))
nvdinir <- (nir - red) / (nir + red)
nvdirededge <- (nir - rededge) / (nir + rededge)
msr <- ((nir / red) - 1) / sqrt((nir / red) + 1)
msrrededge <- ((nir / rededge) - 1) / sqrt((nir / rededge) + 1)
cigreen <- nir / green -1
cirededge <- nir / rededge - 1
nvdiredrededge <- (nir - (alpha * red + (1 - alpha) * rededge)) / (nir + (alpha * red + (1 - alpha) * rededge))
msrredrededge <- (nir / (alpha * red + (1 - alpha) * rededge) - 1) / sqrt(nir / (alpha * red + (1 - alpha) * rededge) + 1)
ciredrededge <- nir / (alpha * red + (1 - alpha) * rededge) - 1

# extra combinations
nir_re_g <- rast(list(nir, rededge, green))

#nvdinir <- stretch(nvdinir)
#nvdirededge <- stretch(nvdirededge)

# create folder for output images
dir.create(imageOutputFolder, showWarnings = FALSE)

# we need a world file to use these images with FUSION (not any more!!...GeoTIFF is recognized). This is done using the gdal options. You can use
# WORLDFILE=YES but the file extension will be .wld which FUSION won't recognize. TFW=YES produces a world file
# with .tfw extension which FUSION will recognize and use.
#
# write off composite images
writeRaster(fcnir, paste0(imageOutputFolder, imageFileBasename, "NIR.tif"), gdal = gdalOptions, datatype = dataType, overwrite = TRUE)
writeRaster(fcrededge, paste0(imageOutputFolder, imageFileBasename, "rededge.tif"), gdal = gdalOptions, datatype = dataType, overwrite = TRUE)
writeRaster(rgb, paste0(imageOutputFolder, imageFileBasename, "RGB.tif"), gdal = gdalOptions, datatype = dataType, overwrite = TRUE)
writeRaster(nvdirededge, paste0(imageOutputFolder, imageFileBasename, "nvdirededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(nvdinir, paste0(imageOutputFolder, imageFileBasename, "nvdinir.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(msr, paste0(imageOutputFolder, imageFileBasename, "msr.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(msrrededge, paste0(imageOutputFolder, imageFileBasename, "msrrededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(cigreen, paste0(imageOutputFolder, imageFileBasename, "cigreen.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(cirededge, paste0(imageOutputFolder, imageFileBasename, "cirededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(nvdiredrededge, paste0(imageOutputFolder, imageFileBasename, "nvdiredrededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(msrredrededge, paste0(imageOutputFolder, imageFileBasename, "msrredrededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(ciredrededge, paste0(imageOutputFolder, imageFileBasename, "ciredrededge.tif"), gdal = gdalOptions, datatype = "FLT4S", overwrite = TRUE)
writeRaster(panchro, paste0(imageOutputFolder, imageFileBasename, "panchro.tif"), gdal = gdalOptions, datatype = dataType, overwrite = TRUE)

writeRaster(nir_re_g, paste0(imageOutputFolder, imageFileBasename, "nir_re_g.tif"), gdal = gdalOptions, datatype = dataType, overwrite = TRUE)

#writeRaster(fcnir, paste0(imageOutputFolder, imageFileBasename, "NIR.bmp"), gdal = "WORLDFILE=YES", datatype = "INT1U", overwrite = TRUE)
