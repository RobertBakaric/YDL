use Test::More;
use lib '../lib';
use YDL::Compute;

plan tests => 1;

my $output1 = "10 0 0 0 0 0 0 0 0 0";

my $n = 10;

my $ydl = YDL::Compute->new();

my $conf = $ydl->YDLCompute(states => $n);

ok( $conf eq $output1, "YDL Compute");

done_testing;
