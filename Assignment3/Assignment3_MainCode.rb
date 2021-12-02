require 'bio'
require 'rest-client' 
require 'enumerator' #to get the coordinates of the match



# Create a function called "fetch" that we can re-use everywhere in our code

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



original_list = File.new("./ArabidopsisSubNetwork_GeneList.txt", "r")

original_list_lines = File.readlines(original_list)

original_agi = []
i=0
original_list_lines.each do |x|
  original_agi[i] = original_list_lines[i].partition("\n")[0].downcase
    # We convert it into downcase (lowercase) to make more easy the future "comparations" between them to obtain the interactions
  i=i+1
end

complement = Regexp.new(/complement/)
cttctt_match = Regexp.new(/cttctt/i)



i=0
embl_file = []
original_agi.each do |x|
  
  res = fetch("http://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=ensemblgenomesgene&format=embl&id=#{x}");

  if res 
    record = res.body  
    embl_file[i] = Bio::EMBL.new(res.body) 
  else
    puts "the Web call failed - see STDERR for details..."
  end
i=i+1
end



source = "BioRuby"
type = "direct_repeat"
strand = "."
score = "."
phase = "."
attributes = "."



gff3 = File.new("gff", "w")
gff3.write("##gff-version 3\n") 
headers = ["seqid", "source", "type", "start", "end", "strand", "phase", "attributes"]
headers = headers.join("\t")
gff3.write(headers+"\n")

embl_file.each do |embl|

  seq = embl.seq
  exon_pos = []
  exon_seq = []
  cttctt_coordinates = []
  cttctt_pos = []
  i=0
  j=0

  embl.features.each do |feature|
     
    if feature.feature == "gene"
      gene = "#{feature.qualifiers[0].value}" 
      #the seqid is the gene AGI with a counter (.n) to distinguish different "cttctt" repetitions
    end
    
    if feature.feature == "exon"
       unless feature.position.match(complement)
         exon_pos[i] = feature.position.split("..")
         exon_seq[i] = seq["#{exon_pos[i][0]}".to_i.."#{exon_pos[i][1]}".to_i]
         if cttctt_match.match(exon_seq[i])
              cttctt_coordinates[j] = [exon_seq[i].enum_for(:scan, /cttctt/i).map { Regexp.last_match.begin(0) }[0] + exon_pos[i][0].to_i, exon_seq[i].enum_for(:scan, /cttctt/i).map { Regexp.last_match.end(0) }[0] + exon_pos[i][0].to_i - 1].uniq.compact 
               #we substract -1 at the end in order to get the real ending position (and not like an ruby array numeration)
              j=j+1
        end
        i=i+1
       end
    end
    cttctt_pos = cttctt_coordinates.uniq.compact
  end

  features = Bio::Feature.new('cttctt', cttctt_pos)
  features.append(Bio::Feature::Qualifier.new('sequence', 'cttctt'))
  embl.features << features
  embl.features

    counter = 1
  embl.features.each do |feature|
    
    if feature.feature == "gene"
      seqid = "#{feature.qualifiers[0].value}" + ".#{counter}" 
      #the seqid is the gene AGI with a counter (.n) to distinguish different "cttctt" repetitions
    end

    next unless feature.feature == "cttctt"
    feature.position.each do |pos| 
      start_pos = "#{pos[0]}".to_s
      end_pos = "#{pos[1]}".to_s
      fields = [seqid, source, type, start_pos, end_pos, score, strand, phase, attributes]
      new_line = fields.join("\t") + "\n"
      gff3.write(new_line)
      counter = counter + 1 #we increment the counter by 1
      seqid = "#{seqid.split(".")[0]}" + ".#{counter}" 
       
    end
  end
end
gff3.close