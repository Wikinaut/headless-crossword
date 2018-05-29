#!/bin/bash

#	fetch a daily crossword puzzle web page
#	extract the puzzle (svg) and convert it to pdf.
#
#	use Chromium headless for a perfect conversion
#
#	requires: chromium, pdftk, pdfjam
#
#	20180512 initial version

#	where the pdfs and html are written and can be accessed:
# 	web root

dir="/var/www/html/xword/daily"

NOW="$(date "+%Y%m%d")"

webpage="https://www.sz-online.de/unterhaltung/spiele/kreuzwortraetsel"

outf="${dir}/${NOW}"
outpdf=${outf}.pdf

# Fetch the daily crossword web page.
# Extract the <svg>...</svg> crossword page part
# Write a temporary html, which can be viewed and printed in the browser.

# Firefox 60.0 creates a nice screenshot with default filename "output.pdf" but requires GTK3
# so we do not want to do this:
# firefox --headless --screenshot "${outf}.00.screenshot.firefox.pdf" ${webpage}

# chromium
chromium --headless --disable-gpu --print-to-pdf="${outf}.00.webpage.screenshot.chrome.pdf" "${webpage}" 1>/dev/null 2>&1

userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0) Gecko/20100101 Firefox/60.0";

curl -H '$userAgent' -sS "${webpage}" -o ${outf}.00.webpage.curl.html
sed -n '1h;1!H;${;g;s/^.*\(<svg id.*svg>\).*$/<meta charset=\"utf-8\" \/>\1/g;p;}' "${outf}.00.webpage.curl.html" > "${outf}.01.svg.html"

# This is the core of the script:
# render the <svg> part of the webpage to pdf, use a headless browser
chromium --headless --disable-gpu --print-to-pdf="${outf}.02.svg.screenshot.chrome.pdf" "${outf}.01.svg.html" 1>/dev/null 2>&1

# as chromium-headless only produces letter-sized output, we have to convert to A4
pdfjam --quiet --a4paper "${outf}.02.svg.screenshot.chrome.pdf" --outfile "${outf}.03.svg.screenshot.chrome.a4.pdf"

# margin left top right bottom
pdfcrop --margins '25 20 -100 -145' --clip "${outf}.03.svg.screenshot.chrome.a4.pdf" "${outf}.04.svg.screenshot.chrome.a4.cropped.pdf" 1>/dev/null
cp "${outf}.04.svg.screenshot.chrome.a4.cropped.pdf" "${outpdf}"
