#!/bin/sh

SALIDA="./benchmark/mono$1.txt"

echo "##############################################################" > $SALIDA
echo "## ./bin/ClienteyServidor -n $1                               " >> $SALIDA
echo "##                                                            " >> $SALIDA
echo "## Por $(whoami) ($(date))                                    " >> $SALIDA
echo "##############################################################" >> $SALIDA
echo >> $SALIDA

./bin/ClienteyServidor -n $1 | tee -a $SALIDA
