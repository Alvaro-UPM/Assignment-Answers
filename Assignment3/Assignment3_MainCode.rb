=begin
Personal note:
I know my last github submit is quite late. These last weeks have been so busy for me and I did my best.
Although I know it is probably quite improvable, I hope you enjoy my code :)
=end


require 'bio' #requering BioRuby
require 'rest-client' #to access the web
require 'enumerator' #to get the coordinates of the match



# Create a function called "fetch" that we can re-use everywhere in our code
#.....................................
def fetch(url, headers = {accept: "*/*"}, user = "", pass="")
  response = RestClient::Request.execute({
    method: :get,
    url: url.to_s,
    user: user,
    password: pass,
    headers: headers})
  return response
  
  rescue RestClient::ExceptionWithResponse => e
    $stderr.puts e.inspect
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue RestClient::Exception => e
    $stderr.puts e.inspect
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
  rescue Exception => e
    $stderr.puts e.inspect
    response = false
    return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
end
#.....................................


# Getting AGIs from the 168 AGIs' list
#.....................................
=begin
Here, we create a has with the "clean" AGIs from our original list.
=end
original_list = File.new("./ArabidopsisSubNetwork_GeneList.txt", "r")

original_list_lines = File.readlines(original_list)

original_agi = []
i=0
original_list_lines.each do |x|
  original_agi[i] = original_list_lines[i].partition("\n")[0].downcase
  i=i+1
end
#.....................................


# Regular expressions
# .............................
=begin
Since some genes have features exons called "complement" that have "weird" position 
called "complement(someID:start_pos..end_pos)"
(there is a screenshot as an example called "This is what I mean by weird positions"). 
The number of these positions are usually greater than the maximum number in the gene's sequence and having
some looks at UniProt I did not found any information about them.
So, we are using this regular expression to discard these "weird" exons and focus on the main ones: "start_pos..end_pos"
and "complement(start_pos..end_pos)"
=end

position = Regexp.new(/^(\d+)\S\S(\d+)$/) #  "start_pos..end_pos" regular expression

complement_position = Regexp.new(/^complement\S(\d+)\S\S(\d+)\S$/) # "complement(start_pos..end_pos)" regular expression

cttctt_match = Regexp.new(/cttctt/i) #we use this regular expression to check if there is 'cttctt' in the seq string

aagaag_match = Regexp.new(/aagaag/i) 
#we use this regular expression to check if there is 5' 'aagaag' 3' in the forward sequence string, that is,
# 5' 'cttctt' 3' in its reverse sequence

chromosome = Regexp.new(/chromosome:TAIR10:([1-5]):(\d+):(\d+)/i) #we use this to get the chromosome coordinates of the genes
# .............................



# Web access to retrieve the data and introduce it in Bio:EMBL object
#.....................................
i=0 # just to itinerate into the "all_record" and all_embl" arrays elements at the same time
all_record = [] # an array to get all the "dirty" response body
all_embl = [] # an array in which we are going to introduce all the Bio:EMBL created from the web call response of all the AGIs
original_agi.each do |x|
  
  res = fetch("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{x}"); # calling the web

  if res # if there is response
    record = res.body
    all_record[i] = res.body 
    all_embl[i] = Bio::EMBL.new(res.body) # introducing the body's response into a new Bio:EMBL (EnsEMBL Sequence Object)
    # and, each of these ones, into "all_embl" array
    i=i+1
  else
    puts "the Web call failed - see STDERR for details..."
  end
end
#.....................................



# Adding new 'cttctt' features to the EnsEMBL Sequence objects
#.....................................
all_embl.each do |embl| 

  seq = embl.seq # seq is the sequence of the embl
  exon_pos = [] # positions of the exons
  exon_seq = [] # sequence of the exons
  cttctt_coordinates = [] # the cttctt coordinates of the exon being "analyzed"
  cttctt_pos = [] # cttctt position of all the exons of the embl being "running"
  i=0 # each embl "i" and "j" itinerators start from 0
  j=0
  
