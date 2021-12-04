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
complement = Regexp.new(/complement/)
=begin
Since some genes have features exons called "complement" (If I am not wrong,
I think that this have nothing to do with complement DNA strand), 
but we you have a look at UniProt they are not consider as exons,
we are using this regular expression to discard these "complement" exons and focus on the main one
=end

cttctt_match = Regexp.new(/cttctt/i) #we use this regular expression to check if there is 'cttctt' in the seq string

chromosome = Regexp.new(/chromosome:TAIR10:([1-5]):(\d+):(\d+)/i) #we use this to get the chromosome coordinates of the genes
# .............................



# Web access to retrieve the data and introduce it in Bio:EMBL object
#.....................................
i=0 # just to itinerate into the "all_record" and all_embl" arrays elements at the same time
all_record = [] # an array to get all the "dirty" response body
all_embl = [] # an array in which we are going to introduce all the Bio:EMBL created from the web call response of all the AGIs
original_agi.each do |x|
  
  res = fetch("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{x}"); #calling the web

  if res 
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



# Adding new 'cttctt' features to the EnsEMBL Sequence object
#.....................................
all_embl.each do |embl|

  seq = embl.seq # seq is the sequence of the embl
  exon_pos = [] # positions of the exons
  exon_seq = [] # sequence of the exons
  cttctt_coordinates = [] # the cttctt coordinates of the exon being "analyzed"
  cttctt_pos = [] # cttctt position of all the exons of the ebml being "running"
  i=0
  j=0

  embl.features.each do |feature|

    if feature.feature == "exon" # if the feature is called "exon"
         unless feature.position.match(complement) # and there is not a "complement" one
           exon_pos[i] = feature.position.split("..") #get the exon position
           exon_seq[i] = seq["#{exon_pos[i][0]}".to_i.."#{exon_pos[i][1]}".to_i] # and get it sequence using the positions 
           #in the complete gene sequence (previously called "seq")
           if cttctt_match.match(exon_seq[i]) # if there is 'cttctt' inside the exon_seq, get its coordinates (using the method below)
                cttctt_coordinates[j] = [exon_seq[i].enum_for(:scan, /cttctt/i).map { Regexp.last_match.begin(0) }[0] + exon_pos[i][0].to_i, exon_seq[i].enum_for(:scan, /cttctt/i).map { Regexp.last_match.end(0) }[0] + exon_pos[i][0].to_i - 1].uniq.compact 
                 #we substract -1 at the end (exon_pos[i][0].to_i - 1) in order to get the real ending position, that is, the last 'T' (and not like an ruby array numeration)
                j=j+1
          end
          i=i+1
         end
      end
      cttctt_pos = cttctt_coordinates.uniq.compact #we compact all the 'cttctt' repeats coordinates of the same embl in an unique array
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
In fact, we are fixing the most of them and we are only having differences "string" in "seqid", "start" and "end" fiedls.
=end

source = "BioRuby"
type = "direct_repeat"
strand = "."
score = "."
phase = "."
attributes = "."
#.....................................


# First GFF3 file creation
#.....................................
gff3 = File.new("gff3_first", "w") # we open the gff3 file to write the CTTCTT features (called "gff3_first)
gff3.write("##gff-version 3\n") # we write mandatory first line
headers = ["seqid", "source", "type", "start", "end", "strand", "phase", "attributes"] 
# Here above, we define the string that we are going to use as headers in the gff3 file.
headers = headers.join("\t") # we join the headers by \t, because gff3 is a tab-separated format
gff3.write(headers+"\n") # we write the headers

report = File.new("report", "w") # we open another file (called "report") to report the genes (if any) 
#that have not any 'cttctt' repeat in their exons
report.write("Here we report the genes that exons with CTTCTT repeats:\n") # we write the first line of this report


all_embl.each do |embl|

  fields_arr = [] 
=begin
Here above, we create a fields_arr in which we are going to introduce the values 
of the gff3 fields for each 'cttctt' repeat of each embl. 
Latter, we are going to use it to know if there is any 'cttctt' in that embl or not to make the report.
=end
  seqid = []
