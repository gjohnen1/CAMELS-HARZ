from camelsp import Station
import pandas as pd
import os

def save_corine_to_stations():
    """
    Add the extracted CORINE land cover data to the stations in the camelsp
    folder structure.

    """
    # Read the extracted CORINE land cover data
    corine = pd.read_csv("/corine/output_data/corine_extracted.csv")

    # Loop over the rows and add the data to the stations
    for _, row in corine.iterrows():
        # Initialize station
        s = Station(row["camels_id"])

        # Get the station output_path
        output_path = s.output_path

        # Create the folder land_cover if it does not exist
        os.makedirs(os.path.join(output_path, "land_cover"), exist_ok=True)

        # Save the land cover data as a csv file
        land_cover_path = os.path.join(output_path, "land_cover", "corine.csv")

        # Save the land cover data
        corine.loc[corine["camels_id"] == row["camels_id"]].to_csv(land_cover_path, index=False)


if __name__ == "__main__":
    save_corine_to_stations()