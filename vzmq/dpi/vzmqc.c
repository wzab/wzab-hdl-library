/*
  This is the C part of the VZMQ - package allowing to pass ZMQ messages
  from software to the GHDL or XSIM simuulation.
  Code written by Wojciech M. Zabolotny (wzab01<at>gmail.com or
  wzab<at>ise.pw.edu.pl)
  Published as PUBLIC DOMAIN or under Creative Commons CC0 license
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <zmq.h>
#include "vzmq.h"

static int zmq_smax=0, zmq_rmax=0;
static void *ctx = NULL;
static unsigned int mprio;
static void *socket = NULL;
static int rc=-1;
DPI_LINKER_DECL DPI_DLLESPEC 
void init_zmq_server_c(int i_zmq_smax,int i_zmq_rmax)
{
  zmq_smax = i_zmq_smax;
  zmq_rmax = i_zmq_rmax;
  ctx = zmq_ctx_new ();
  assert (ctx);
  /* Create ZMQ_STREAM socket */
  socket = zmq_socket (ctx, ZMQ_PAIR); //When it was ZMQ_REP, I couldn't repeat call
  assert (socket);
  rc = zmq_bind (socket, "ipc://mystream2");
  assert (rc == 0);
}

void close_zmq_server(int ile)
{
}

DPI_LINKER_DECL DPI_DLLESPEC int 
zmq_get_message_c(int nmax,int * nact,svLogicVecVal buf[])
{
  //svBitVecVal * buf=(svBitVecVal *) vbuf;
  int msize;
  unsigned char rbuf[zmq_rmax];
  if(nmax > zmq_rmax) {
    fprintf(stderr,"Too many bytes requested %d>%d\n",nmax,zmq_rmax);
    *nact=-1;
    return 0;
  }
  msize = zmq_recv (socket,rbuf,nmax, ZMQ_DONTWAIT);
  if(msize<0) {
    if(errno==EAGAIN) {
      //fprintf(stderr,"No data %d\n",msize);
      *nact = 0;
      return 0;
    }
    perror("receive error ");
    fprintf(stderr,"Can't receive %d\n",msize);
    *nact=msize;
    return 0;
  } else {
    fprintf(stderr,"Received message of length: %d\n",msize);
    int i,j,k;
    for(i=0;i<msize;i++) {
      k=8*i;
      fprintf(stderr,"%c",rbuf[i]);
      for(j=0;j<8;j++) {
        if(rbuf[i] & (1<<j))
          svPutBitselLogic(buf,k+7-j,sv_1);
        else
          svPutBitselLogic(buf,k+7-j,sv_0);
       }
    }
    fprintf(stderr,"\n");
    *nact=msize;
    return 0;
  }
}

DPI_LINKER_DECL DPI_DLLESPEC int 
zmq_put_message_c(int msize,int * nact,const svLogicVecVal buf[])
{
  //svBitVecVal * buf=(svBitVecVal *) vbuf;
  int res=0,i,j,k;
  unsigned char wbuf[zmq_smax];
  //Check if the number of transmitted bytes is correct
  if(msize > zmq_smax) {
    fprintf(stderr,"Too many bytes requested %d>%d\n",msize,zmq_smax);
    *nact=-1;
    return 0;
  }
  //Translate the message from bit vector to bytes
  for(i=0;i<msize;i++) {
    k=8*i;
    wbuf[i] = 0;
    for(j=0;j<8;j++)
      if(svGetBitselLogic(buf,k+7-j)==sv_1)
        wbuf[i] |= (1<<j);
  }
 res = zmq_send(socket,wbuf,msize, 0);
  if(res<0) {
    perror("transmit error ");
    fprintf(stderr,"Can't receive %d\n",res);
    *nact=res;
    return 0;
  } else {
    *nact=res;
    return 0;
  }
}


