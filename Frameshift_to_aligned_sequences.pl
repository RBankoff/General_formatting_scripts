#!/usr/bin/perl -w

my $input = $ARGV[0];
my $output = (split('.', $input))[0];
$output .= ".out.nuc";

my @ref_codons;
my @complete_sequences;

my $header;
my $ref_sequence;
my $mask = "NNN";


open (IN, "<", $input) or die "couldn't open input alignment, $!\n";
while (my $line = <IN>){
	chomp $line;
	push @raw_data, $line;
}
close IN;

for (my $i = 0 ; $i < (scalar(@raw_data)); $i++){
	if ($i < 1){
		push @complete_sequences, $raw_data[$i];
		$header = $raw_data[$i];
	}
	else{
		if ($raw_data[$i] =~ m/^Emulti/){
			push @complete_sequences, $raw_data[$i];
			my $ref_seq = (split(/\s+/, $raw_data[$i]))[1];
			$ref_sequence = $ref_seq;
			@ref_codons = ($ref_seq =~ m/.../g);
		}
		else{
			my $seq_length = length($ref_sequence);
			my @local_codons;
			my @post_codons;

			my $local_name = (split(/\s+/, $raw_data[$i]))[0];
			my $local_seq = (split(/\s+/, $raw_data[$i]))[1];
			print "Local seq: $local_seq\n";

			@local_codons = ($local_seq =~ m/.../g);
			$nucscount = 0;
			foreach $lc (@local_codons){
				$nucscount++;
			}
			print "CC: $nucscount\n";

			my $counter = 0;
			foreach $l (@local_codons){
				if ($counter < (scalar(@ref_codons))){
					if ($l =~ m/^$ref_codons[$counter]$/){
						push @post_codons, $l;
					}
					elsif($l =~ m/^NNN$/){
						push @post_codons, $l;
					} 
					elsif($l =~ m/^---$/){
						push @post_codons, $l;
					}
					elsif($l =~ m/[ACGTN]{3}/i){
						push @post_codons, $l;
					}
					else{
						print "L: $l\n";
						push @post_codons, $mask; 
					}
				}
				$counter++;
			}

			my $local_processed_seq = join('', @post_codons);
			my $check_length = length($local_processed_seq);
			if ($check_length == $seq_length){
				my $for_final = $local_name . "   " . $local_processed_seq;
				push @complete_sequences, $for_final;
			}
			else{
				die "Wrong sequence length in $local_name after masking for post-alignment frameshifts.\nSequence length is $check_length, should be $seq_length\n";
			}

		}
	}
}

my $count = 0;

open (OUT, ">", $output) or die "Couln't open output file $output for writing, $!\n";
foreach $c (@complete_sequences){
	print OUT $c . "\n";
	$count++;
}

#to account for header
$count -= 1;

my $num_seqs = (split(/\s/, $header))[0];
my $seq_length = 

print "Total number of sequences: $count\n";
print "Total number of sequences according to header: $header\n";

exit;
