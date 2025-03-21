# code to generate theoretical stem pattern for blocks
#
library(terra)

source("Rcode/FileSystem.R")

# set up some things...
outputFolder <- paste0(dataFolder, "StemMaps/")

# planting patterns for blocks are a 12 column by 26 row grid
# spacing was 3.6m
# each plot had 5 "extra" trees but most were cut several years ago
# 
# Code below is a brute force solution.
#
# The file from USDavis has the tag numbers but it doesn't align with the lidar
# trees. I thought this might have been a coordinate projection difference but
# both datasets (UCDavis and WestFork lidar and imagery) use the same projection.
# In the RefineAlignment.R code, I move the UCDavis trees to match the lidar-derived 
# trees and compare tag numbers.
#
# I thought about warping the grid of trees by computing an affine
# transformation using corner points/trees (maybe others as well) but don't
# think this is the best approach since it would distort the grid. IMO, It is
# best to keep the "perfect" grid (with additions) and relax the matching radius
# when assigning tree attributes to the lidar-derived tree locations.
#
# Also want to fine tune the CHM and segmentation using the stem maps as truth.
# I suspect I can tune things so we find all trees (best case) or almost all trees
# (acceptable case).
#
# Basic idea is to build a perfect stem map, then adjust the origin and rotation 
# to best match the lidar-derived treetop locations. A key part of this is that the 
# origin of each block is the tree in the lower left corner. This is moved to the
# tree location detected in the lidar CHM and then rotation is applied using an
# angle measured in ArcPro using Measure-Direction-Distance (gives azimuth). I measured
# the angle (azimuth) along the columns of trees (picked a column of dots representing 
# lidar-derived trees that looked straight).
#
columns <- 12
rows <- 26
spacing <- 3.6

