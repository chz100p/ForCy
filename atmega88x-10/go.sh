#!/bin/sh

./fcy -e fcc.f < $1.txt
./fcy usrprg.f
rm usrprg.f
