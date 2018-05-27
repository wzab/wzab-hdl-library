/*-------------------------------------------------------------------------------
 -- Title      : Package vzmq 
 -- Project    : 
 -------------------------------------------------------------------------------
 -- File       : vzmq_tb.vhd
 -- Author     : Wojciech M. Zabolotny (wzab01<at>gmail.com or wzab<at>ise.pw.edu.pl
 -- Company    : Institute of Electronic Systems
 -- License    : Public Domain or Creative Commons CC0
 -- Created    : 2018-05-20
 -- Last update: 2018-05-24
 -- Platform   : 
 -- Standard   : VHDL'93
 -------------------------------------------------------------------------------
 -- Description: vzmq - package for passing ZMQ messages to GHDL or XSIM simulation
 -------------------------------------------------------------------------------
 -- Copyright (c) 2016,2018 
 -------------------------------------------------------------------------------
 -- Revisions  :
 -- Date        Version  Author  Description
 -- 2018-05-20  1.0      wzab    Created
 -------------------------------------------------------------------------------
 */
module vzmq # (parameter MAX_SND=16384, MAX_RCV=16384)
   ( //Sending interface
     input logic [8*MAX_SND-1:0] 	snd_msg,
     input logic 		snd_stb,
     input logic [31:0] 	snd_bytes,
     output logic 		snd_ack,
     //Receiving interface
     input logic 		rcv_stb,
     output logic 		rcv_ack,
     output logic [8*MAX_RCV-1:0] rcv_msg ,
     output logic [31:0] 	rcv_bytes
     );
   
   import "DPI-C" function void init_zmq_server_c(int max_send, int max_receive);
   import "DPI-C" task zmq_get_message_c (input int nmax,
					  output int nact, inout logic [8*MAX_RCV-1:0] v1);
   import "DPI-C" task zmq_put_message_c (input int msize, output int nact,
					  input logic [8*MAX_SND-1:0] v1);

   integer 							    act_snd;
   integer 							    act_rcv;
   
   
   
   initial begin
      init_zmq_server_c(MAX_SND,MAX_RCV);
   end

   always @ (snd_stb) begin
      //$displayh(snd_msg,";");
      zmq_put_message_c(snd_bytes,act_snd,snd_msg);
      if (act_snd >= 0)
	snd_ack <= 1;
      else
	snd_ack <= 0;      
   end

   always @ (rcv_stb) begin
      zmq_get_message_c(MAX_RCV,act_rcv,rcv_msg);      
      rcv_bytes <= act_rcv;
      if (act_rcv > 0)
	rcv_ack <= 1;
      else
	rcv_ack <= 0;
   end
   
endmodule