# set the block number (1-4)...loop to do all 4 blocks
for (blockNum in 1:4) {
  #blockNum <- 4

  pts <- data.frame()
  for (row in 1:rows) {
    for (col in 1:columns) {
      X <- (col - 1) * spacing # + spacing / 2
      Y <- (row - 1) * spacing # + spacing / 2
      if (col <= 6) {
        if (row <= 5)
          Plot <- 1
        else if (row <= 9)
          Plot <- 2
        else if (row <= 13)
          Plot <- 3
        else if (row <= 17)
          Plot <- 4
        else if (row <= 21)
          Plot <- 5
        else if (row <= 26)
          Plot <- 6
      } else {
        if (row <= 5)
          Plot <- 12
        else if (row <= 9)
          Plot <- 11
        else if (row <= 13)
          Plot <- 10
        else if (row <= 17)
          Plot <- 9
        else if (row <= 21)
          Plot <- 8
        else if (row <= 26)
          Plot <- 7
      }
      
      Plot <- Plot + (blockNum - 1) * 12
      
      Border <- ifelse(col == 1 || col == columns || row == 1 || row == rows, TRUE, FALSE)
      pts <- rbind(pts, data.frame(Tag = 0, Block = blockNum, Plot = Plot, X = X, Y = Y, Row = ifelse(blockNum > 1, row + 16, row), Col = (blockNum - 1) * columns + col, Live = TRUE, Border = Border, Filler = FALSE, Extra = FALSE))
    }
  }
  
  makeIndex <- function(row, col)
  {
    if (blockNum == 1)
      ind <- ((row - 1) * columns + col) 
    else
      ind <- ((row - 16 - 1) * columns + (col - (blockNum - 1) * 12)) 
    
    return(ind)
  }
  
  # Live: TRUE or FALSE
  # Border: TRUE or FALSE
  # Filler: TRUE or FALSE
  # Extra: TRUE or FALSE
  
  if (blockNum == 1) {
    pts$Live[makeIndex(6,1)] <- FALSE
    pts$Live[makeIndex(7,3)] <- FALSE
    pts$Live[makeIndex(7,7)] <- FALSE
    pts$Live[makeIndex(8,2)] <- FALSE
    pts$Live[makeIndex(9,2)] <- FALSE
    pts$Live[makeIndex(9,5)] <- FALSE
    pts$Live[makeIndex(11,7)] <- FALSE
    pts$Live[makeIndex(16,5)] <- FALSE
    pts$Live[makeIndex(20,3)] <- FALSE
    pts$Live[makeIndex(21,9)] <- FALSE
    pts$Live[makeIndex(23,2)] <- FALSE
    pts$Live[makeIndex(24,5)] <- FALSE
    pts$Live[makeIndex(25,3)] <- FALSE
    pts$Live[makeIndex(25,4)] <- FALSE
    pts$Live[makeIndex(26,2)] <- FALSE
    
    pts$Filler[makeIndex(9,4)] <- TRUE
    pts$Filler[makeIndex(17,2)] <- TRUE
    
    # block 1
    pts$Tag[1:12] <- c("10199","2949","10190","10197","10191","10192","11343","11340","11341","11345","11348","11349")
    pts$Tag[13:24] <- c("10198","7709","2855","3186","7823","3096","7003","6980","2023","556","353","11344")
    pts$Tag[25:36] <- c("10193","7624","2872","2908","7880","7555","5533","6844","2273","2328","398","11347")
    pts$Tag[37:48] <- c("10194","2998","3017","7749","7593","7802","7098","7064","5323","2208","523","11346")
    pts$Tag[49:60] <- c("10196","7681","3153","3076","2943","7522","5354","5477","6801","2307","2086","11342")
    pts$Tag[61:72] <- c("32700","3865","8684","8475","8513","8545","6486","8904","7249","7199","7275","4449")
    pts$Tag[73:84] <- c("32688","8549","4048","4010","8633","8622","4337","9006","6441","8936","7320","11582")
    pts$Tag[85:96] <- c("32686","4102","8665","3784","3794","3824","2479","1669","2601","2503","8973","4366")
    pts$Tag[97:108] <- c("32687","3969","4085","31799","3899","3941","4370","2558","4321","1707","4421","11581")
    pts$Tag[109:120] <- c("11532","886","1959","5978","1923","847","2140","4704","5402","4750","5282","11283")
    pts$Tag[121:132] <- c("11534","952","1033","2015","841","138","6939","318","9150","427","9302","11284")
    pts$Tag[133:144] <- c("11533","5880","6742","5963","5121","5921","9250","2161","6906","4565","5250","11285")
    pts$Tag[145:156] <- c("963","6782","6700","5090","5847","5800","246","4532","9093","2142","5438","11282")
    pts$Tag[157:168] <- c("11441","6658","6175","6295","1284","1488","3682","3658","3706","4259","3636","11208")
    pts$Tag[169:180] <- c("11442","6234","6339","1502","1296","6644","9210","4218","4151","4612","4188","11207")
    pts$Tag[181:192] <- c("32315","6142","1320","1554","1528","6612","8410","8367","8865","8753","4672","11699")
    pts$Tag[193:204] <- c("11445","11443","6263","1393","1433","1835","8272","8316","8775","8815","9167","11695")
    pts$Tag[205:216] <- c("11648","6635","1594","692","714","588","7992","8093","8189","8067","8163","32054")
    pts$Tag[217:228] <- c("11645","7134","5629","1623","2362","657","7916","8043","8226","7971","8182","11160")
    pts$Tag[229:240] <- c("33091","5606","7168","5705","620","2424","3585","3315","3228","3555","3347","32051")
    pts$Tag[241:252] <- c("11647","5566","6633","6421","5643","6355","3390","3487","3271","3483","3442","32058")
    pts$Tag[253:264] <- c("11485","2693","7497","4506","4794","2648","204","782","1108","24","181","11388")
    pts$Tag[265:276] <- c("11487","7430","2747","1773","4475","1759","1242","805","1194","6079","5174","11391")
    pts$Tag[277:288] <- c("11493","6565","6534","7395","7368","9315","1138","66","6044","5034","5764","11393")
    pts$Tag[289:300] <- c("11484","7461","9037","9363","4841","2769","5732","5052","6086","6008","5210","11394")
    pts$Tag[301:312] <- c("11489","11488","11486","11490","9382","11492","11389","11395","831","5788","11392","11390")
  } else if (blockNum == 2) {
    pts$Live[makeIndex(19,16)] <- FALSE
    pts$Live[makeIndex(19,22)] <- FALSE
    pts$Live[makeIndex(20,17)] <- FALSE
    pts$Live[makeIndex(20,18)] <- FALSE
    pts$Live[makeIndex(21,14)] <- FALSE
    pts$Live[makeIndex(21,16)] <- FALSE
    pts$Live[makeIndex(24,16)] <- FALSE
    pts$Live[makeIndex(26,17)] <- FALSE
    pts$Live[makeIndex(26,21)] <- FALSE
    pts$Live[makeIndex(32,23)] <- FALSE
    pts$Live[makeIndex(40,18)] <- FALSE
    pts$Live[makeIndex(40,19)] <- FALSE
    pts$Live[makeIndex(40,20)] <- FALSE
    pts$Live[makeIndex(40,21)] <- FALSE
    pts$Live[makeIndex(41,16)] <- FALSE
    pts$Live[makeIndex(41,19)] <- FALSE
    
    pts$Filler[makeIndex(30,14)] <- TRUE
    pts$Filler[makeIndex(30,23)] <- TRUE
    pts$Filler[makeIndex(38,19)] <- TRUE
    pts$Filler[makeIndex(40,17)] <- TRUE
  
    # block 2
    pts$Tag[1:12] <- c("32053","11173","11171","11170","32625","11175","11373","5197","33001","11377","11375","11380")
    pts$Tag[13:24] <- c("11176","3520","3425","3356","3514","3405","1096","58","225","1219","1135","6122")
    pts$Tag[25:36] <- c("32052","3222","3304","7987","8154","3573","1211","168","760","822","7","11379")
    pts$Tag[37:48] <- c("11169","3454","3276","7907","8128","8250","5719","6096","6062","5986","5772","11376")
    pts$Tag[49:60] <- c("11172","8201","7948","8070","8179","8028","5202","5163","5054","5024","6020","11374")
    pts$Tag[61:72] <- c("11331","5355","6858","7092","5487","5520","5798","6757","5153","6692","6740","11530")
    pts$Tag[73:84] <- c("11333","2282","6795","6954","5320","7055","5937","5896","5096","5850","5950","11527")
    pts$Tag[85:96] <- c("11334","2035","7012","2335","558","2093","1034","1060","128","961","89","11531")
    pts$Tag[97:108] <- c("11332","520","381","2198","2270","350","2000","909","1957","838","1911","32441")
    pts$Tag[109:120] <- c("11242","9215","8771","8859","8288","8738","3154","7687","2846","3052","2948","9598")
    pts$Tag[121:132] <- c("11240","9180","8357","8414","4250","8810","3039","3115","2928","3197","3000","9597")
    pts$Tag[133:144] <- c("8415","3621","3666","4170","3701","4135","7517","7894","7801","7588","7579","10188")
    pts$Tag[145:156] <- c("8417","3761","8308","4633","4678","4228","7834","7629","7727","7573","7740","2936")
    pts$Tag[157:168] <- c("11638","11637","5636","6367","5587","5684","1413","1305","6278","6656","11432","11433")
    pts$Tag[169:180] <- c("6393","6619","6424","7108","5558","5591","1318","1269","1377","6195","1470","11435")
    pts$Tag[181:192] <- c("11639","7171","671","2393","1613","2435","1832","1446","1459","1522","6597","11430")
    pts$Tag[193:204] <- c("11636","1567","661","1855","710","606","6252","6330","1876","6214","6145","11434")
    pts$Tag[205:216] <- c("11274","6882","5309","481","436","263","7403","9328","6566","9064","9376","11478")
    pts$Tag[217:228] <- c("11275","5263","296","4545","4585","6947","6535","7356","7469","1737","7436","11476")
    pts$Tag[229:240] <- c("11273","5427","2119","4760","4691","6931","4521","2620","4840","1791","4808","11477")
    pts$Tag[241:252] <- c("11276","9107","5443","9249","9119","9275","4792","2772","4457","2750","2702","2766")
    pts$Tag[253:264] <- c("11574","6462","7259","8907","2533","9023","32697","4038","4036","3940","3819","32695")
    pts$Tag[265:276] <- c("2611","7187","8952","8993","1647","4326","3907","4008","4118","3780","4071","32698")
    pts$Tag[277:288] <- c("11571","6498","7328","2587","4936","4438","8712","8644","8472","3874","8563","32650")
    pts$Tag[289:300] <- c("11567","7288","4386","2508","1722","4311","8506","8604","8421","3837","3985","31782")
    pts$Tag[301:312] <- c("11565","9516","11566","11570","11569","11568","32690","32651","32692","32693","32699","32294")
  } else if (blockNum == 3) {
    pts$Live[makeIndex(19,30)] <- FALSE
    pts$Live[makeIndex(19,34)] <- FALSE
    pts$Live[makeIndex(20,31)] <- FALSE
    pts$Live[makeIndex(20,33)] <- FALSE
    pts$Live[makeIndex(20,34)] <- FALSE
    pts$Live[makeIndex(20,35)] <- FALSE
    pts$Live[makeIndex(21,29)] <- FALSE
    pts$Live[makeIndex(21,31)] <- FALSE
    pts$Live[makeIndex(21,32)] <- FALSE
    pts$Live[makeIndex(21,34)] <- FALSE
    pts$Live[makeIndex(21,35)] <- FALSE
    pts$Live[makeIndex(22,30)] <- FALSE
    pts$Live[makeIndex(23,33)] <- FALSE
    pts$Live[makeIndex(24,27)] <- FALSE
    pts$Live[makeIndex(25,26)] <- FALSE
    pts$Live[makeIndex(30,31)] <- FALSE
    pts$Live[makeIndex(35,27)] <- FALSE
    pts$Live[makeIndex(36,31)] <- FALSE
    pts$Live[makeIndex(41,35)] <- FALSE
  
    pts$Filler[makeIndex(21,35)] <- TRUE
    pts$Filler[makeIndex(25,26)] <- TRUE
    pts$Filler[makeIndex(25,31)] <- TRUE
    pts$Filler[makeIndex(33,31)] <- TRUE
    pts$Filler[makeIndex(33,35)] <- TRUE
  
    # block 3
    pts$Tag[1:12] <- c("11509","11517","11510","11516","11518","11515","11414","11420","11423","11421","11416","11422")
    pts$Tag[13:24] <- c("11514","5147","6772","6733","1064","865","6210","6650","1300","1344","6615","11418")
    pts$Tag[25:36] <- c("11513","5113","5943","933","132","82","6594","6162","6148","6173","6320","11415")
    pts$Tag[37:48] <- c("11508","6790","5842","1937","1031","917","6258","6301","1409","1523","1467","11419")
    pts$Tag[49:60] <- c("11512","5881","5818","5905","6678","1956","1810","1889","1379","1260","11417","11424")
    pts$Tag[61:72] <- c("10062","8102","8023","3348","3546","3486","3935","3906","3978","3785","3827","32652")
    pts$Tag[73:84] <- c("11154","8110","3306","3590","3389","3470","8621","4011","3859","4040","4077","32646")
    pts$Tag[85:96] <- c("11152","7908","7959","8008","8239","3216","8654","8542","8679","8574","8464","32643")
    pts$Tag[97:108] <- c("11150","32635","8062","8138","7973","8204","32694","8496","8676","8449","8722","32637")
    pts$Tag[109:120] <- c("33049","5003","5989","56","1167","16","2524","1709","8920","7284","8967","11558")
    pts$Tag[121:132] <- c("11366","6075","5073","4856","211","63","4887","4352","2546","6474","6437","11556")
    pts$Tag[133:144] <- c("11365","6073","6112","1111","1237","773","2597","2470","7312","7237","7206","11557")
    pts$Tag[145:156] <- c("11364","6021","5179","5220","5722","5781","4312","4399","1670","8954","9027","11559")
    pts$Tag[157:168] <- c("11219","8366","4145","8282","3673","3688","7130","5640","5584","6643","5691","11618")
    pts$Tag[169:180] <- c("11217","3616","4195","4674","8857","3748","6418","6628","5592","6356","7165","11614")
    pts$Tag[181:192] <- c("11218","9187","4605","8830","8758","8395","1586","648","616","682","712","11616")
    pts$Tag[193:204] <- c("11216","4249","9201","8780","8302","4220","33205","1627","595","2439","11617","11615")
    pts$Tag[205:216] <- c("11325","5505","6994","6852","2331","2083","4526","9097","270","4732","452","11266")
    pts$Tag[217:228] <- c("11322","5369","6813","6960","2252","525","294","4592","5421","5448","2159","11265")
    pts$Tag[229:240] <- c("11324","5531","7072","403","2032","2289","5268","9257","2128","9134","5304","11267")
    pts$Tag[241:252] <- c("11323","5317","7035","363","555","2194","4684","434","6914","6893","9304","11264")
    pts$Tag[253:264] <- c("11461","1768","7435","4482","2619","4806","2823","2880","2985","2972","3019","9582")
    pts$Tag[265:276] <- c("11463","4801","2802","1785","2675","2749","3155","3051","3210","3094","7721","9583")
    pts$Tag[277:288] <- c("11460","4837","9333","9044","7362","7386","7566","7653","2929","7609","7875","9572")
    pts$Tag[289:300] <- c("11468","9345","6540","9348","6556","7475","7671","7795","7854","7520","7776","9569")
    pts$Tag[301:312] <- c("11469","11462","2755","9385","11467","2712","9578","9586","9587","9570","9571","9584")
  } else if (blockNum == 4) {
    pts$Live[makeIndex(18,38)] <- FALSE
    pts$Live[makeIndex(19,39)] <- FALSE
    pts$Live[makeIndex(19,40)] <- FALSE
    pts$Live[makeIndex(19,43)] <- FALSE
    pts$Live[makeIndex(20,42)] <- FALSE
    pts$Live[makeIndex(20,43)] <- FALSE
    pts$Live[makeIndex(21,39)] <- FALSE
    pts$Live[makeIndex(21,40)] <- FALSE
    pts$Live[makeIndex(21,42)] <- FALSE
    pts$Live[makeIndex(21,43)] <- FALSE
    pts$Live[makeIndex(21,44)] <- FALSE
    pts$Live[makeIndex(23,38)] <- FALSE
    pts$Live[makeIndex(24,44)] <- FALSE
    pts$Live[makeIndex(24,46)] <- FALSE
    pts$Live[makeIndex(25,46)] <- FALSE
    pts$Live[makeIndex(25,47)] <- FALSE
    pts$Live[makeIndex(26,39)] <- FALSE
    pts$Live[makeIndex(26,44)] <- FALSE
    pts$Live[makeIndex(26,46)] <- FALSE
    pts$Live[makeIndex(26,48)] <- FALSE
    pts$Live[makeIndex(27,42)] <- FALSE
    pts$Live[makeIndex(27,44)] <- FALSE
    pts$Live[makeIndex(27,45)] <- FALSE
    pts$Live[makeIndex(27,47)] <- FALSE
    pts$Live[makeIndex(28,38)] <- FALSE
    pts$Live[makeIndex(28,44)] <- FALSE
    pts$Live[makeIndex(28,47)] <- FALSE
    pts$Live[makeIndex(29,43)] <- FALSE
    pts$Live[makeIndex(30,42)] <- FALSE
    pts$Live[makeIndex(30,43)] <- FALSE
    pts$Live[makeIndex(30,44)] <- FALSE
    pts$Live[makeIndex(31,37)] <- FALSE
    pts$Live[makeIndex(31,38)] <- FALSE
    pts$Live[makeIndex(31,39)] <- FALSE
    pts$Live[makeIndex(31,41)] <- FALSE
    pts$Live[makeIndex(32,40)] <- FALSE
    pts$Live[makeIndex(32,41)] <- FALSE
    pts$Live[makeIndex(32,47)] <- FALSE
    pts$Live[makeIndex(35,41)] <- FALSE
    pts$Live[makeIndex(41,39)] <- FALSE
  
    pts$Filler[makeIndex(25,46)] <- TRUE
    pts$Filler[makeIndex(25,47)] <- TRUE
    pts$Filler[makeIndex(26,43)] <- TRUE
    pts$Filler[makeIndex(33,43)] <- TRUE
    pts$Filler[makeIndex(41,47)] <- TRUE
  
    # block 4
    pts$Tag[1:12] <- c("11229","11230","11227","11225","11231","11232","11545","11549","11544","11550","11548","11542")
    pts$Tag[13:24] <- c("11228","9203","8735","4132","8300","8861","6506","4414","2576","2535","7256","11543")
    pts$Tag[25:36] <- c("11226","3671","8399","8777","4667","4270","8966","6461","1711","4303","2498","11546")
    pts$Tag[37:48] <- c("11233","3607","4176","8318","3724","8346","7271","7220","9004","7325","8908","11541")
    pts$Tag[49:60] <- c("11234","4636","8811","3696","9169","4217","4390","1665","4345","2462","8949","11547")
    pts$Tag[61:72] <- c("11499","5920","4909","928","114","1926","1275","6157","1463","1387","1398","11407")
    pts$Tag[73:84] <- c("11501","6735","1963","1023","2016","6780","1315","1552","1511","6294","6182","11404")
    pts$Tag[85:96] <- c("11500","5951","5899","6680","1053","5806","6649","6253","6657","1396","6604","11408")
    pts$Tag[97:108] <- c("11502","5125","154","868","5099","5858","6341","1402","1805","11405","11406","11403")
    pts$Tag[109:120] <- c("11356","5053","6087","1133","1222","1114","31767","3984","8505","3828","3916","32636")
    pts$Tag[121:132] <- c("11355","827","59","1199","788","5186","8447","8717","8617","4056","3877","32644")
    pts$Tag[133:144] <- c("11358","5737","5213","5752","193","213","8554","8538","3778","4020","3867","32645")
    pts$Tag[145:156] <- c("11357","6074","29","5019","6054","6001","8653","8453","8658","4092","8702","32642")
    pts$Tag[157:168] <- c("11453","1750","2720","4804","1787","6561","2423","7174","5551","5647","6425","11656")
    pts$Tag[169:180] <- c("11452","4512","2781","7460","4485","2623","1845","6385","6390","1625","7125","11657")
    pts$Tag[181:192] <- c("11451","6524","2683","7493","9217","4821","1568","2395","1857","5601","627","11655")
    pts$Tag[193:204] <- c("11454","7449","7396","7355","9355","2812","11658","5673","745","678","583","11654")
    pts$Tag[205:216] <- c("9581","7891","7596","2839","3108","7797","7088","2348","7015","5330","6822","11314")
    pts$Tag[217:228] <- c("9579","7753","7556","3209","3137","2905","2097","2246","2285","2060","2199","11313")
    pts$Tag[229:240] <- c("9585","7853","7689","3004","7505","3073","566","500","337","5511","391","11315")
    pts$Tag[241:252] <- c("9580","7702","7650","2947","7580","3047","5480","7045","6838","6959","5374","11316")
    pts$Tag[253:264] <- c("11254","9284","9147","4571","2134","2171","8142","3509","8032","7921","3370","11139")
    pts$Tag[265:276] <- c("11251","444","4730","289","450","253","7952","3534","3266","8243","3424","32055")
    pts$Tag[277:288] <- c("445","4548","5465","4693","9092","6934","8197","3570","7989","8096","8065","11136")
    pts$Tag[289:300] <- c("11256","5280","6876","5408","5270","9262","3218","3469","3341","7984","33298","11141")
    pts$Tag[301:312] <- c("11249","11253","11252","11258","11255","11250","11138","11140","11137","11143","10061","11144")
  }
  
  # add extra trees that are still present (not cut)
  addExtraTree <- function(row, col, block, plot, tag, Live = TRUE, Extra = TRUE)
  {
    # compute XY using row,col...should be decimal ##.5,##.5  
    X <- (col - ((blockNum - 1) * columns) - 1) * spacing # + spacing / 2
    Y <- (row - ifelse(blockNum > 1, 16, 0) - 1) * spacing # + spacing / 2
    
    df <-data.frame(Tag = tag, Block = block, Plot = plot, X = X, Y = Y, Row = row, Col = col, Live = Live, Border = FALSE, Filler = TRUE, Extra = Extra)  
    pts <<- rbind(pts, df)
  }
  
  if (blockNum == 1) {
    # no extra trees remain uncut
  } else if (blockNum == 2) {
    addExtraTree(40.5, 19.5, blockNum, 19, "32696")
  } else if (blockNum == 3) {
    addExtraTree(19.5, 31.5, blockNum, 36, "11428", Live = FALSE)
    addExtraTree(19.5, 32.5, blockNum, 36, "11426", Live = FALSE)
    addExtraTree(19.5, 33.5, blockNum, 36, "11425", Live = FALSE)
    addExtraTree(19.5, 34.5, blockNum, 36, "11429")
    addExtraTree(20.5, 31.5, blockNum, 36, "11427")
    addExtraTree(24.5, 26.5, blockNum, 26, "11157", Live = FALSE)
  } else if (blockNum == 4) {
    addExtraTree(18.5, 39.5, blockNum, 37, "11237", Live = FALSE)
    addExtraTree(18.5, 43.5, blockNum, 48, "11555", Live = FALSE)
    addExtraTree(26.5, 43.5, blockNum, 46, "32064", Live = FALSE)
    addExtraTree(27.5, 46.5, blockNum, 46, "32592", Live = FALSE)
    addExtraTree(30.5, 41.5, blockNum, 40, "11455", Live = FALSE)
    addExtraTree(31.5, 39.5, blockNum, 40, "11458", Live = FALSE)
    addExtraTree(31.5, 40.5, blockNum, 40, "11459", Live = FALSE)
    addExtraTree(31.5, 45.5, blockNum, 45, "11659", Live = FALSE)
    addExtraTree(34.5, 40.5, blockNum, 41, "9591", Live = FALSE)
  }
  
  # create points
  trees <- vect(pts, geom = c("X", "Y"), crs = "EPSG:32610", keepgeom = FALSE)
  
  # align by trial and error...sort of educated trial and error since we have tree locations 
  # from lidar.
  # initial origin is from the lidar trees with offset to get to corner of study plot/area
  # rotation was measured in ArcPro along columns of trees. This could be improved a bit but the
  # alignment turned out pretty good.
  if (blockNum == 1) {
    ox <- 500724.965 #- 1.8    # had entire block off by 1 row...maybe not!!
    oy = 5154780.184 #- 1.8
    #ox <- 500726.344 #- 1.8
    #oy = 5154783.547 #- 1.8
    angle <- 19.2833
  } else if (blockNum == 2) {
    ox <- 500786.63 #- 1.8
    oy = 5154823.445 #- 1.8
    angle <- 18.0
  } else if (blockNum == 3) {
    ox <- 500828 #- 1.8
    oy = 5154810 #- 1.8
    angle <- 17.0 + 22/60
  } else if (blockNum == 4) {
    ox <- 500869.785 #- 1.8
    oy = 5154796.982 #- 1.8
    angle <- 17.0 + 5/60
  }
  
  trees <- shift(trees, dx = ox, dy = oy)
  trees <- spin(trees, angle, ox, oy)
  
  # add locations to trees as columns
  xy <- geom(trees, df = TRUE)
  trees$X <- xy$x
  trees$Y <- xy$y
  
  # write tree locations to shapefile
  writeVector(trees, paste0(outputFolder, "Block", blockNum, "Trees.shp"), overwrite = TRUE)
  
  #plot(trees[trees$Live,])
  #plot(trees)
  
  # deal with block
  # generate block rectangle...local coordinate system
  block = data.frame(X = c(-spacing / 2, columns * spacing + spacing / 2, columns * spacing + spacing / 2, -spacing / 2, -spacing / 2),
                     Y = c(-spacing / 2, -spacing / 2, rows * spacing + spacing  / 2, rows * spacing + spacing / 2, -spacing / 2))
  
  blkpts <- vect(block, geom=c("X", "Y"), crs = "EPSG:32610", keepgeom = TRUE)
  #blk <- vect(geom(blkpts), type = "polygons", crs = "EPSG:32610")
  blk <- convHull(blkpts)
  
  blk <- shift(blk, dx = ox, dy = oy)
  blk <- spin(blk, angle, ox, oy)
  writeVector(blk, paste0(outputFolder, "Block", blockNum, "Perimeter.shp"), overwrite = TRUE)
}