=begin
Since there are some "complement" exon which coordinates are refered to the "reverse" chain,
we use this to get the gene sequence lenght and, that way, be able to get the "real" ("forward") position of
these "complement" exons by substrating the start position obtained in "complement(start_pos..end_pos)"
from the gene length.
To get the gene length we know (by revising the data previously) that
the first feature's position is always refered to the gene start and end position inside the gene sequence,
so this "end position" is the gene length.
=end
  if embl.features[0] and embl.features[0].position.match(position) # if there is features[0] and it match position regexp
    gene_length = "#{embl.features[0].position.match(position)[2]}".to_i # get the third element of the match (end_pos) as the gene length
  end

    embl.features.each do |feature| # know we itinerate inside the features to get the exon_pos, exon_seq and cttctt_pos inside these exons

    if feature.feature == "exon" # if the feature is called "exon"
      exon_position = feature.position # get the exon position
         if exon_position.match(position) 
           # and if this position match our specific regular expression for "forward" exons (position regexp)
           exon_pos[i] = "#{exon_position.match(position)[1]}", "#{exon_position.match(position)[2]}" #get the exon position
           exon_seq[i] = seq["#{exon_pos[i][0]}".to_i.."#{exon_pos[i][1]}".to_i] # and then we get the sequence between the positions
           #in the complete gene sequence (previously called "seq")
           i=i+1 #add +1 to the itinerator
           
          elsif exon_position.match(complement_position)
           # and if the position match our specific regular expression for "complement" exons (but not "weird" ones) (complement_position regexp)
           exon_pos[i] = "#{gene_length - exon_position.match(complement_position)[2].to_i}", "#{gene_length - exon_position.match(complement_position)[1].to_i}"
           #get the exon position
           exon_seq[i] = seq["#{exon_pos[i][0]}".to_i.."#{exon_pos[i][1]}".to_i] # and then we get the sequence between the positions
           #in the complete gene sequence (previously called "seq")
           i=i+1 #add +1
         
         end

=begin
Since we add +1 to "i" just after the adding of a new exon_pos or exon_seq,
in the following code, when we write "i-1" we are refering to the last exon_pos or exon_seq that was added
=end
      
            if cttctt_match.match(exon_seq[i-1])
             # if there is 'cttctt' inside the exon_seq, get its coordinates 
                cttctt_repeat_start = exon_seq[i-1].enum_for(:scan, /(?=(cttctt))/i).map { Regexp.last_match.begin(0) }.uniq.compact
                # we use this method that "scan" the sequence string looking for 'cttctt' repeats an return an array with the begin position in the string
                cttctt_repeat_start.each do |repeat| # for each of these 'cttctt' repeat found we introduce it in a new array
                 # adding the exon position inside the whole gene to its position inside the exon to represent it start_pos,
                 # adding +5 for the represent its end_pos (we know the last 't' is 5 position far from the first 'c')
                 # about this last +5, I have to say that I used +6 to get the gff3 that I introduced in EnsEMBL in order to avoid
                 # the overlap between the differet 'cttctt' repeats in the chromosome graphic representation
                 # so in the attached screenshot we match the next nucleotide after the last 't' on purpose.
                  # And we add "+" because it is a match in the forward chain
                  cttctt_coordinates[j] = repeat + exon_pos[i-1][0].to_i, repeat + exon_pos[i-1][0].to_i + 5, "+"
                  cttctt_coordinates = cttctt_coordinates.compact
                  j=j+1
                end
                 # since in the 'cttctt' position using "scan" method the first number is 0
                 # and in the exon position is 1 we do not need to add or substract any number,
                 # we are directly getting the rigth position for introduce our gff3 file in EnsEMBL
                
            end
           
            if aagaag_match.match(exon_seq[i-1]) # we do exactly the same here but matching 'aagaag'
            # since it is the sequence that you get if you looks for 'cttctt' in the reverse chain in 5' 3' direction
                cttctt_repeat_start = exon_seq[i-1].enum_for(:scan, /(?=(aagaag))/i).map { Regexp.last_match.begin(0) }.uniq.compact 
                cttctt_repeat_start.each do |repeat|
                  cttctt_coordinates[j] = repeat + exon_pos[i-1][0].to_i, repeat + exon_pos[i-1][0].to_i + 5, "-"
                  # we introduce them as 'cttctt' repeats but adding "-" to indicate that we are talking about the reverse chain
                  cttctt_coordinates = cttctt_coordinates.compact
                  j=j+1
                end
                 
                
            end
        end
      cttctt_pos = cttctt_coordinates.uniq.compact 
      end

=begin
Here, we create a new Sequence Feature called 'cttctt'
with the positions of each 'cttctt' repeat including in "cttctt_pos" array.
And we add this new Feature to our EnsEMBL Sequence Object (embl)
=end
  features = Bio::Feature.new('cttctt', cttctt_pos)
  features.append(Bio::Feature::Qualifier.new('sequence', 'cttctt'))
  embl.features << features
  embl.features
  
end
#.....................................


# Defining common fields
#.....................................
=begin
Since the gff3 format "fields" (or headers) are: "seqid", "source", "type", "start", "end", "strand", "phase", "attributes"
Here, we fix the "string" that we want to be always in some of these "fields".
In fact, we are fixing some of them and we are only having different "strings" in "seqid", "start", "end" and "strand" fiedls.
=end

source = "EnsEMBL"
type = "direct_repeat"
score = "."
phase = "."
attributes = "cttctt_repeat"
#.....................................


