import os
import geopandas as gpd
import pandas as pd

def generate_harz_gpkg():
    # Define the directory containing the shapefiles
    directory = '/home/sngrj0hn/GitHub/CAMELS-DE/catchments_harz'
    # List all shapefiles in the directory
    shapefiles = [os.path.join(directory, f) for f in os.listdir(directory) if f.endswith('.shp')]
    # Initialize list to hold GeoDataFrames and a dictionary for ID mapping
    gdfs = []
    id_counter = 1
    id_mapping = {}
    for shp in shapefiles:
        # Load the shapefile
        gdf = gpd.read_file(shp)
        # remove all columns except 'geometry'
        gdf = gdf[['geometry']]
        
        # Generate IDs and map them
        gdf['id'] = range(id_counter, id_counter + len(gdf))
        id_mapping[os.path.basename(shp)] = list(gdf['id'])
        id_counter += len(gdf)
        
        gdfs.append(gdf)

    all_catchments = gpd.GeoDataFrame(pd.concat(gdfs, ignore_index=True))
    # Save to a new GeoPackage
    print(os.getcwd())
    # Save to geopackage
    all_catchments.to_file("camels_soils/isric/output_data/catchments.gpkg", driver="GPKG")


if __name__ == "__main__":
    generate_harz_gpkg()