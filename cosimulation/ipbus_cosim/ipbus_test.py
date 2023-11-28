#!/usr/bin/python

import cbus
nodes=cbus.cbus_read_nodes('ipbus_test.xml')
ival1=nodes['IVAL1']
ival2=nodes['IVAL2']
ival3=nodes['IVAL3']
oval1=nodes['OVAL1']
oval2=nodes['OVAL2']
oval3=nodes['OVAL3']
buggy=nodes['BUGGY']
cbus.bus_delay(250)
oval1.write(0x13)
oval2.write(0x7)
oval3.write(0x31230000)
cbus.bus_delay(250)
print(hex(ival1.read()))
print(hex(ival2.read()))
print(hex(ival3.read()))
#Access below should generate an exception
buggy.write(3)


