#!/usr/bin/perl -w

my $infile_list = $ARGV[0];

my @infiles;

open (IN, "<", $infile_list) or die "No such file as $infile_list, $!\n";
while (my $line = <IN>){
	chomp $line;
	push @infiles, $line;
}
close IN;

foreach $i (@infiles){
	print "Infile name: $i\n";
	my @outname_pieces = split(/\./, $i);
	my $outname = $outname_pieces[0] . ".nuc";
	print "OUTNAME: " . $outname ."\n";

	my @nexdata;
	my @linedata;
	my @pre_taxa;
	my @taxa;
	my @seqs_by_taxa;

	my $tax_num;
	my $n_char;
	my $seq_switch = 0;
	my $chunk_switch = 0;
	my $end_trigger = 0;

	open (LOCAL_NEXUS, "<", $i) or die "No such file as $i, $!\n";
	while (my $line = <LOCAL_NEXUS>){
		chomp $line;
		push @nexdata, $line;
	}
	close LOCAL_NEXUS;

	my $local_counter = 0;

	unless ($nexdata[$local_counter] =~ m/#NEXUS/) {
		print "Not a nexus format file, check inputs!\n";
	}

	foreach $n (@nexdata){

		if ($n =~ m/^;/){
                	print "END TRIGGER: $n\n";
                        $end_trigger++;
                }

		if ($end_trigger < 1){
			if ($n =~ m/^dimensions/){
				my $dimensions = $n;
				$tax_num = (split(' ', $dimensions))[1];
				$tax_num =~ s/[^0-9]//g;
				$n_char = (split(' ', $dimensions))[2];
				$n_char =~ s/[^0-9]//g;
			}
			if ($n =~ m/matrix/){
				$seq_switch += 1;
				$chunk_switch += 1;
			}

			if ($seq_switch >= 1){
				unless ($seq_switch == 0){
					if ($n !~ m/^\W$/){
						my @local_taxon = split('\s', $n);
						if ($n !~ m/matrix/g){
							push @pre_taxa, $local_taxon[0];
							push @linedata, $n;
						}
					}
					else{
						$seq_switch = 0;
						$chunk_switch += 1;
					}
				}
			}

			if ($chunk_switch >= 2){
				if ($n !~ m/^\W$/){
					push @linedata, $n;
				}

				else{
					$chunk_switch += 1;
				}
			}
		}
		$local_counter++;
	}

	#line parsing

	#Hard coded reference to sequence names will need to be changed based on input sequence headers
	my $reference_seq_to_move_to_top = 'Emulti';
	foreach $preclean_t (@pre_taxa){
		if ($preclean_t !~ m/$reference_seq_to_move_to_top/){
			push @taxa, $preclean_t;
		}
	}
	unshift @taxa, $reference_seq_to_move_to_top;


	my $taxon_counter = 0;
	foreach $tc (@taxa){
		my $pushed_check = 0;
		foreach $l (@linedata){
			if ($l =~ m/\s/g){
				my @local_taxon = split('\s', $l);
				my $check_tax = $local_taxon[0];
				print "Check tax: " . $check_tax . "\n"; 
				shift @local_taxon;
				my $preseq = join('', @local_taxon);
				print "preseq: " . $preseq . "\n";
				$preseq =~ s/[^ACGTN-]//g;
				print "preseq2: " . $preseq . "\n";
				if ($tc =~ m/$check_tax/){
					if ($pushed_check == 0){
						push @seqs_by_taxa, $preseq;
						$pushed_check += 1;
					}
					else{
						$seqs_by_taxa[$taxon_counter] .= $preseq;
					}
				}
			}
		}
		$taxon_counter++;	 
	}
	$taxon_counter = 0;
	#Nuc_file_construction
	my @nuc;
	my $header = " $tax_num $n_char\n";
	push @nuc, $header;
	foreach $tx (@taxa){
		my $final_seq = $tx . "   " . $seqs_by_taxa[$taxon_counter] . "\n";
		push @nuc, $final_seq;
		$taxon_counter++;
	}


	open (OUT, ">", $outname) or die "Couldn't make outfile $outname, $!\n";
	foreach $nc (@nuc){
		print OUT "$nc";
	}
	close OUT;


}
exit;
