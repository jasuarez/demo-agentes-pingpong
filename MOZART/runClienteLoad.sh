#!/bin/sh

SALIDA="./benchmark/multiLoad$1.txt"

echo "##############################################################" > $SALIDA
echo "## ./bin/ClienteLoad -n $1                                    " >> $SALIDA
echo "##                                                            " >> $SALIDA
echo "## Por $(whoami) ($(date))                                    " >> $SALIDA
echo "##############################################################" >> $SALIDA
echo >> $SALIDA

./bin/ClienteLoad -n $1 | tee -a $SALIDA
