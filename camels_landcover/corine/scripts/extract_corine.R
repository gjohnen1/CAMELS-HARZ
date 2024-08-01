# Calculate fractions of land use classes for catchment polygons (from gpkg)
# @author: Pia Ebeling and
#          land use group of the CAMELS-DE team
#
# created: 2022/11/03
# modified: 2024/02/29

# Load packages ####
library(sf) # spatial features
library(tidyverse)
# Raster extraction
# library(stars) # to plot cropped raster
library(exactextractr) # to extract raster data including covered fractions
library(terra) # for raster formatting

# Prepare workspace ####
path <- "Y:/Home/ebelingp/Projects/camels/scripts/R"
setwd(path)
source("functions_camels.R")
ezg_file = '../../ezgs/merit_hydro.gpkg' # Example file with 3 catchments (layers)
ezg_name <- "merit_hydro"
ezg_polygons_all <- sf::st_read(dsn=ezg_file, layer=ezg_name)

# Load raster data (Landuse) to extract
clc.tif <- rast("../input_data/ger_corine_ger100_2012_level1.tif")
class_values <- sort(unique(c(clc.tif[[1]])))
print(class_values)


# Transform EZG polygon to match the raster coordinate system
ezg_polygons_all <- st_transform(ezg_polygons_all, st_crs(clc.tif))

    
# Extract the raster data ####
extracted_rast <- exact_extract(clc.tif, ezg_polygons_all, 
                                fun="frac", force_df=T, 
                                append_cols="id")





# For plotting: Loop through all layers (catchments)
for (i in 1:nrow(ezg_polygons_all)){
    print(i)
    ezg_polygons <- ezg_polygons_all[i,]
    ezg_union <- ezg_polygons
    
    # Check/Plot EZG unified polygon
    glimpse(ezg_union)
    ggplot() + 
        geom_sf(data=ezg_polygons)
    
    # Plot raster to mask by EZG area ####
    clc.tif_SpatRaster <- st_as_stars(clc.tif)
    raster_ezg <- st_crop(clc.tif_SpatRaster, ezg_union_trans, as_points = FALSE)
    class_estimate <- table(raster_ezg[[1]])
    sum(class_estimate)
    error_estimate <- sum(class_estimate)*100*100/ezg_union_trans$area
    ggplot() +
        geom_stars(data=raster_ezg) +
        geom_sf(data=ezg_union_trans, color="pink", size=1,fill=NA) +
        geom_sf_label(data=ezg_union_trans, aes(label=paste(round(area_calc),"km2"))) +
        scale_fill_continuous(name="class",na.value ="transparent")
}
