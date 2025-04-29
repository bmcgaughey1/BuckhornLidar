# code to merge block files into single files
#
# There are better ways to do this but brute force is often the fastest and least
# error prone. However, cut-and-paste mistakes (forgetting to change something in 
# pasted code) are possible (and likely).
#
library(terra)

source("Rcode/FileSystem.R")

outputFolder <- paste0(dataFolder, "FINALData/")

# ****** CSV files

# merged block trees...no trees with recent measurements for block 1
df1 <- read.csv(paste0(outputFolder, "FINAL_Merged_Block1_Trees.csv"), stringsAsFactors = FALSE)
df2 <- read.csv(paste0(outputFolder, "FINAL_Merged_Block2_Trees.csv"), stringsAsFactors = FALSE)
df3 <- read.csv(paste0(outputFolder, "FINAL_Merged_Block3_Trees.csv"), stringsAsFactors = FALSE)
df4 <- read.csv(paste0(outputFolder, "FINAL_Merged_Block4_Trees.csv"), stringsAsFactors = FALSE)

df <- rbind(df2, df3)
df <- rbind(df, df4)

# write data
write.csv(df, paste0(outputFolder, "FINAL_Merged_trees.csv"), row.names = FALSE)

# simple measurements
if (!useShiftedTrees) {
  df1 <- read.csv(paste0(outputFolder, "FINAL_Block1_SimpleMeasurements.csv"), stringsAsFactors = FALSE)
  df2 <- read.csv(paste0(outputFolder, "FINAL_Block2_SimpleMeasurements.csv"), stringsAsFactors = FALSE)
  df3 <- read.csv(paste0(outputFolder, "FINAL_Block3_SimpleMeasurements.csv"), stringsAsFactors = FALSE)
  df4 <- read.csv(paste0(outputFolder, "FINAL_Block4_SimpleMeasurements.csv"), stringsAsFactors = FALSE)
  
  df <- rbind(df1, df2)
  df <- rbind(df, df3)
  df <- rbind(df, df4)
  
  # write data
  write.csv(df, paste0(outputFolder, "FINAL_SimpleMeasurements.csv"), row.names = FALSE)
}

# shifted simple measurements
df1 <- read.csv(paste0(outputFolder, "FINAL_ShiftedBlock1_SimpleMeasurements.csv"), stringsAsFactors = FALSE)
df2 <- read.csv(paste0(outputFolder, "FINAL_ShiftedBlock2_SimpleMeasurements.csv"), stringsAsFactors = FALSE)
df3 <- read.csv(paste0(outputFolder, "FINAL_ShiftedBlock3_SimpleMeasurements.csv"), stringsAsFactors = FALSE)
df4 <- read.csv(paste0(outputFolder, "FINAL_ShiftedBlock4_SimpleMeasurements.csv"), stringsAsFactors = FALSE)

df <- rbind(df1, df2)
df <- rbind(df, df3)
df <- rbind(df, df4)

# write data
write.csv(df, paste0(outputFolder, "FINAL_ShiftedSimpleMeasurements.csv"), row.names = FALSE)

# ****** geospatial files

# merged block trees...no trees with recent measurements for block 1
v1 <- vect(paste0(outputFolder, "FINAL_Merged_Block1_Trees.shp"))
v2 <- vect(paste0(outputFolder, "FINAL_Merged_Block2_Trees.shp"))
v3 <- vect(paste0(outputFolder, "FINAL_Merged_Block3_Trees.shp"))
v4 <- vect(paste0(outputFolder, "FINAL_Merged_Block4_Trees.shp"))

v <- vect(c(v1, v2, v3, v4))

# write data
writeVector(v, paste0(outputFolder, "FINAL_Merged_trees.shp"), overwrite = TRUE)

# simple measurements
if (!useShiftedTrees) {
  v1 <- vect(paste0(outputFolder, "FINAL_Block1_SimpleMeasurements.shp"))
  v2 <- vect(paste0(outputFolder, "FINAL_Block2_SimpleMeasurements.shp"))
  v3 <- vect(paste0(outputFolder, "FINAL_Block3_SimpleMeasurements.shp"))
  v4 <- vect(paste0(outputFolder, "FINAL_Block4_SimpleMeasurements.shp"))
  
  v <- vect(c(v1, v2, v3, v4))
  
  # write data
  writeVector(v, paste0(outputFolder, "FINAL_SimpleMeasurements.shp"), overwrite = TRUE)
}

# shifted simple measurements
v1 <- vect(paste0(outputFolder, "FINAL_ShiftedBlock1_SimpleMeasurements.shp"))
v2 <- vect(paste0(outputFolder, "FINAL_ShiftedBlock2_SimpleMeasurements.shp"))
v3 <- vect(paste0(outputFolder, "FINAL_ShiftedBlock3_SimpleMeasurements.shp"))
v4 <- vect(paste0(outputFolder, "FINAL_ShiftedBlock4_SimpleMeasurements.shp"))

v <- vect(c(v1, v2, v3, v4))

# write data
writeVector(v, paste0(outputFolder, "FINAL_ShiftedSimpleMeasurements.shp"), overwrite = TRUE)
