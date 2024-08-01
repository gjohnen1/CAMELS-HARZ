# CORINE Land Cover

## Description

Dockerized tool to extract and process data from the CORINE land cover tif file for CAMELS-DE.  
A .csv file is created in the `output_data` folder containing the area percentage of land cover classes in each catchment. For CAMELS-DE we only use the superclasses of CORINE, the extracted variable are listed below.  
The results are copied to the camelsp `output_data` directory, where other tools process the data further and organize it in the folder structure.

## Container

### Build the container

```bash
docker build -t corine .
```

### Run the container

Follow the instructions in `input_data/README.md` to add the necessary input data to run the tool. 

To run the container, the local `input_data`, `output_data` and `camelsp/output_data` directories have to be mounted inside the container:

```bash
docker run -v ./input_data:/input_data -v ./output_data:/output_data -v /path/to/local/camelsp/output_data:/camelsp/output_data -it --rm corine
```

## Output variables

All variables represent the area percentage of the main CORINE land cover classes of the total catchment area.  

**CORINE classes**:
- artificial_surfaces_perc [%]
- agricultural_areas_perc [%]
- forests_and_seminatural_areas_perc [%]
- wetlands_perc [%]
- water_bodies_perc [%]
