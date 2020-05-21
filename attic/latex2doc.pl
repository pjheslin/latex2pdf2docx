#!/usr/bin/perl -w
use strict;

my $file = $ARGV[0];
$file =~ s/.tex$//;

# Run xelatex on the base file
my $err ='warning rerun LaTeX';
while ($err =~ m/warning.*re-?run/i) {
    print "Running LaTeX\n";
    $err=`xelatex -interaction=nonstopmode $file.tex`;
    if ($err =~ m/\n(\![^\n]*)\n([^\n]*)/s) {
        print "LaTeX error: $1\n$2\n";
        exit;
    }
}

# Run pfdtotext on the output
print "Running pdftotext\n";
system("pdftotext -nopgbrk $file.pdf") and die $!;

print "Munging output\n";
open IN, "<$file.txt" or die $!;
my $buf ='';
while (<IN>) {
    $buf .= $_;
}

# Remove spurious para breaks
$buf =~ s/\n\n/\n/g;

$buf =~ s/\\\\\s*\\par/\\\\/g;


# Doesn't make any difference to output
# $buf =~ s/\\par\s*\\begin\{/\\begin{/sg;

# Revert endnotes to footnotes
my @notes;
my ($doc, $note) =  split /\\end{document}\s*(?:\\par)?\s*NOTES\s*/, $buf, 2;
if ($note) {
    my $c = 1;
    while ($note =~ m/\\begin{footnotetext}(.*?)\\end{footnotetext}/sg) {
        $notes[$c] = $1;
        $c++;
    }
#  print "$_ => $notes{$_}\n\n" for sort keys %notes;
#     exit;

    $doc =~ s/\\footnotemark{\s*([^}]*)\s*}/\\footnote{$notes[$1]}/sg;
    $buf = $doc;

    $buf .= '\end{document}';
}
    
open OUT, ">$file-convert.tex" or die $!;
print OUT $buf;
close OUT or die $!;

print "Running latex2rtf\n";
# Needs a recent latex2rtf to handle unicode
# We tell it to look at fonts.cfg in this dir to get sensible Unicode-aware fonts
system("latex2rtf -P . $file-convert.tex") and die $!;

print "Generated file: $file-convert.rtf \n";

# TODO

# ellipsis


# Tips

# Search for stray curly brackets
# Check for stray whitespace around environments
