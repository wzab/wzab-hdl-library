# fifo_to_udp - VHDL block for sending data from FIFO as a UDP package

That block allows you to receive the data from a queue and send it via Ethernet as a UDP package.
The block handles only transmission of data, so you must provide it with the information
about both (senders and receivers) MAC addresses and IP addresses.
The block needs an information about the number of data bytes available in the FIFO.
It also needs an information about the number of bytes it is allowed to put into a single UDP packet.
The block starts to send data after it receives a "send" pulse.
During the transmission, the "busy" output is asserted.


