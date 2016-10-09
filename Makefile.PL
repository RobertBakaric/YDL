use ExtUtils::MakeMaker;

mkdir "./lib";
mkdir "./lib/YDL";
mkdir "./t/";
system("cp src/lib/YDL/* ./lib/YDL");
system("cp  src/t/* ./t/");
system("cp  src/apps/* ./bin/");


WriteMakefile(
	NAME		=> 'YDL',
	AUTHOR   => q{Robert Bakaric <rbakaric@exaltum.eu>},
	LICENSE  => 'GNU GENERAL PUBLIC LICENSE Version 3',
	ABSTRACT => 'Young Lattice Diagram Creator',
	VERSION	=> '0.01',

	dist		=> { 'COMPRESS' => 'gzip' },
	PREREQ_PM => {
        "Getopt::Long" => 0,
    },
    META_ADD => {
        provides => {
            'YDL::Compute' => {
               file => 'Compute.pm',
               version => '0.01',
            },
            'YDL::Draw' => {
               file => 'Draw.pm',
               version => '0.01',
            },
        },
    },
);



