=begin
We create this class to introduce the interaction networks with only the members of the original gene list 
that interact with each other since the task as for that. And we define two methods to get all the KEGG annotations 
(ID and Pathway Name) and GO annotations (ID and Term Name only from the biological_process part) of the genes inside 
that interaction network. So, this class has three attributes: interaction_network, kegg_annotations and go_annotations.
=end

class InteractionNetwork
  
  attr_accessor :interaction_network
  attr_accessor :kegg_annotations
  attr_accessor :go_annotations
  
  #We introduce the arrays with our interaction networks as an array.
  def initialize (interaction_network = []) 
    interaction_network.each do |x|
      match_agi = Regexp.new(/AT[[1-5]MC]G\d\d\d\d\d/i)
      unless match_agi.match(x) #We use a Regular Expression to check if the AGI format is correct
         puts "WARNING! AGI format incorrect"
      end
    end
    @interaction_network = interaction_network
  end
      
    require 'rest-client' 
    require 'json'
      
         # This is the function called "fetch" from Lectures that we can re-use everywhere in our code
     #................................
     
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
     
     #.................................
     
  def get_kegg
    kegg_annotations = [] #array containing all the kegg annotations of the interaction network.
    
    #To get the annotations from all the gene inside the interaction network, we do a .each loop.
    interaction_network.each do |x|
      kegg = fetch("http://togows.org/entry/kegg-genes/ath:#{x}/pathways.json") 
      #We use Togo for obtaining the pathways introducing the gene AGI (in this case "x")
      kegg = JSON.parse(kegg) #we require it in json format
      
      #Since we get one hash containing the KEGG ID as key and the Pathway name as value inside an array, 
      #we do the following.
      
        kegg_keys = kegg[0].keys.uniq #We get the keys and the values of that hash
        kegg_values = kegg[0].values.uniq 
      
      #And we introduce both inside the kegg array starting in kegg[0] and itinerating each time.
      #This way we get a final array called "kegg_annotations" 
      #in which each element is an string contaiting "KEGG ID KEGG PathwayName"
      
        i=0
        kegg_keys.each do |x|
          kegg[i] = kegg_keys[i] + " " + kegg_values[i]
          i=i+1
        end
      kegg_annotations = kegg_annotations.concat(kegg).uniq.compact 
      #We use concat to introduce each single kegg (only from one gene) in an array containing all the found annotations
      
      kegg_annotations = kegg_annotations.uniq.compact
      #We make it uniq and compact to avoid repetitions or nil
    end
      @kegg_annotations = kegg_annotations
  end
      

  def get_go
    go_annotations = [] #array containing all the kegg annotations of the interaction network.
    
    go = [] #we create an empty array equivalent to the "kegg" one of the las method, 
    #so here we are going to introduce the go annotations of the gene that is being running in the each lopp
    interaction_network.each do |x|
      uniprot_string = fetch("https://www.ebi.ac.uk/Tools/dbfetch/dbfetch?db=uniprotkb&id=#{x}")
      #we search for the information inside the entry of the database UniProt
      uniprot_arr = (uniprot_string.body).split("\n") 
      #we introduce the "body" inside an array in which its element is a line because we split at \n

      go_id = [] #here we are going to introduce the GO IDs of the "running" gene
      go_process = [] #here we are going to introduce the GO biological processes of the "running" gene
      
   #looking at the string we know in which "way" is written the GO ID and GO biological process inside the string,
    #so we create two (as much as possible) specific regular expressions to match them.
      match_process = Regexp.new(/;\sP:((\w|\s)+);/)
      match_id = Regexp.new(/id=GO:(\d{7})/)
      
      i=0
      uniprot_arr.each do |x|
        if match_process.match(x) and match_id.match(x) 
          #if a line inside the string contain two matches (this decreases more the possibility of mismatch)
          #then we introduce the "clean" part of both matches (between brackets, using [1]) as an element of "go" array
          #that way we get a clean sring in each element, such as: "GO ID GO Biological Process"
          go[i] = "#{match_id.match(x)[1]}" + " " + "#{match_process.match(x)[1]}"
          i = i+1
       end
      end
      go_annotations = go_annotations.concat(go)
      go_annotations = go_annotations.uniq.compact
    end
    @go_annotations = go_annotations
  end
      
end 