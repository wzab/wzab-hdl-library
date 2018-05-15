#!/usr/bin/python3
"""
This is a simple script for creating the XDC mapping from the series of CSV files
describing the interface boards and cables used to connect the target chip
or device with the FPGA.
Please note, that the script is very simplified and there is no good error 
detection.

Written by Wojciech M. Zabolotny (wzab@ise.pw.edu.pl) 11.07.2017
License: PUBLIC DOMAIN of CC0 (whatever is more convenient for you)
"""

import csv
def read_csv(fname,cols):
    """
    The read_csv accepts two arguments.
    fname - name of the csv file to read
    cols - two element list describing position and transformation function
    
    """
    res={}
    for i in range(0,2):
        if len(cols[i])==1:
            cols[i].append(lambda x: x)
    #print(cols)
    with open(fname, newline='') as csvfile:
         myreader = csv.reader(csvfile, delimiter=',', quotechar='\"')
         for row in myreader:
             rkey=cols[0][1](row[cols[0][0]])
             rval=cols[1][1](row[cols[1][0]])
             if res.__contains__(rkey):
                 #raise(Exception("Duplicated pin:"+rkey))
                 print("Warning! Duplicated pin:"+rkey)
             res[rkey]=rval
    return res

# We create the chain of dictionaries starting from the one defining the 
# desired connection of the target chip to the FPGA
dicts=[]
dicts.append(read_csv('sts-xyter-feba.csv',(
        [0,],
        [1,],
)))
dicts.append(read_csv('feba.csv',(
        [0,],
        [1,],
)))
# We assume, that the cable provides 1 to 1 connection
# Therefore there is no CSV for the cable
dicts.append(read_csv('gDPB.csv',(
        [0,lambda x: str.replace(x,"G3-","X11-")],
        [3,],
)))
#If our gDPB is in FMC2, we remove LA2_ and HB2_ prefixes in pin definitions
dicts.append(read_csv('pinout.csv',(
        #[2,lambda x: x.replace("LA2_","").replace("HB2_","")],
        [2,lambda x: x.replace("LA1_","").replace("HB1_","")],
        [0  ,],
)))
#Now we open the output constraints file
fxdc=open("sts_xyter_gDPB.xdc","w")
#Now we can do the translation, but we first sort the keys
pins=list(dicts[0].keys())
pins.sort()
for pin in pins:
    print(pin)
    key=pin
    for i in range(0,len(dicts)):
        key=dicts[i][key]
        print("->"+key)
    #Now write the lines to the output XDC
    fxdc.write("set_property PACKAGE_PIN %s [get_ports {%s}]\n" % (key, pin))
    fxdc.write("set_property IOSTANDARD LVDS_25 [get_ports {%s}]\n" % pin)
fxdc.close()  
