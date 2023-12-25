Preparing the Pi

On the python side two packages need to be installed.  Both of these were available in the repositories for my RaspberryPi-OS (64bit).  I believe all this software could be installed using Add/Remove software from the Pi preferences menu.

Bitstring allows us to unpack the 13 bit temperatures in the Bluetooth advertisement
sudo apt install python3-bitstring
Bleak is the library that allows us to access the Bluetooth advertisements
sudo apt install python3-bleak 

On the R side we need to install the base R package
sudo apt install r-base-core

And then 3 R packages including shiny, the web application framework.  Lubridate eases the conversion from UTC time to local time, while viridislite provides a palate for graphs that is color-blind friendly.
sudo apt install r-cran-shiny
sudo apt install r-cran-lubridate
sudo apt install r-cran-viridislite

Install the github software into a directory of your choice.  I used on called Rcombust, but the specific name should not matter.  So now I have a directory called Rcombust that contains the files BLEreader.py and start.R.  The directory also has a subdirectory called CPT, and that directory contains the app.R (that’s the shiny app).  

Something like this...
Rcombust
     | ->CPT
             app.R
    BLEreader.py
    start.R

To start things up, open two terminal windows in the Rcombust directory (you may have to type: cd Rcombust).  In the first terminal type: 
python BLEreader.py

This immediately starts up a script that reads Bluetooth advertisements.  If you CPT is nearby and on you should see things like:

C2:71:0D:46:63:F0

Raw data :0x01ff560010312366c48c9961337206d2b81b00e00000

Type 01

ID Code : ff560010

0x1bb8d206723361998cc4662331

1703455739.070 75.8 71.6 70.2 70.0 69.7 69.5 69.5 69.5 

Mode : 0b00

-----------------------------------------------

You don’t need to worry about any of this output, but if you are curious is contains the address of the Bluetooth sender, the original advertisement, etc.  Most relevant is the second to the last line, which is the decoded line with UTC time (seconds since Jan. 01, 1970) and the temperatures of the 8 sensors in the probe.  You may also see something like:

C2:71:0D:46:63:F0

Raw data :0x01ff5600103103000000000000000000000001c00000

Type 01

ID Code : ff560010

0x00000000000000000000000331

1703455739.193 -4.0 -4.0 -4.0 -4.0 -4.0 -4.0 -4.0 69.5 

Invalid

Mode : 0b00

-----------------------------------------------
This seems to be an invalid advertisement, as most of the temperature data bits are 0 (-4 degrees F after translation).  I drop any advertisement that contains any temperature data with a bits = 0. It seems strange that they would spend energy sending out invalid advertisements, but perhaps it is a hardware limitation.  

Now switch to the second terminal and type:
./start.R

This starts the shiny app and you should soon see the interface.  It may take it up to a minute to capture enough data to populate the graphs. 

If you try these scripts on a windows computer (and yes, if you have a Bluetooth compatible computer these scripts should work in a python environment), start.R won’t work.  Windows and Linux differ in how they retrieve the local IP number.  The alternative is to start the shiny app manually.  In the terminal type:
R
library(shiny)
runApp('CPT', port=7775, host='your_local_IP_address') 

R starts an R console.  library(shiny) loads shiny into that console.  The runApp() is a shiny function to start the shiny app.  It take two arguments, a port number and your local IP address.  On linux you find your local IP address with ifconfig, but on windows one uses ipconfig and the format of the result is different (hence the problem with start.R).  On windows run ipconfig and look for the line starting with ‘IPv4 Address’.  It should be something like “192.168.1.32’.  So your runApp line would be:
runApp(‘CPT’, port=7775, host=’192.168.1.32’)

Viewing the shiny webpage.
If all went well, you should now be able to use a browser from any computer, tablet or phone attached to your local network.  Open the browser and enter ‘http://192.168.1.32:7775’ (or whatever your Pi’s local IP address is) into the address bar.  Note that you apparently can’t use a secure (“https:”) connection.  Enjoy the roast when it’s done!

On persistence
According to Murphy’s law, anything that can go wrong will go wrong.  The shiny app undoubtedly has bugs, your computer might crash, the power might go off.  The BLEreader script is constantly writing data to the hard drive,  both the latest temperature data (CombustComm.csv) as well as a data file with all the temperatures from the current cook (CombustCommCont.csv).  If something goes awry, just restart the shiny app (./start.R), perhaps also BLEreader.py if it has also stopped.  The app will read all the data from the current cook and continue on it’s way.  The down side of this persistence is that the app will gladly read in data from that cook 2 weeks ago and begin adding the current cook to the old cook.  Not what you wanted, eh?  The simplest solution is to just delete the two data files (CombustComm.csv and CombustCommCont.csv). The new cook will start afresh.  Another option that I’ve found useful is to rename the data files to, say Roast1.csv and Roast1Cont.csv.   In the future, if I ever want to review that cook, I can just copy those files to CombustComm.csv and  CombustCommCont.csv.  DON’T start BLEreader.py (it will start adding new data to these old files), just run start ./start.R and you will see all the old data and graphs from the rib roast you cooked two years ago.  If you are the organized sort, you might also add a text file with notes from the cook.  If I had that I might have noticed that my guests preferred a rib roast somewhat more done than myself.  Well, that and the fact that my probe placement was off and didn’t include the true core temp.  
