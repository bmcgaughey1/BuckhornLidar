# code to generate theoretical stem pattern for blocks
#
library(terra)

souce("Rcode/FileSystem.R")

# planting patterns for blocks are a 12 column by 26 row grid
# spacing was 3.6m
# each plot had 5 "extra" trees but most were cut several years ago

columns <- 12
rows <- 26
spacing <- 3.6

# generate block rectangle
block = data.frame(X = c(0, (columns + 1) * spacing, (columns + 1) * spacing, 0, 0),
                   Y = c(0, 0, (rows + 1) * spacing, (rows + 1) * spacing, 0))

blkpts <- vect(block, geom=c("X", "Y"), crs = "EPSG:26910", keepgeom = TRUE)
blk <- vect(geom(blkpts), type = "polygons")
writeVector(blk, paste0(outputFolder, "Block1Perimeter.shp"), overwrite = TRUE)

pts <- data.frame()
for (row in 1:rows) {
  for (col in 1:columns) {
    X <- col * spacing + spacing / 2
    Y <- row * spacing + spacing / 2
    pts <- rbind(pts, data.frame(X = X, Y = Y))
  }
}

# block 1
pts$Family <- "11111"
pts$Family[1:12] <- c("10199","2949","10190","10197","10191","10192","11343","11340","11341","11345","11348","11349")
pts$Family[13:24] <- c("10198","7709","2855","3186","7823","3096","7003","6980","2023","556","353","11344")
pts$Family[25:36] <- c("10193","7624","2872","2908","7880","7555","5533","6844","2273","2328","398","11347")
pts$Family[37:48] <- c("10194","2998","3017","7749","7593","7802","7098","7064","5323","2208","523","11346")
pts$Family[49:60] <- c("10196","7681","2153","2076","2343","7522","5354","5477","6801","2307","2086","11342")
pts$Family[61:72] <- c("32700","3865","8684","8475","8513","8545","6486","8904","7249","7199","7275","4449")
pts$Family[73:84] <- c("32688","8549","4048","4010","8633","8622","4337","9006","6441","8936","7320","11582")
pts$Family[85:96] <- c("32686","4102","8665","3784","3794","3824","2479","1669","2601","2503","8973","4366")
pts$Family[97:108] <- c("32687","3969","4085","31799","3899","3941","4370","2558","4321","1707","4421","11581")
pts$Family[109:120] <- c("11532","886","1959","5978","1923","847","2140","4704","5402","4750","5282","11283")
pts$Family[121:132] <- c("11534","952","1033","2015","841","138","6939","318","9150","427","9302","11284")
pts$Family[133:144] <- c("11533","5880","6742","5963","5121","5921","9250","2161","6906","4565","5250","11285")
pts$Family[145:156] <- c("963","6782","6700","5090","5847","5800","246","4532","9093","2142","5438","11282")
pts$Family[157:168] <- c("11441","6658","6175","6295","1284","1488","3682","3658","3706","4259","3636","11208")
pts$Family[169:180] <- c("11442","6234","6339","1502","1296","6644","9210","4218","4151","4612","4188","11207")
pts$Family[181:192] <- c("32315","6142","1320","1554","1528","6612","8410","8367","8865","8753","4672","11699")
pts$Family[193:204] <- c("11445","11443","6263","1393","1433","1835","8272","8316","8775","8815","9167","11695")
pts$Family[205:216] <- c("11648","6635","1594","692","714","588","7992","8093","8189","8067","8163","32054")
pts$Family[217:228] <- c("11645","7134","5629","1623","2362","657","7916","8043","8226","7971","8182","11160")
pts$Family[229:240] <- c("33091","5606","7168","5705","620","2424","3585","3315","3228","3555","3347","32051")
pts$Family[241:252] <- c("11647","5566","6633","6421","5643","6355","3390","3487","3271","3483","3442","32058")
pts$Family[253:264] <- c("11485","2693","7497","4506","4794","2648","204","782","1108","24","181","11388")
pts$Family[265:276] <- c("11487","7430","2747","1773","4475","1759","1242","805","1194","6079","5174","11391")
pts$Family[277:288] <- c("11493","6585","6534","7395","7368","9315","1138","66","6044","5034","5764","11393")
pts$Family[289:300] <- c("11484","7461","9037","9363","4841","2769","5732","5052","6086","6008","5210","11394")
pts$Family[301:312] <- c("11489","11488","11486","11490","9382","11492","11389","11395","831","5788","11392","11390")
trees <- vect(pts, geom = c("X", "Y"), crs = "EPSG:26910", keepgeom = TRUE)

# align by trial and error
# *** may want to spin around 1.8,1.8 and not 0,0
trees <- spin(trees, 19.28, 0, 0)
ox <- 500720 - 1.7
oy = 5154778 - 1
trees <- shift(trees, dx = ox, dy = oy)
writeVector(trees, paste0(outputFolder, "Block1Trees.shp"), overwrite = TRUE)
plot(trees)