=begin
We define the seqid as an array since there are more than one "gene" feature in some web response, 
with different AGIs differing by 10 units in their AGI number, e.g., "at5g542702 and "at5g54280"
(I do not really know why).
Although it could be wrong, we are going to consider this AGIs as the same and we are going to pick up the first one o
of the "seqid" array as the seqid
=end
  
  j = 0  # parameters just for the mentioned arrays elements itinerations (respectively)
  id = 0

  embl.features.each do |feature|

      if feature.feature == "gene" # if feature is called "gene"
        seqid[id] = "#{feature.qualifiers[0].value}" #we get the AGI as "seqid" 
        id = id+1
      end

      next unless feature.feature == "cttctt" # pass to the next feature unless the feature is called "cttctt" (our created feature)
        feature.position.each do |pos| # each one do pos (each pos is an array with 2 elements: start and end positions, respectively)
          start_pos = "#{pos[0]}".to_s # get the start_pos as the first elemet of pos array
          end_pos = "#{pos[1]}".to_s # get the end_pos as the second elemet of pos array
          fields_arr[j] = [seqid[0], source, type, start_pos, end_pos, score, strand, phase, attributes] 
          # above introduce a new elements in the "fields_arr" array
          new_line = fields_arr[j].join("\t") + "\n" #we join these new elements (adding \n for new line)
          gff3.write(new_line) # an we write them as a new line in the gff3 file
          j=j+1
      end
    
  end
  if fields_arr == [] #if the fields_arr keeps empty after all the features itinerations 
  # that means that it was not created a new feature called "cttctt" for that embl
  # because there is not 'cttct' repeats in any of its exons' sequences
    report.write("#{seqid[0]}\n") # So, in this case, we write its seqid as a new line in the report file
  end
    
end
gff3.close # file called "gff3_first"
report.close # file called "report"
# we close both files
#.....................................



# Second GFF3 file creation
#.....................................

gff3_chr = File.new("gff3_chr", "w") # we open the gff3 file to write the CTTCTT features
gff3_chr.write("##gff-version 3\n") # we write mandatory first line
headers = ["seqid", "source", "type", "start", "end", "strand", "phase", "attributes"] 
# Here above, we define the string that we are going to use as headers in the gff3 file.
headers = headers.join("\t") # we join the headers by \t, because gff3 is a tab-separated format
gff3_chr.write(headers+"\n") # we write the headers


chr = []
chr_start = []
chr_end = []
k=0 #itinerator
all_record.each do |record|
  if record.match(chromosome) # if record match "chromosome" RegExp (defined above in "Regular Expression")
    chr[k] = record.match(chromosome)[1] # get the chromosome number as chr
    chr_start[k] = record.match(chromosome)[2] # get the start coordinate of the gene inside the chromosome
    chr_end[k] = record.match(chromosome)[3] #just in case
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

  seqid = "Chr#{chr[k]}"

  embl.features.each do |feature|

      next unless feature.feature == "cttctt" # pass to the next feature unless the feature is called "cttctt" (our created feature)
        feature.position.each do |pos| # each one do pos (each pos is an array with 2 elements: start and end positions, respectively)
          start_pos = "#{pos[0].to_i + chr_start[k].to_i - 1}".to_s # get the start_pos as the first elemet of pos array
          end_pos = "#{pos[1].to_i + chr_start[k].to_i - 1}".to_s # get the end_pos as the second elemet of pos array
          fields = [seqid, source, type, start_pos, end_pos, score, strand, phase, attributes] 
          # above introduce a new elements in the "fields_arr" array
          new_line = fields.join("\t") + "\n" #we join these new elements (adding \n for new line)
          gff3_chr.write(new_line) # an we write them as a new line in the gff3 file
      end
    
  end
k=k+1 # again, we always increase the value in each iteration because want to keep the pacing
end
gff3_chr.close # file called "gff3_chr"
# we close the file 
#.....................................