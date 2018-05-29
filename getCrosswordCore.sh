#!/bin/bash
# dummy code
# emergency stop
exit

#	fetch a daily crossword puzzle web page
#	extract the puzzle (svg) and convert it to pdf.
#	use Chromium headless for a perfect conversion

webpage="https://www.sz-online.de/unterhaltung/spiele/kreuzwortraetsel"

curl -sS $webpage -o webpage.html
sed -n '1h;1!H;${;g;s/^.*\(<svg id.*svg>\).*$/<meta charset=\"utf-8\" \/>\1/g;p;}' webpage.html > webpage.svg.html

# This is the core of the script:
chromium --headless --disable-gpu --print-to-pdf=webpage.pdf webpage.svg.html

# scale to DIN A4
pdfjam --quiet --a4paper webpage.pdf --outfile webpage.a4.pdf

# crop margin left top right bottom
pdfcrop --margins '25 20 -100 -145' --clip webpage.pdf cropped.pdf
