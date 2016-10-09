#!/usr/bin/perl
#  YDLCreator.pl
#
#  Copyright 2016 Robert Bakaric <rbakaric@exaltum.eu>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#


use strict;

use Getopt::Long;
use YDL::Compute;
use YDL::Draw;

=head1 NAME

YDLCreator - Young Diagram Lattice Calculator

=head1 SYNOPSIS

    use YDL::Compute;
    use YDL::Draw;

    my $YDLcomp = YDL::Compute->new();
    my $YDLdraw = YDL::Draw->new();

    # -----        Compute YDL        ----- #
    my $compute = $YDLcomp->YDLCompute(states => $N);

    # -----     Get YDL  lattice      ----- #
    $l = $compute->GetLattice();

    # -----    Parse YDL  lattice     ----- #
    my $table = ParseLattice($l);
    sub ParseLattice {

    	my ($array) = @_;
      my %latt;

    	foreach my $part (@{$array}){
    		my @x = split("\t", $part);
    		push(@{$latt{$x[1]}}, $x[0]);
    	}
    	return \%latt;
    }

    # -----        Draw YDL        ----- #
    # $conf = [N, 0,0,..,0(N-1)]
    $YDLdraw->YDLDraw(start => $conf,  lattice => $table);


=head1 DESCRIPTION

In mathematics, Young's lattice is a partially ordered set of Young diagrams
that is formed by connecting all integer partitions of a given diagram. It was
named after Alfred Young, who developed the representation theory of the symmetric
groups. In Young's theory, the objects (now called Young diagrams) can be partially
ordered by inclusion resulting in a so called partially ordered set termed Young's
lattice.

Moreover, given M^l it is possible to extract a complete list of irreducible
subrepresentations (S^l) form a complete list as l varies over all possible
partitions. Here one such set is computed and its representation illustrated
using a Hesse diagram:


                            A
                            |
                            B
                          /   \
                        C       D
                          \   /
                            E
                            |
                            F
                            |
                            G

Where A, B, ...G are Young diagrams depicting a given partition.




=head1 AUTHOR

Robert Bakaric <rbakaric@exaltum.eu>

=head1 LICENSE


#  Copyright 2016 Robert Bakaric <rbakaric@exaltum.eu>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#

=head1 ACKNOWLEDGEMENT


      1. William Fulton (1997) Young Tableaux: With Applications to
      Representation Theory and Geometry. Cambridge University Press.

=cut

my $ydl = YDL::Compute->new();
my $yDl = YDL::Draw->new();


my ($help,$N,$verbos, $hesse, $table);
GetOptions ("n=i" => \$N,  # input
            "h" => \$help,
            "l" => \$hesse,
            "y" => \$table
            );


if($help){

print <<EOF;
 __     _______  _      _____                _
 \\ \\   / /  __ \\| |    / ____|              | |
  \\ \\_/ /| |  | | |   | |     _ __ ___  __ _| |_ ___  _ __
   \\   / | |  | | |   | |    | '__/ _ \\/ _` | __/ _ \\| '__|
    | |  | |__| | |___| |____| | |  __/ (_| | || (_) | |
    |_|  |_____/|______\\_____|_|  \\___|\\__,_|\\__\\___/|_|



                                         By Robert Bakaric

_________________________________________________________________v0.01
EOF


  print "Usage: perl ./program [options]\n\n";
  print "\t-h\tPrints this\n";
  print "\t-n\tThe number of states (def: 6)\n";
  print "\t-y\tPrint Young table (def: FALSE)\n";
  print "\t-l\tPrint Hesse diagram in Latex (def: FALSE)\n\n";

  exit(0);
}


$N = 6 unless $N;


# -----            Compute YDL             ----- #

my $conf = $ydl->YDLCompute(states => $N);

my $h = $ydl->GetPartitions();
my %hash = %$h;

print "#Summary\n#Partition\tIncom\t#OfMoreMixed\t#OfLessMixed\n";#\tDistanceFromDisorder\tDistanceFromOrder\n";
foreach my $part (keys %hash){
   my @c = split(" ",$part);
   ## FXME bugs noted!!
  # my $disdis = $ydl->DistanceFromDisorder(partition => \@c);
  # my $disord = $ydl->DistanceFromOrder(partition => \@c);
   print "$part\t$hash{$part}->[0]\t$hash{$part}->[1]\t$hash{$part}->[2]\n";#$disdis\t$disord\n";
}


my $l;


# -----          Compute YDL table          ----- #

if ($table){
  $l = $ydl->GetLattice();
  my @lattice = @$l;

  print "\n\n#YDLattice\n#Chiled\tParent\n";
  foreach my $part (@lattice){
    print "$part\n";
  }
}

# -----       Compute Hesse diagram        ----- #

if ($hesse && $table){
  my $lattFormated = ParseLattice($l);
  print "\n\n#Hesse_diagram(latex)\n";
  print "#  \\usepackage{youngtab}\n";
  print "#  \\usetikzlibrary{matrix}\n";
  print "#  \\usetikzlibrary{tikz}\n";
  $yDl->YDLDraw(start => $conf,  lattice => $lattFormated);
}



# -----         Parsing function         ----- #

sub ParseLattice {

	my ($array) = @_;

	my %latt;

	foreach my $part (@{$array}){
		my @x = split("\t", $part);
		push(@{$latt{$x[1]}}, $x[0]);
	}
	return \%latt;
}
