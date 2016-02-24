#!/bin/sh

SALIDA="./servidor.log"

echo "##############################################################" > $SALIDA
echo "## ./bin/ServidorLoad -n $1                                   " >> $SALIDA
echo "##                                                            " >> $SALIDA
echo "## Por $(whoami) ($(date))                                    " >> $SALIDA
echo "##############################################################" >> $SALIDA
echo >> $SALIDA

./bin/ServidorLoad -n $1 | tee -a $SALIDA
