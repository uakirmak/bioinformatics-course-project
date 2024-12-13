use strict;
use warnings;
my $file = $ARGV[0];
open(FILE, "<$file") || die "cannot open $file\n";

# Extract file name and extension
my ($name, $ext) = $file =~ /^(.+)\.([^.]+)$/;
open(OUT1, ">$name\_1.$ext") || die "cannot open $name\_1.$ext\n";
open(OUT2, ">$name\_2.$ext") || die "cannot open $name\_2.$ext\n";
while(<FILE>){
    chomp;
    print OUT1 "$_\/1\n";
    print OUT2 "$_\/2\n";
    my $newline = <FILE>; chomp($newline);
    print OUT1 substr($newline, 0, length($newline)/2)."\n";
    print OUT2 substr($newline, length($newline)/2, length($newline)/2)."\n";
    $newline = <FILE>; chomp($newline);
    print OUT1 "$newline\/1\n";
    print OUT2 "$newline\/2\n";
    $newline = <FILE>; chomp($newline);
    print OUT1 substr($newline, 0, length($newline)/2)."\n";
    print OUT2 substr($newline, length($newline)/2, length($newline)/2)."\n";
}
close(FILE);
close(OUT1);
close(OUT2);

# Remove the original file
unlink($file) or warn "Could not unlink $file: $!";

