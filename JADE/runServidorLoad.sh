#!/bin/sh

SALIDA="./servidor.log"
MEM=256m

echo "##############################################################" > $SALIDA
echo "## java -server -Xmx$MEM jade.Boot -container serv:pingpong.jade.ServidorLoad($1)  " >> $SALIDA
echo "##                                                            " >> $SALIDA
echo "## Por $(whoami) ($(date))                                    " >> $SALIDA
echo "##############################################################" >> $SALIDA
echo >> $SALIDA

java -server -Xmx$MEM jade.Boot -container serv:pingpong.jade.ServidorLoad\($1\) | tee -a $SALIDA
