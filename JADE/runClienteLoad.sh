#!/bin/sh

SALIDA="./benchmark/multiLoad$1.txt"
MEM=256m

echo "##############################################################" > $SALIDA
echo "## java -server -Xmx$MEM jade.Boot -container cli:pingpong.jade.ClienteLoad($1)  " >> $SALIDA
echo "##                                                            " >> $SALIDA
echo "## Por $(whoami) ($(date))                                    " >> $SALIDA
echo "##############################################################" >> $SALIDA
echo >> $SALIDA

java -server -Xmx$MEM jade.Boot -container cli:pingpong.jade.ClienteLoad\($1\) | tee -a $SALIDA
