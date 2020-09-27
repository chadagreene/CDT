[![DOI](https://zenodo.org/badge/171331090.svg)](https://zenodo.org/badge/latestdoi/171331090) [![View Climate Data Toolbox for MATLAB on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/70338-climate-data-toolbox-for-matlab)

![Climate Data Toolbox for Matlab](CDT_reduced.jpg)

# CDT Contents and Documentation
[**Click here**](https://www.chadagreene.com/CDT/CDT_Contents.html) to view the CDT documentation online.

# Installing the toolbox:
There are a few different ways to install this toolbox. Pick your favorite among the following:

### ...from the Add-On Explorer in MATLAB: 
In the Home menu of MATLAB, click Add-Ons, and search for Climate Data Toolbox. Click "Add from GitHub" and that's all you need to do. Installing this way is easy and will provide the most up-to-date version available. 


### ...as a .mltbx toolbox: (will almost always be outdated)
First, download the ~100 MB .mltbx file [here](https://chadagreene.com/ClimateDataToolbox.mltbx). After downloading the .mltbx file, installation should be as easy as double clicking on the zip file and clicking "install". Or you can navigate to it in the Matlab file explorer, right click on the .mltbx, and click "Install." 

The installation process puts the files in a folder called something like:

```~MATLAB/Add-Ons/Toolboxes/Climate Data Toolbox/```

If that's not correct, find the CDT folder by typing this into the Matlab Command Window: 

```which cdt -all```

If the which hunt still turns up nothing, that suggests the toolbox hasn't been properly installed. 

### ...or as individual files and folders:
The files in this GitHub repository may be slightly more up to date than the prepackaged .mltbx toolbox. So if you want to be on the bleeding edge of innovation, get the cdt folder, put it somewhere Matlab can find it, and then right-click on it from within Matlab and select "Add to Path--Selected folder and subfolders."

# After installation:
Type 

```cdt```

into the command line to check out the documentation.

# Citing CDT: 
Please cite our paper! 

Chad A. Greene, Kaustubh Thirumalai, Kelly A. Kearney, José Miguel Delgado, Wolfgang Schwanghart, Natalie S. Wolfenbarger, Kristen M. Thyng, David E. Gwyther, Alex S. Gardner, and Donald D. Blankenship (2019). The Climate Data Toolbox for MATLAB. _Geochemistry, Geophysics, Geosystems,_ 20, 3774-3781. [doi:10.1029/2019GC008392](https://doi.org/10.1029/2019GC008392)

The Climate Data Toolbox is also mirrored on the MathWorks File Exchange site [here](https://www.mathworks.com/matlabcentral/fileexchange/70338).