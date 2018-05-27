/*
This is the C part of the VZMQ - package allowing to pass ZMQ messages
from software to the GHDL simuulation.
Code written by Wojciech M. Zabolotny (wzab01<at>gmail.com or
wzab<at>ise.pw.edu.pl)
Published as PUBLIC DOMAIN or under Creative Commons CC0 license
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <zmq.h>

int zmq_smax=0, zmq_rmax=0;
void *ctx = NULL;
unsigned int mprio;
void *socket = NULL;
int rc=-1;

void init_zmq_server_c(const int i_zmq_smax,const int i_zmq_rmax)
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

void zmq_get_message_c(int nmax,int * nact,unsigned char *buf)
{
  int msize;
  unsigned char rbuf[zmq_rmax];
  if(nmax > zmq_rmax) {
    fprintf(stderr,"Too many bytes requested %d>%d\n",nmax,zmq_rmax);
    *nact=-1;
    return;
  }
  msize = zmq_recv (socket,rbuf,nmax, ZMQ_DONTWAIT);
  if(msize<0) {
    if(errno==EAGAIN) {
      *nact = 0;
      return;
    }
    perror("receive error ");
    fprintf(stderr,"Can't receive %d\n",msize);
    *nact=msize;
    return;
  } else {
    fprintf(stderr,"Received message of length: %d\n",msize);
    int i,j;
    for(i=0;i<msize;i++) {
      fprintf(stderr,"%c",rbuf[i]);
      for(j=0;j<8;j++)
        if(rbuf[i] & (1<<j))
          buf[i*8+j]=3;
        else
          buf[i*8+j]=2;
    }
    fprintf(stderr,"\n");
    *nact=msize;
    return;
  }
}

void zmq_put_message_c(int msize,int * nact,unsigned char *buf)
{
  int res=0,i,j;
  unsigned char wbuf[zmq_smax];
  //Check if the number of transmitted bytes is correct
  if(msize > zmq_smax) {
    fprintf(stderr,"Too many bytes requested %d>%d\n",msize,zmq_smax);
    *nact=-1;
    return;
  }
  //Translate the message from bit vector to bytes
  for(i=0;i<msize;i++) {
    wbuf[i] = 0;
    for(j=0;j<8;j++)
      if(buf[8*i+j]==3)
        wbuf[i] |= (1<<j);
  }
  res = zmq_send(socket,wbuf,msize, 0);
  if(res<0) {
    perror("transmit error ");
    fprintf(stderr,"Can't receive %d\n",res);
    *nact=res;
    return;
  } else {
    *nact=res;
    return;
  }
}


