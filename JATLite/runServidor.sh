#!/bin/sh

SALIDA="./servidor.log"
MEM=256m

echo "##############################################################" > $SALIDA
echo "## java -server -Xmx$MEM pingpong.jatlite.Servidor $1         " >> $SALIDA
echo "##                                                            " >> $SALIDA
echo "## Por $(whoami) ($(date))                                    " >> $SALIDA
echo "##############################################################" >> $SALIDA
echo >> $SALIDA

rm -f incoming/* ; java -server -Xmx$MEM pingpong.jatlite.Servidor $1 | tee -a $SALIDA
