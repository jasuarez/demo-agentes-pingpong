#!/bin/sh

SALIDA="./benchmark/monoLoad$1.txt"

echo "##############################################################" > $SALIDA
echo "## ./bin/ClienteyServidorLoad -n $1                           " >> $SALIDA
echo "##                                                            " >> $SALIDA
echo "## Por $(whoami) ($(date))                                    " >> $SALIDA
echo "##############################################################" >> $SALIDA
echo >> $SALIDA

./bin/ClienteyServidorLoad -n $1 | tee -a $SALIDA
