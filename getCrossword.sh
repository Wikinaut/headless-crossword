#!/bin/bash

#	fetch a daily crossword puzzle web page
#	extract the puzzle (svg) and convert it to pdf.
#	create a single-pdf collection of the daily puzzles.
#	use Chromium headless for a perfect conversion
#
#	requires: chromium, pdftk, pdfjam
#
#	20180512 initial version

#	where the pdfs and html are written and can be accessed:
# 	web root

dir="/var/www/html/xword"


NOW="$(date "+%Y%m%d")"
YESTERDAY="$(date "+%Y%m%d" -d "yesterday")"

yesterfile="${dir}/${YESTERDAY}.pdf"
collectionfilename="xword-collection.pdf"
collection="${dir}/$collectionfilename"

outf="${dir}/${NOW}"
outpdf=${outf}.pdf

# Fetch the daily crossword web page.
# Extract the <svg>...</svg> crossword page part
# Write a temporary html, which can be viewed and printed in the browser.

userAgent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0) Gecko/20100101 Firefox/60.0";

curl -H '$userAgent' -sS https://www.sz-online.de/unterhaltung/spiele/kreuzwortraetsel | \
	sed -n '1h;1!H;${;g;s/^.*\(<svg id.*svg>\).*$/<meta charset=\"utf-8\" \/>\1/g;p;}' > "${outf}.html"

# "heart" (core) of the script:
# render the <svg> part to pdf using a headless browser
chromium --headless --disable-gpu --print-to-pdf="${outpdf}" "${outf}.html" 1>/dev/null 2>&1

# as chromium-headless only produces letter-sized output, we have to convert to A4
pdfjam --quiet --a4paper "${outf}.pdf" --outfile "${outpdf}"

# margin left top right bottom
pdfcrop --margins '25 20 -100 -145' --clip "${outpdf}" "${outpdf}.crop" 1>/dev/null 2>&1
mv "${outpdf}.crop" "${outpdf}"


# clean-up temporary html file
rm "${outf}.html"

# "collection": put all daily pdfs together into one pdf file
pdftk $(find ${dir} -type f \( -regextype posix-extended -regex ".*/[0-9]{8}.pdf" \) | sort -rn) cat output "$collection"


# pdfs of crossword puzzles of the previous n days

for i in `seq 0 7`; do
	eval d${i}=${dir}/"$(date "+%Y%m%d" -d "$i day ago")".pdf
done

if [ -f $d0 ] && [ -f $d1 ] && [ -f $d2 ] && [ -f $d3 ] && [ -f $d4 ] && [ -f $d5 ] && [ -f $d6 ] && [ -f $d7 ];  then
	eightdays=${dir}/${NOW}-8days.pdf
	pdftk $d0 $d1 $d2 $d3 $d4 $d5 $d6 $d7 cat output $eightdays  
	pdfjam --quiet --a4paper $eightdays --outfile $eightdays
	pdfjam-pocketmod $eightdays --quiet --outfile ${dir}/${NOW}-8days-pocketmod.pdf
fi

if [ -f $d0 ] && [ -f $d1 ] && [ -f $d2 ] && [ -f $d3 ] && [ -f $d4 ] && [ -f $d5 ] && [ -f $d6 ];  then
	pdftk $d0 $d1 $d2 $d3 $d4 $d5 $d6 cat output ${dir}/${NOW}-7days.pdf  
fi

if [ -f $d0 ] && [ -f $d1 ] && [ -f $d2 ] && [ -f $d3 ] && [ -f $d4 ] && [ -f $d5 ];  then
	pdftk $d0 $d1 $d2 $d3 $d4 $d5 cat output ${dir}/${NOW}-6days.pdf  
fi

if [ -f $d0 ] && [ -f $d1 ] && [ -f $d2 ] && [ -f $d3 ] && [ -f $d4 ];  then
	pdftk $d0 $d1 $d2 $d3 $d4 cat output ${dir}/${NOW}-5days.pdf  
fi

if [ -f $d0 ] && [ -f $d1 ] && [ -f $d2 ] && [ -f $d3 ];  then
	pdftk $d0 $d1 $d2 $d3 cat output ${dir}/${NOW}-4days.pdf  
fi

if [ -f $d0 ] && [ -f $d1 ] && [ -f $d2 ];  then
	pdftk $d0 $d1 $d2 cat output ${dir}/${NOW}-3days.pdf  
fi

if [ -f $d0 ] && [ -f $d1 ];  then
	pdftk $d0 $d1 cat output ${dir}/${NOW}-2days.pdf
fi

# zip -j -q ${dir}/${NOW}-allfiles.zip ${dir}/*.pdf
zip -j -q ${dir}/allfiles.zip ${dir}/*.pdf
