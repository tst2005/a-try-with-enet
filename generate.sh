#!/bin/sh

echo '#include "enet/enet.h"' > tmp.c

(
echo "\
typedef unsigned int u_int;
typedef unsigned long u_long;

typedef u_int SOCKET;
typedef struct fd_set {
  u_int fd_count;
  SOCKET fd_array[64];
} fd_set;

"
./CParser/lcpp  -I/usr/include tmp.c
# | grep -v '^#line'
# | grep -v '^#include <'
) > enet.h
#rm -f -- tmp.c
