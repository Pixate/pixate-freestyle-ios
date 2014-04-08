cat <<EOF
@import "misc.css";
EOF

for name in $(ls fa-*); do
    NAME=`echo "$name" | cut -d'.' -f1`
    cat <<EOF
.$NAME {
    background-image: url($NAME.svg);
}
EOF
done

