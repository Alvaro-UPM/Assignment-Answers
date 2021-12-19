# Requiring BioRuby and StringIO
require 'bio'
require 'stringio'


# Regular expressions:
#....................................
fasta_header = Regexp.new(/^>/) # to match the fasta format headers (all start that way)
#....................................


# reading both .fa files
pep_file = File.new("Databases/pep.fa", "r") # S.pombe 
arab_file = File.new("Databases/arab.fa", "r") # A.thaliana

# we divide these files in lines 
pep_lines = File.readlines(pep_file)
arab_lines = File.readlines(arab_file) 


# we create an array called "pep_fasta" in which we group all the file lines that are part from the same "S.pombe" fasta entry 
pep_fasta = "" # first we create a new string in which we introduce all the file lines
pep_lines.each do |line|
  if line.match(fasta_header) # if the lines match the fasta_header add it to the string all complete
    pep_fasta = pep_fasta + "#{line}"
  else 
    pep_fasta = pep_fasta + "#{line.split("\n")[0]}" # if not add it but removing the final "\n"
  end
end

pep_fasta = pep_fasta.split(">")
=begin
Then, create the array dividing this "continuous" string in fasta entry by doing split at ">".
But, since the original ">" at the first fasta line is removed using split we add it again using the loop below.
=end
i=0
pep_fasta.each do |entry|
  pep_fasta[i] = ">" + "#{entry}" # adding ">" again to each fasta in the "pep_fasta" array
  i=i+1
end
pep_fasta.shift # removing the first element of the array which is only a ">" due to the split at ">" of the first fasta entry.


=begin
We use exactly the same strategy to create an array called "arab_fasta" in which we group all the file lines that are part from the same "A.thaliana" fasta entry
=end
arab_fasta = ""
arab_lines.each do |line|
  if line.match(fasta_header)
    arab_fasta = arab_fasta + "#{line}"
  else 
    arab_fasta = arab_fasta + "#{line.split("\n")[0]}"
  end
end

arab_fasta = arab_fasta.split(">")

i=0
arab_fasta.each do |entry|
  arab_fasta[i] = ">" + "#{entry}"
  i=i+1
end
arab_fasta.shift # finally, we get the array


=begin
Eventually, we can do the "reciprocal best hit" between these two lists of fasta sequence using BLAST
in order to get candidates pairs of orthologue genes between these two species ("S.pombe" and "A.thaliana")
=end
orthologue_candidates = [] # we create an empty array in which we are going to introduce the ortologues candidates
n=0

=begin
We define both "arab" and "pep" factories that we are going to use as databases to do our BLAST against to.
We write "./Databases/..." because we have the databases in a folder called "Databases" that is in the same folder we are ("./")
=end
arab_factory = Bio::Blast.local('tblastn', './Databases/arab')  
pep_factory = Bio::Blast.local('blastx', './Databases/pep') 

$stderr.puts "Searching ... "  # standard error

=begin
We choose to run first every S.pombe entry (pep) against the A.thaliana database (arab)
and then run the best hit obtained of A.thaliana against all the S.pombre database and check if we have a reciprocal best hit
=end
pep_fasta.each do |pep| # each S.pombe fasta entry 

  next unless arab_factory.query("#{pep}") # next if there is not response to the BLAST query
  pep_report = arab_factory.query("#{pep}") # if there is response we use it to define the report
 
  pep_hits = [] # empty array
  i=0
  pep_report.each do |hit| # report each define these hit variable
    pep_hit_id = "#{hit.hit_id}"
    pep_evalue = "#{hit.evalue}"
    pep_target_id = "#{hit.target_id}"
    pep_lap_at = "#{hit.lap_at}"
    pep_qseq = ""
    pep_hseq = ""
  
    hit.each do |hsp|
      pep_qseq = hsp.qseq  
      pep_hseq = hsp.hseq 
    end
    pep_hits[i] = pep_hit_id, pep_evalue, pep_target_id, pep_lap_at, pep_qseq, pep_hseq
    i=i+1
    # introduce these variable in order in the "pep_hits" array
  end
  next unless pep_hits[0] != nil # if we do not have any hit, go to the next pep fasta entry
  next unless pep_hits[0][1].to_f < 0.01 # Hits with e-value (pep_hits[0][1]) smaller than 0.01 can be considered as good hit for homology matches (source: https://www.metagenomics.wiki/tools/blast/evalue)
  arab = "#{arab_fasta["#{pep_hits[0][2]}".to_i]}"
  # define arab as the A.thaliana fasta entry in the same position as the best hit's target id
  #("pep_hits[0]" is the best hit and "pep_hits[0][2]" is the "target_id" of that best hit)
  
  next unless arab != "" # if arab is an empty string, next
  
  next unless pep_factory.query("#{arab}") # if there is response to the query
  
  arab_report = pep_factory.query("#{arab}")  # same strategy
  
  arab_hits = []
  j=0
  arab_report.each do |hit|
    arab_hit_id = "#{hit.hit_id}"
    arab_evalue = "#{hit.evalue}"
    arab_target_id = "#{hit.target_id}"
    arab_lap_at = "#{hit.lap_at}"
    arab_qseq = ""
    arab_hseq = ""
 
    hit.each do |hsp|
      arab_qseq = hsp.qseq  
      arab_hseq = hsp.hseq 
    end
    arab_hits[j] = arab_hit_id, arab_evalue, arab_target_id, arab_lap_at, arab_qseq, arab_hseq 
    j=j+1
  end
  
  next unless arab_hits[0] != nil # if there is best hit
  next unless arab_hits[0][1] < 0.01 # Hits with e-value (arab_hits[0][1]) smaller than 0.01 can be considered as good hit for homology matches (source: https://www.metagenomics.wiki/tools/blast/evalue)
  if arab_hits[0][2] == pep_fasta_sample.index(pep)
    # check if it is a reciprocal best hit, by checking is the "target_id" is the same as the index of the "running" pep (that we use in the first BLAST)
    orthologue_candidates[n] = "#{pep.split("\n")[0]} and #{arab.split("\n")[0]}" # introduce the two candidates fasta header into the "orthologue_candidates" array
    n=n+1
  end
end
orthologue_candidates