#!/usr/bin/bash
ruby sim.rb N 30 156231 ArrivalRate.dat ArrivalRate.dat carRates.dat carRates.dat logOut.dat
ruby xWalkGraphics.rb logOut.dat