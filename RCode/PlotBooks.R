# code to produce a "book" of plot images. The book is placed in the base data folder
#
source("Rcode/FileSystem.R")

library(terra)
library(fusionwrapr)

# set checkForFiles to FALSE to force creation of image book
checkForFiles <- FALSE
doHillshade <- TRUE

bookFileName <- paste0(dataFolder, "Buckhorn_Imagery.pdf")
  
# check to see if we already have the images...needed since a single images covers multiple plots
if (checkForFiles) {
  if (file.exists(bookFileName))
    stop("Image book already exists!")
}

# read composite images and grayscale
rgb <- rast(paste0(imageOutputFolder, imageFileBasename, "RGB.tif"))
fcnir <- rast(paste0(imageOutputFolder, imageFileBasename, "NIR.tif"))
fcrededge <- rast(paste0(imageOutputFolder, imageFileBasename, "rededge.tif"))
nvdirededge <- rast(paste0(imageOutputFolder, imageFileBasename, "nvdirededge.tif"))
nvdinir <- rast(paste0(imageOutputFolder, imageFileBasename, "nvdinir.tif"))
msr <- rast(paste0(imageOutputFolder, imageFileBasename, "msr.tif"))
msrrededge <- rast(paste0(imageOutputFolder, imageFileBasename, "msrrededge.tif"))
cigreen <- rast(paste0(imageOutputFolder, imageFileBasename, "cigreen.tif"))
cirededge <- rast(paste0(imageOutputFolder, imageFileBasename, "cirededge.tif"))
nvdiredrededge <- rast(paste0(imageOutputFolder, imageFileBasename, "nvdiredrededge.tif"))
msrredrededge <- rast(paste0(imageOutputFolder, imageFileBasename, "msrredrededge.tif"))
ciredrededge <- rast(paste0(imageOutputFolder, imageFileBasename, "ciredrededge.tif"))
nir_re_g <- rast(paste0(imageOutputFolder, imageFileBasename, "nir_re_g.tif"))
panchro <- rast(paste0(imageOutputFolder, imageFileBasename, "panchro.tif"))

# get image extent to clip DTM since DTM may cover slightly different area than images
e <- ext(panchro)
  
if (doHillshade) {
  DTM <- readDTM(FUSION_DTMFile, type = "terra", epsg = 26910)
  DTM <- crop(DTM, e)
  
  # do hillshade using multiple angles
  alt <- disagg(DTM, 10, method="bilinear")
  slope <- terrain(alt, "slope", unit="radians")
  aspect <- terrain(alt, "aspect", unit="radians")
  hdtm <- shade(slope, aspect, angle = c(45, 45, 45, 80), direction = c(315, 0, 45, 135))
  hdtm <- Reduce(mean, hdtm)

  CHM <- readDTM(paste0(dataFolder, "FUSIONProcessing/CHM/CHM.dtm"), type = "terra", epsg = 26910)
  CHM <- crop(CHM, e)
  
  # do hillshade using multiple angles
  alt <- disagg(CHM, 10, method="bilinear")
  slope <- terrain(alt, "slope", unit="radians")
  aspect <- terrain(alt, "aspect", unit="radians")
  hchm <- shade(slope, aspect, angle = c(45, 45, 45, 80), direction = c(315, 0, 45, 135))
  hchm <- Reduce(mean, hchm)
}
  
margins <- c(2, 4, 2, 6)

# if dimensions of the area are wider than they are tall, legend is clipped off
pdf(bookFileName)
if (doHillshade) {
  plot(hdtm, col=grey(0:100/100), legend=FALSE, mar=c(2,2,2,4), main = "Ground Surface Hillshade")
  plot(hchm, col=grey(0:100/100), legend=FALSE, mar=c(2,2,2,4), main = "Canopy Height Hillshade")
}

#  l <- global(panchro, quantile, na.rm = TRUE, probs = c(0.01))
#  h <- global(panchro, quantile, na.rm = TRUE, probs = c(0.99))
#  plot(panchro, range = c(l[[1]], h[[1]]), col = grDevices::gray.colors(255), legend = FALSE, axes = FALSE, mar = c(0, 0, 2, 0), main = "panchromatic")
plot(panchro, col = grDevices::gray.colors(255), legend = FALSE, axes = TRUE, mar = margins, main = "panchromatic")

plotRGB(rgb, mar = margins, axes = TRUE, main = "RGB")
plotRGB(fcnir, mar = margins, axes = TRUE, main = "False color NIR")
plotRGB(fcrededge, mar = margins, axes = TRUE, main = "False color rededge")

l <- global(nvdinir, quantile, na.rm = TRUE, probs = c(0.01))
h <- global(nvdinir, quantile, na.rm = TRUE, probs = c(0.99))
plot(nvdinir, range = c(l[[1]], h[[1]]), mar = margins, main = "NIR NVDI")

l <- global(nvdirededge, quantile, na.rm = TRUE, probs = c(0.01))
h <- global(nvdirededge, quantile, na.rm = TRUE, probs = c(0.99))
plot(nvdirededge, range = c(l[[1]], h[[1]]), mar = margins, main = "rededge NVDI")

l <- global(msr, quantile, na.rm = TRUE, probs = c(0.01))
h <- global(msr, quantile, na.rm = TRUE, probs = c(0.99))
plot(msr, range = c(l[[1]], h[[1]]), mar = margins, main = "MSR")

l <- global(msrrededge, quantile, na.rm = TRUE, probs = c(0.01))
h <- global(msrrededge, quantile, na.rm = TRUE, probs = c(0.99))
plot(msrrededge, range = c(l[[1]], h[[1]]), mar = margins, main = "rededge MSR")

l <- global(cigreen, quantile, na.rm = TRUE, probs = c(0.01))
h <- global(cigreen, quantile, na.rm = TRUE, probs = c(0.99))
plot(cigreen, range = c(l[[1]], h[[1]]), mar = margins, main = "green CI")

l <- global(cigreen, quantile, na.rm = TRUE, probs = c(0.01))
h <- global(cigreen, quantile, na.rm = TRUE, probs = c(0.99))
plot(cirededge, range = c(l[[1]], h[[1]]), mar = margins, main = "rededge CI")

l <- global(nvdiredrededge, quantile, na.rm = TRUE, probs = c(0.01))
h <- global(nvdiredrededge, quantile, na.rm = TRUE, probs = c(0.99))
plot(nvdiredrededge, range = c(l[[1]], h[[1]]), mar = margins, main = "red and rededge NVDI")

l <- global(msrredrededge, quantile, na.rm = TRUE, probs = c(0.01))
h <- global(msrredrededge, quantile, na.rm = TRUE, probs = c(0.99))
plot(msrredrededge, range = c(l[[1]], h[[1]]), mar = margins, main = "red and rededge MSR")

l <- global(ciredrededge, quantile, na.rm = TRUE, probs = c(0.01))
h <- global(ciredrededge, quantile, na.rm = TRUE, probs = c(0.99))
plot(ciredrededge, range = c(l[[1]], h[[1]]), mar = margins, main = "red and rededge modified CI")

plotRGB(nir_re_g, mar = margins, axes = TRUE, main = "False color NIR-rededge-green")
dev.off()
