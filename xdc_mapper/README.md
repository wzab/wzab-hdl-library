The xdc_map.py is the very simple utility allowing you to automatically generate the XDC file for the design where a chip is connected via a set of interface board and cables.
For each intermediate interface you need to create a mapping CSV file, where a single row describes a single connection.
Then you create a translators' chain, where you can define the columns in the CSV rows and the translation function.
The translation function takes care for slight modification of the pin names.
In the attached example data you can define to which FMC connector is your chip connected. You modify it by uncommenting one of the following lines:
    #[2,lambda x: x.replace("LA2_","").replace("HB2_","")],
(when it is in the second FMC connecxtor)
    [2,lambda x: x.replace("LA1_","").replace("HB1_","")],
(when it is in the first FMC connecxtor)

The tool itself is published as PUBLIC DOMAIN or under CC0 license.

The attached data are provided only to demonstrate the functionality (they are taken from a sample boards that I was using right now, with the schematic diagrams publically available in the Internet).

The tools is very simple and has minimalistic error detection. To configure it you must manually modify the code. However, it appeared a convenient tool saving the time, and allowing me to avoid mistakes when preparing pinout XDC files.

The tool was first published in the usenet alt.spurces group. You can find the post in the Google archive: https://groups.google.com/forum/#!topic/alt.sources/_8ScVn-ZweU
