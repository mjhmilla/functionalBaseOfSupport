# Description

This is a collection of Matlab scripts that will demonstrate how to compute the location of a functional-base-of-support (FBOS) model given either plug-in-gait or an IOR marker data. In addition, there is an example that shows you how to construct your own FBOS model using example data. The FBOS is described in these papers:

  - Sloot LH, Millard M, Werner C and Mombaur K (2020) Slow but Steady: Similar Sit-to-Stand Balance at Seat-Off in Older vs. Younger Adults. Front. Sports Act. Living 2:548174. doi: 10.3389/fspor.2020.548174

  - Millard M & Sloot LH (2024) The basis of balance analysis: the functional base of support provided by the human foot. (in preparation)


All of the code and files in this repository are covered by the license mentioned in the SPDX file header which makes it possible to audit the licenses in this code base using the ```reuse lint``` command from https://api.reuse.software/. A full copy of the license can be found in the LICENSES folder. To keep the reuse tool happy even this file has a license:

 SPDX-FileCopyrightText: 2024 Matthew Millard <millard.matthew@gmail.com>

 SPDX-License-Identifier: MIT

Please note that csv files in the data folder do not have license headers though these files are also offered under the MIT license.

# Quick start
1. Make sure that the data folder contains:

    Data_PiG_IOR_Static.mat  (in data/staticMarkerData folder)
    normBosModelIorShod.csv  (in data/normBosModel folder)
    normBosModelPigShod.csv  (in data/normBosModel folder)
    normBosModelIorBare.csv  (in data/normBosModel folder)
    normBosModelPigBare.csv  (in data/normBosModel folder)

2. Set the Matlab path to the main location of the local repository (you can see the folders 'code','data' and 'output').

3. Run main_testPiGFunctionalBosModel.m
	This function calculates a fBOS model ...

4. You should see a plot that contains:

  a. The markers from 'Data_PiG_IOR_Static.mat' 
  b. The foot frame location for the Ior marker set (blue, red, green dashed lines) and the Pig marker set (solid lines)
  c. The functional bos model for the Ior marker set (dashed blue) and the Pig marker set (solid magenta)

5. For an example of how to **apply** the functional base of support model to your own work, please run and carefully read the following example files. Make sure your path is set correctly to the main location of the local repository.
  a. main_iorBosExample.m
  b. main_pigBosExample.m

After going through the code in these two examples (the comments will direct you to the relevant sections) you will be able to calculate the location of the FBOS model in your own data.

5. For an example of how to **create** a FBOS model from data try running main_bosModelConstructionExample.m. If you are interested in creating your own FBOS model you will need to perform the experiments that are described in the publications mentioned in the description.
