#! /bin/sh

for f in $1/*.css
do
    f_base=$(basename "${f}" .css)
    echo "\n/** ${f_base} **/\n"
    cat "${f}"
    echo "\n/** End of ${f_base} **/\n"
    echo "\n"
done

