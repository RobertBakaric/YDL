#  Compute.pm
#
#  Copyright 2016 Robert Bakaric <robert@exaltum.eu>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
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


package YDL::Compute;

use vars qw($VERSION);
use POSIX;
$VERSION = '0.01';

use strict;
use Carp;


=head1 NAME

YDL::Compute - Young Diagram Lattice Computor

=head1 SYNOPSIS

    use YDL::Compute;

    my $YDLobject = YDL::Compute->new();

    # -----        Compute YDL        ----- #
    my $N=10;
    my $ydl = $YDLobject->YDLCompute(states => $N);
    my $n = (keys %{#ydl});

    # -----               Print result                ----- #
    print "Number of Yound Diagram Partitions: $n\n"; ## Expected result: 42


=head1 DESCRIPTION

The class is designed to compute all irreducible subrepresentations (S^l), such
that S^l forms a complete list of irreducible representations od Sn and l varies
over all partitions of n.  Moreover the class contains functions for computing the
shortest distance from a given permutation to its maximally ordered/disordered
configuration.


=head2 new

    my $YDLobject = YDL::Compute->new();


    Creates a new YDL::Compute object.


=head2 YoungCompute

    my $ydl = $YDLobject->YDLCompute(states => $N);


    Function computes the list of partitions for N.

=head2 DistanceFromDisorder

    my $ydl = $YDLobject->DistanceFromDisorder(partition => [4,3,3,2,1,0,0,0,0,0,0,0,0]);

    Function returns the number of partitions between a given partition
    ([4,3,3,2,1,0,0,0,0,0,0,0,0]) and [1,1,1,1,1,1,1,1,1,1,1,1,1,1].

=head2 DistanceFromOrder

    my $ydl = $YDLobject->DistanceFromDisorder(partition => [4,3,3,2,1,0,0,0,0,0,0,0,0]);

    Function returns the number of partitions between a given partition
    ([4,3,3,2,1,0,0,0,0,0,0,0,0]) and [13,0,0,0,0,0,0,0,0,0,0,0,0].

=head2 GetLattice

    my $ydl = $YDLobject->GetLattice();

    Function returns the lattice in a tab seperated two column table.

=head2 GetPartitions

    my $ydl = $YDLobject->GetPartitions();

    Function returns the list of partitions of [N,0,0,0,0,0,0,0,0,0,0,0,0] together
    with the associate information : #Partition
                                     #Incom
                                     #OfMoreMixed
                                     #OfLessMixed

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


      1. William Fulton (1997) Young Tableaux: With Applications to Representation
      Theory and Geometry. Cambridge University Press.

=cut



# "5 5 4 3 1 1" => [32,54,12] #number of [incomparable partitions, more mixed, less mixied]
my %partitions = ();
# "5 5 4 3 1 1" => 5 5 5 2 1 1 #child => parent
my @lattice =();



#################################################
#               CONSTRUCTOR
#################################################
#################################################
sub new {
#################################################

  my ($class)=@_;

  my $self = {};
  bless ($self,$class);
}


#################################################
#               FUNCTIONS
#################################################
#################################################
sub YDLCompute {
#################################################

   my ($self,%arg) = @_;

   my $init = $self->_ComputePartitions(states => $arg{states});
   return $init;
}




#################################################
sub _ComputePartitions {
#################################################

my ($self,%arg)= @_;

   my %hash = ();
   my $a =[];
   for(my $i = 0; $i<$arg{states}; $i++){
      $a->[$i] = 0;
   }
   $a->[0] = $arg{states};
   $hash{"@$a"} = [0,0,0];

   $self->_TreeRecurse(node=> $a, partitions =>\%hash, lattice => \@lattice);
   my @part = keys %hash;
   foreach my $p (@part){
	   my @g=(0,0,0);
	  foreach my $q (@part){
		  my @p = split(" ",$p);
		  my @q = split(" ",$q);
          my $res = $self->_Majorize(a=> \@p, b=>\@q);
          $g[$res]++;
	  }
	  $hash{$p} = \@g;
 }
 %partitions = %hash;

 return "@$a";

}


#################################################
sub _Majorize {
#################################################

my ($self,%arg)= @_;

   my @a=();
   my @b=();
   my $x =0;
   my $y =0;

   for (my $i = 0; $i< @{$arg{a}}; $i++){
	   $x+=$arg{a}->[$i];
	   $a[$i] =$x;
   }
   $x = 0;
   for (my $i = 0; $i< @{$arg{b}}; $i++){
	   $x+=$arg{b}->[$i];
	   $b[$i] =$x;
   }


   $x=0;
   for(my $i=0;$i< @a; $i++){
			 if($a[$i]> $b[$i]){
				 if($x<0){
				    $y=0;
				    last;
				}
				 $x=1;
				 $y=1;

			 }elsif ($a[$i] < $b[$i]){
				 if($x>0){
					 $y=0;
					 last;
				 }
				 $x = -1;
				 $y = -1;
			 }
		 }

   return $y == -1 ? 2 : $y;


}


#################################################
sub _TreeRecurse {
#################################################

my ($self,%arg)= @_;
   my %hash;

   my @a = @{$arg{node}};
   my @v;
   my $l =0;
   my $r = 0;
   for(my $i = 0; $i< @a-1; $i++){
	   if($a[$i] > $a[$i+1] && $a[$i]-1 > 0 && $l == 0){
		   $a[$i]--; $l=1; $r=$i;
	   }
	   if($a[$i] >= $a[$i+1]+1 && $l == 1){
		   $a[$i+1]++;
		   my @b = @a;
		   push(@v , \@b);
		   @a = @{$arg{node}};
		   $l=0;
		   $i=$r
     }
   }

   foreach my $s (@v){
     push(@{$arg{lattice}},"@$s\t@a");
     next if exists $arg{partitions}->{"@$s"};
     $arg{partitions}->{"@$s"} = [0,0,0];
     $self->_TreeRecurse(node=> $s, partitions =>$arg{partitions}, lattice => $arg{lattice});
   }

}



##################################################
sub _DistanceTotal {
##################################################

   	my ($self,%arg)= @_;

   	my $Qsum = 0 ;
    for (my $i = 0; $i < @{$arg{partition}}; $i++){
       $Qsum+=$arg{partition}->[$i];
    }

    my $x = ($Qsum > @{$arg{partition}}) ? (@{$arg{partition}}) : ($Qsum);

    my $r = $Qsum % $x;
    my $cel = ceil($Qsum/$x);
    my $flo = ($Qsum/$x);
    my $D_t = $cel*(2*$x -3 ) - 2*($x-$r);

    if($r == 2){
       $D_t++;
    }
	  my $epsilon =0;
    for (my $i = 0; $i < $x; $i++){
       if($arg{partition}->[$i]< $flo){
          $epsilon += ($flo-$arg{partition}->[$i]);
        }
    }

   	return ($D_t,$epsilon);
}



#################################################
sub DistanceFromDisorder {
#################################################

  my ($self,%arg)= @_;

  my ($tot,$epsilon) = $self->_DistanceTotal(partition => $arg{partition});
  return (2*$epsilon);
}


#################################################
sub DistanceFromOrder {
#################################################

  my ($self,%arg)= @_;

  my ($tot,$epsilon) = $self->_DistanceTotal(partition => $arg{partition});
  return $tot - (2*$epsilon);
}

#################################################
sub GetPartitions {
#################################################
   return \%partitions;
}


#################################################
sub GetLattice {
#################################################
   return \@lattice;
}


1;
