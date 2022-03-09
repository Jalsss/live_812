find . -type f -name '*.png' | while read FILE ; do
    newfile="$(echo ${FILE} |sed -e 's/210/24/')" ;
    mv "${FILE}" "${newfile}" ;
done 
