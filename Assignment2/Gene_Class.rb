class Gen
  
=begin
  We are going to use this class called "Gen" to obtain the "first" and "second" level of gen's interactions 
  (@gen_interactions1 and @gen_interactions2, respectively) of our 168 genes (in our AGIs list). 
  For achieve that, we are going to use the BAR database from UToronto because we can use the AGIs as "input"
  and we can obtain the AGIs of the interactors as the "output"
=end
  
#We define the class' properties
  attr_accessor :gen_agi
  attr_accessor :gen_interactions
  attr_accessor :gen_interactions2
  
   def initialize (gen_agi = "") #The input is going to be a string (each AGI from our 168 AGIs' list)
     
    match_agi = Regexp.new(/AT[[1-5]MC]G\d\d\d\d\d/i) 
    #We use a Regular Expression to check if the AGI format is correct
    
    if match_agi.match(gen_agi)
      @gen_agi = gen_agi.downcase 
      #We covert it into downcase (lowercase) to make more easy the future "comparations" between them to obtain the interactions
    else 
      puts "WARNING! AGI format incorrect"
    end
     
     require 'rest-client'  

     # This is the function called "fetch" from Lectures that we can re-use everywhere in our code
     
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
     
     res = fetch("http://bar.utoronto.ca:9090/psicquic/webservices/current/search/query/#{@gen_agi}?format=tab25");
     # As we said, we search our AGIs (input) in the database BAR (URL obtained from PSICQUIC services) 
     #and we obtain the output as format=tab25 (string separated in column by "\t" and separated in row by "\n")
     
      if res #we check that we have obtained a response
        body = res.body  #we define body as the response's body (a string)
      else
        puts "the Web call failed for #{@gen_agi} - see STDERR for details..."
      end
     
    body_lines = body.split("\n") #we separate the different lines (or rows) of body splicing the string at "\n" 
    a=0
    body_lines_columns = []
    body_lines.each do |x|
      body_lines_columns[a] = body_lines[a].split("\t") #we separates the previous lines into columns 
      #(obtained the string that is in a specific line and in a specific column) splicing at "\t"
      a=a+1
    end
     
=begin
Here below we make a selection of the columns that we want to use (because we do not need all of them).

If we have a look at the columns that we obtained in the output when we call the web API, these are the following (an only 1 row example):
uniprotkb:P93292	uniprotkb:Q9S7M0	tair:AtMg00280	tair:At5g54270	tair:ORF110A	tair:LHCB3|tair:LHCB3*1	-	-	pubmed:17675552	taxid:3702	taxid:3702	-	psi-mi:"MI:2165"(BAR)	-	intact-miscore:0.9

Above, we can see that the columns in which we are interested are the 3º, 4º (each of these two has an AGI from an reported interaction),
the 10º, 11º (each of these two has the taxid of previous AGI's specie, respectively) and the 15º in which we have 
the intact-miscore (the intact-miscore The MIscore is a normalized score (from 0 to 1) based on
the number of publications reporting the interaction). So we select only these 5 columns to continue with.
=end
    all_columns_selection = [] #here we are going to have the selected column from all the rows
    c=0
    body_lines_columns.each do |x|
      d = 0
      selected_columns = [2,3,9,10,14] #selected columns
      columns_selection = [] #we use it to itinerate each row, selecting the column that we want and we pass it to all_columns_selection later
      selected_columns.each do |x|
        columns_selection[d] = body_lines_columns[c][selected_columns[d]].split(":")[1] #We do this split to obtain only the "data" part
        #and, that way, remove the key that is before the ":" (for example: intact-miscore:0.9)
        d = d+1
      end
      all_columns_selection[c] = columns_selection
      c=c+1
    end
    
=begin
Next, we obtain the firt interactions of our input AGI. Since we know that the first and second columns
(from the selected ones) contain AGI of an interaction we are going to use that. We have to be caution of not getting the same input AGI
as an interior, since it is usually in one of these two columns (logically). 

In the comparations between AGIs (equals or not equals) we use always downcase to prevent from errors due to different case.
=end
    interactions = []
    each_column = []
    e=0
    g=0
    all_columns_selection.each do |x|
      each_column = all_columns_selection[e]
      if each_column[4].to_f > 0.7 and each_column[3] == "3702" and each_column[2] == "3702" 
        #First, we filter that the specie of both interactors is Arabidopsis thaliana (taxid: 3702) and that the intact-miscore of the interaction is, at least, 0.7.
        if each_column[0].downcase != "#{@gen_agi}".downcase #Here we get the AGI from the first column only if it is different fron our input AGI
          interactions[g] = each_column[0].downcase
          g=g+1
        elsif each_column[1].downcase != "#{@gen_agi}".downcase #Here the same, we get the AGI from the second column only if it is different fron our input AGI
          interactions[g] = each_column[1].downcase
          g=g+1
        else
          g=g
        end
      end
      e=e+1
    end
    
    @gen_interactions = interactions #We collect the results in the class property "@gen_interactions"

=begin
Next, we are going to obtain the second interations of our input AGI. 
We create an iterative loop in which we use the first interations' AGIs as input in the Web API call.  
And after that, we use the same strategy to obtain the interactions of these interactions. 
Then, we obatin the second interactions of our original 168 AGIs list.
=end

     
    f=0
    interactions2 = []
    interactions.each do |x|
      res = fetch("http://bar.utoronto.ca:9090/psicquic/webservices/current/search/query/#{@gen_interactions[f]}?format=tab25");

        if res 
          body = res.body  
        else
          puts "the Web call failed for #{@gen_interactions[f]} - see STDERR for details..."
        end

      body_lines = body.split("\n")  #same splicing at "\n"
      a=0
      body_lines_columns = []
      body_lines.each do |x|
        body_lines_columns[a] = body_lines[a].split("\t") #same splicing at "\t"
        a=a+1
      end

      all_columns_selection = []
      c=0
      body_lines_columns.each do |x|
        d = 0
        selected_columns = [2,3,9,10,14] #the same selected columns
        columns_selection = []
        selected_columns.each do |x|
          columns_selection[d] = body_lines_columns[c][selected_columns[d]].split(":")[1] #same splicing at ":"
          d = d+1
        end
        all_columns_selection[c] = columns_selection
        c=c+1
      end

      interactions = []
      each_column = []
      e=0
      g=0
      all_columns_selection.each do |x|
        each_column = all_columns_selection[e]
        if each_column[4].to_f > 0.7 and each_column[3] == "3702" and each_column[2] == "3702" 
            if each_column[0].downcase != "#{@gen_interactions[f]}".downcase and each_column[0].downcase != "#{@gen_agi}".downcase
              interactions[g] = each_column[0].downcase
              g=g+1
            elsif each_column[1].downcase != "#{@gen_interactions[f]}".downcase and each_column[1].downcase != "#{@gen_agi}".downcase
              interactions[g] = each_column[1].downcase
              g=g+1
            else
              g=g
            end
        else
          next
        end
        e=e+1
      end
    interactions2[f] = interactions
    f=f+1
    end
    
    @gen_interactions2 = interactions2 #We collect the final results in the class property "@gen_interactions2"
     
   end
  
end