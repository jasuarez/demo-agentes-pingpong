#!/bin/sh

SALIDA="./benchmark/monoLoad$1.txt"
MEM=256m

echo "##############################################################" > $SALIDA
echo "## java -server -Xmx$MEM jade.Boot -container cliserv:pingpong.jade.ClienteyServidorLoad($1)  " >> $SALIDA
echo "##                                                            " >> $SALIDA
echo "## Por $(whoami) ($(date))                                    " >> $SALIDA
echo "##############################################################" >> $SALIDA
echo >> $SALIDA

java -server -Xmx$MEM jade.Boot -container cliserv:pingpong.jade.ClienteyServidorLoad\($1\) | tee -a $SALIDA
