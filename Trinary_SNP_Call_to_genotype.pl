#!/usr/bin/perl -w

my $IN = $ARGV[0];
my $OUT = $ARGV[1];

my @in_data;
my @clean_data;

my $header;
my $counter = 0;
open (IN, "<", $IN) or die "couldn't open infile $IN, $!\n";
while (my $line = <IN>){
	chomp $line;
	if ($counter == 0){
		$header = $line;
		$counter++;
	}
	else{
		push @in_data, $line;
	}
}
close IN;

open (OUT, ">", $OUT) or die "Couldn't make outfile $OUT, $!\n";
print OUT $header . "\n";
foreach $id(@in_data){
	my @splitter = split(/\t/, $id);
	my $length = scalar(@splitter);
	my @values;
	my $A = (split(/\//, $splitter[4]))[0];
	my $B = (split(/\//, $splitter[4]))[1];
	my @pre_info;
	for (my $e = 0; $e < 5; $e++){
		push @pre_info, $splitter[$e];
	}
	my $pre_info_holder = join ("\t", @pre_info);

	for (my $i = 5; $i < $length; $i++){
		my $j = $splitter[$i];
		my $nuc;
		if($j == 0){
			$nuc = $A . $A;
		}
		elsif($j == 1){
			$nuc = $A . $B;
		}
		elsif($j == 2){
			$nuc = $B . $B;
		}
		elsif($j == 9){
			$nuc = "0" . "0";
		}
		push @values, $nuc;

	}
	my $Values = join("\t", @values);
	my $final = join("\t", $pre_info_holder,$Values);
	print OUT $final . "\n";
}
close OUT;
print "Done!\n";
exit;
