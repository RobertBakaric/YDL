#  Draw.pm
#
#  Copyright 2016 Robert Bakaric <robert@exaltum.eu>
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


package YDL::Draw;
use vars qw($VERSION);
use POSIX;
$VERSION = '0.01';

use strict;
use Carp;


=head1 NAME

YDL::Draw - Young Diagram Lattice Illustrator

=head1 SYNOPSIS

    use YDL::Draw;

    my $YDLobject = YDL::Draw->new();

    # -----        Draw YDL        ----- #
    # $conf = [N, 0,0,..,0(N-1)]
    $YDLdraw->YDLDraw(start => $conf,  lattice => $table); ## lattice-> parsed
                                                           result from GetLattice()



=head1 DESCRIPTION

The class is designed to illustrate all irreducible subrepresentations (S^l in M^l),
such that a latex object is created and the end-user can simply copy/past the generated
form into hers/his tex document.


=head2 new

    my $YDLobject = YDL::Draw->new();


    Creates a new YDL::Draw object.


=head2 YDLDraw

    # $conf = [N, 0,0,..,0(N-1)]
    $YDLobject->YDLDraw(start => $conf,  lattice => $table);


    Function prints latex form.



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



=cut




my @table = ();
my %lattice =();
my %seen = ();
my $width = 0;


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
sub YDLDraw {
#################################################

   my ($self,%arg) = @_;

   %lattice = %{$arg{lattice}};
   $self->_DrawHesseDiagram(start => $arg{start});


}



#################################################
sub _DrawHesseDiagram {
#################################################

   my ($self,%arg) = @_;

   my @nodes = ($arg{start});
   @table[0] = \@nodes;

   ## the recurcion is not the best way to go but since no more than N=100
   ## computations can be made, I think top of the head recursive solution is
   ## a serious issue - FXME in the future

   $self->_BredthTraversal(depth => 1, nodes => \@nodes);
   my $latexLattice = $self->_Draw();


}


#################################################
sub _Draw {
#################################################

  my ($self) = @_;

  print '\begin{tikzpicture}' . "\n";
  print '\matrix (a) [matrix of math nodes, column sep=3em, row sep=3em]{' . "\n";
  my %loci;
  my $r = 1;
  my $str ='';
  foreach my $row (@table){
    my $t = ($width -@$row+1);

    $str .= ' & ' x $t;
    for(my $i=0; $i< @$row; $i++){
      my $x = $row->[$i];
      $x =~s/ /,/g;
      $str .= "{\\tiny\\yng($x)}" if $x;
      $str .= ' & & ' ;
      $loci{$row->[$i]} = $r . "-". ($t+(($i+1)*2)-1);

    }
    $r++;
    chop($str) if $t <3;
    chop($str) if $t <3;
    $str .= ' & ' x ($t-1);
    print  $str . " \\\\\n";
    $str ='';
  }

  print '};'."\n".' \foreach \i/\j in {';
  $str ='';
  foreach my $key (keys %lattice){
    foreach my $id (@{$lattice{$key}}){
        $str.= "$loci{$key}/$loci{$id}, ";
    }
  }
  chop($str);
  chop($str);
  print "$str".'}'."\n";
  print '\draw (a-\i) -- (a-\j);' . "\n";


  print "\n".'\end{tikzpicture}' . "\n";
}


#################################################
sub _BredthTraversal {
#################################################

   my ($self,%arg) = @_;


   my @v =();
   my @ch = ();
   my %tmp;
   my $i=0;

   foreach my $node (@{$arg{nodes}}){
	   my @b = ();
	   foreach my $child (@{$lattice{$node}}){
		   push(@b, $child) if $seen{$child} != 1;
		   $seen{$child} = 1;
	   }
     if(@b > 0){
	      $v[$i] = \@b;
        $i++;
     }
   }
   ## Rearange

   for (my $j = 0; $j < @v; $j++){

	   for (my $i = 0; $i<@{$v[$j]} ; $i++){
		   if(exists $tmp{$v[$j]->[$i]}){
			   ## this ought to be done more modular!!! FXME
			   my $a=$v[$j-1]->[-1];
			   $v[$j-1]->[-1] = $v[$j-1]->[$tmp{$v[$j]->[$i]}];
			   $v[$j-1]->[$tmp{$v[$j]->[$i]}] = $a;

			   my $b = $v[$j]->[0];
			   $v[$j]->[0] = $v[$j]->[$i];
			   $v[$j]->[$i] = $b;
		   }
		   $tmp{$v[$j]->[$i]} = $i;
	   }
   }

   if(@v > 0){
     foreach my $t (@v){
	      push(@{$table[$arg{depth}]}, @$t);
      }

      $width = @{$table[$arg{depth}]} if @{$table[$arg{depth}]} > $width;

      $self->_BredthTraversal( depth => $arg{depth}+1,
        nodes => $table[$arg{depth}]);
   }

}

1;
