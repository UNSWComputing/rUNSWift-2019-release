#!/usr/bin/perl -w

unless (exists($ENV{RUNSWIFT_VERSION})) {
   $ENV{RUNSWIFT_VERSION} = `cd $ENV{RUNSWIFT_CHECKOUT_DIR} && git describe --always`;
}

print "#include <string>\n";
my $tag = $ENV{RUNSWIFT_VERSION};
chomp $tag;
print "std::string git_version = \"$tag\";\n";

