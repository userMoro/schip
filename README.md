# SCHIP
To automate and simplify the process of setting up and building the matter environment the chip-tool executable for a linux controller and an example application for raspberry pi (lighting-app as default) capable of translating on/off messages in GPIO on/off on pin 17.

With schip you will be able see which prerequisites are needed, which prerequisites are satisfied and finally set up and install everything you need easily.

# How to use 
To use schip funtionalities you need to run ./schip.sh [...] inside the 'setup' folder; 

Use ./schip.sh -h to visualize all the disposable functionalities and command to execute.

if you haven't cloned connectedhomeip repo yet, schip will guide you into that in the update operation.
If you already did, place connectedhomeip in the folder 'schip', near the folder 'setup', before preceeding with other operations

# More
After building an app to use (for device or controller) using "./schip.sh -u -d/-c", a copy will be placed in the "executables" folder.

You can then decide to use those executables directly from there. 
To check the usage of the executables, execute the file without arguments.