# Both first GFF3 file and no_cttctt_report.txt creation
#.....................................
gff3 = File.new("gff3_first.gff3", "w") # we open the gff3 file to write the CTTCTT features (called "gff3_first.gff3")
gff3.write("##gff-version 3\n") # we write mandatory first line

report = File.new("no_cttctt_report.txt", "w") # we open another file (called "no_cttctt_report.txt") to report the genes (if any) 
#that have not any 'cttctt' repeat in their exons
report.write("Here we report the AGIs of the genes which exons have not any 'CTTCTT' repeats in the sequence:\n") # we write the first line of this report


all_embl.each do |embl|
  
  seqid = "" # defining seqid by default as a "empty" string to prevent from problems
  
  differentiator = 1 # to add a dot with a new number to distinguish between seqid of the same gene

 embl.features.each do |feature|

      if feature.feature == "gene" # if feature is called "gene"
        seqid = "#{feature.qualifiers[0].value}" #we get the AGI as "seqid" 
      end

      next unless feature.feature == "cttctt" # pass to the next feature unless the feature is called "cttctt" (our created feature)
        feature.position.each do |pos| # each one do pos (each pos is an array with 2 elements: start and end positions, respectively)
          seqid = "#{seqid.split(".")[0]}" + ".#{differentiator}"
          differentiator = differentiator + 1
          start_pos = "#{pos[0]}".to_s # get the start_pos as the first elemet of pos array
          end_pos = "#{pos[1]}".to_s # get the end_pos as the second elemet of pos array
          strand = "#{pos[2]}".to_s # get if the strand is positive or negative
          fields_arr = [seqid, source, type, start_pos, end_pos, score, strand, phase, attributes] 
          # above introduce a new elements in the "fields_arr" array
          new_line = fields_arr.join("\t") + "\n" #we join these new elements (adding \n for new line)
          gff3.write(new_line) # an we write them as a new line in the gff3 file
      end
    
  end
  if differentiator == 1 #if the differentiator keeps equals to 1 after all the features itinerations 
  # that means that it was not created a new feature called "cttctt" for that embl
  # so there is not 'cttct' repeats in any of its exons' sequences
    report.write("#{seqid}\n") # So, in this case, we write its seqid as a new line in the report file
  end
    
end
gff3.close # file called "gff3_first.gff3"
report.close # file called "no_cttctt_report.txt"
# we close both files
#.....................................



# Second GFF3 file creation
#.....................................

gff3_chr = File.new("gff3_chr.gff3", "w") # Now, we open the gff3 file to write the CTTCTT features (called "gff3_first.gff3"),
#but using the chromosome coordinates instead of the genes's ones
gff3_chr.write("##gff-version 3\n") # we write mandatory first line

chr = [] # empty arrays to introduce the chromosome number,
# start and en dposition of the gene in the chromosome
chr_start = []
k=0 #itinerator

all_record.each do |record|
  if record.match(chromosome) # if record match "chromosome" RegExp (defined above in "Regular Expression")
    chr[k] = record.match(chromosome)[1] # get the chromosome number as chr
    chr_start[k] = record.match(chromosome)[2] # get the start coordinate of the gene inside the chromosome
  end
  k=k+1 # we increase the value of the itinerator even if there is not match 
  #because we want to keep it in the same order as "all_record" and "all_embl" arrays
end

=begin
Since "all_record" and "all_embl" contains the web call body response in the same order 
(they were created using the same itenrator), we can itinerate in both at the same time to 
include the chromosome's number as the new seqid and the 'cttctt' repeat chromosome's coordinates 
as the new start and end positions in our new gff3 file called "gff3_chr"
=end

k=0 # we use the same letter for the itinerator to make clear the pacing between "chr", "chr_start" and "all_embl" itinerations
all_embl.each do |embl|

  seqid = "chr#{chr[k]}"

  embl.features.each do |feature|

      next unless feature.feature == "cttctt" # pass to the next feature unless the feature is called "cttctt" (our created feature)
        feature.position.each do |pos| # each one do pos (each pos is an array with 2 elements: start and end positions, respectively)
          start_pos = "#{pos[0].to_i + chr_start[k].to_i - 1}".to_s # get the start_pos as the first elemet of pos array
          end_pos = "#{pos[1].to_i + chr_start[k].to_i - 1}".to_s # get the end_pos as the second elemet of pos array
          strand = "#{pos[2]}".to_s # get if the strand is positive or negative
          fields = [seqid, source, type, start_pos, end_pos, score, strand, phase, attributes] 
          # above introduce a new elements in the "fields_arr" array
          new_line = fields.join("\t") + "\n" #we join these new elements (adding \n for new line)
          gff3_chr.write(new_line) # an we write them as a new line in the gff3 file
      end
    
  end
k=k+1 # again, we always increase the value in each iteration because want to keep the pacing
end
gff3_chr.close # file called "gff3_chr.gff3"
# we close the file 
#.....................................