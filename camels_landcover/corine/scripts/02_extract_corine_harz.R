# Calculate fractions of land use classes from CORINE dataset for catchment polygons (from gpkg).
# @author: Pia Ebeling, Alexander Dolich
#          and land use group of the CAMELS-DE team
#
# created: 2022/11/03
# modified: 2024/03/01

# set working directory
setwd("./corine")

library(exactextractr)
library(terra)
library(sf)
library(foreign)

# Load corine raster
print("Loading CORINE raster from /input_data/U2018_CLC2018_V2020_20u1.tif ...")
corine <- terra::rast("./input_data/U2018_CLC2018_V2020_20u1.tif")

# Match the CORINE classes with the .dbf
print("Loading CORINE classes from /input_data/U2018_CLC2018_V2020_20u1.tif.vat.dbf ...")
corine_classes <- foreign::read.dbf("./input_data/U2018_CLC2018_V2020_20u1.tif.vat.dbf")

# Define the mapping from subclasses to main classes
corine_mapping <- data.frame(
  subclass = corine_classes$Value,
  mainclass = as.numeric(as.character(corine_classes$CODE_18)) %/% 100  # Convert to numeric before division
)

# Define a function to reclassify the raster from subclasses to main classes
print("Reclassifying the raster to main classes 1-5 (artificial_surfaces, agricultural_areas, forests_and_seminatural_areas, wetlands, water_bodies) ...")
reclassify_raster <- function(x) {
  ifelse(is.na(x), NA, corine_mapping$mainclass[match(x, corine_mapping$subclass)])
}

# Apply reclassify the raster
print("Applying reclassification to CORINE main classes ...")
corine_main_classes <- terra::app(corine, reclassify_raster)

# Load catchment polygons
print("Loading catchment polygons from /output_data/catchments.gpkg ...")
catchments <- sf::st_read("./output_data/catchments.gpkg")

# transform catchments to match the raster coordinate system
catchments <- st_transform(catchments, st_crs(corine_main_classes))

# Extract the raster data for all catchments
print("Extracting the raster data for all catchments ...")
extracted_rast <- exact_extract(corine_main_classes, catchments,
                                fun = "frac", force_df = TRUE,
                                append_cols = "id", progress = FALSE)

# Convert fraction to percentage
extracted_rast[, -1] <- extracted_rast[, -1] * 100

# Define the names of the main classes
main_class_names <- c("artificial_surfaces", "agricultural_areas", "forests_and_seminatural_areas", "wetlands", "water_bodies")

# Rename the columns
colnames(extracted_rast)[-1] <- paste(main_class_names, "perc", sep = "_")
colnames(extracted_rast)[1] <- "camels_id"

# Save the extracted data
print("Saving the extracted data to /output_data/corine_extracted.csv ...")
write.csv(extracted_rast, "./output_data/corine_extracted.csv", row.names = FALSE)
