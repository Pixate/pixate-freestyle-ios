cat <<EOF
#import "IconList.h"

@implementation IconList
+(NSArray *)getList {
	return @[
EOF
for name in $(ls fa-*); do
    NAME=`echo "$name" | cut -d'.' -f1`
    cat <<EOF
		@"$NAME",
EOF
done
cat <<EOF
	];
}
@end
EOF
