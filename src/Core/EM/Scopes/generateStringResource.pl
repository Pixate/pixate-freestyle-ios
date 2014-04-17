#!/usr/bin/perl

my $tab = "    ";

sub emitFile {
    my $methodName = shift;
    my $file = shift;

    print <<EOF;
+ (NSString *)$methodName
{
EOF

    open INPUT, "< $file" or die "Could not open $file: $!";

    $_ = <INPUT>;

    if ($_) {
        chomp;
        s/"/\\"/g;

        print "${tab}return @\"$_\\n\"";

        while (<INPUT>) {
            chomp;
            s/"/\\"/g;

            print "\n$tab$tab\"$_\\n\"";
        }

        print ";\n";
    }

    close INPUT;

    print <<EOF;
}

EOF
}

# main

# emit header
print <<'EOF';
//
//  PXFreestyleBuiltInSource.m
//  pixate-freestyle
//
//  Created by Kevin Lindsey on 4/17/14.
//  Copyright (c) 2014 Pixate, Inc. All rights reserved.
//

#import "PXFreestyleBuiltInSource.h"

@implementation PXFreestyleBuiltInSource

EOF

# emit emaSource
emitFile("emaSource", "built-ins.ema");

# emit emaSource
emitFile("emSource", "built-ins.em");

#emit footer
print <<'EOF';
@end
EOF
