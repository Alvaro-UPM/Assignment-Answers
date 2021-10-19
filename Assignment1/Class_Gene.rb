class Gene
  
  attr_accessor :gene_id
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype
  
=begin
Strategy to define the method initialize of a class:

We use the exactly same strategy for every class that we define.
So, this comment is going to be the same (except in New_Seed_Stock class).

We set the variable line as the input for the method initialize.
This line is a string in the same row
(so, we change the line when a "\n" appears).
As long as we are going to use .tsv file as input,
we create an array with "line.split("\t").
The elements of this array are the strings separate
with a "\t" in the line that we use as input.
So, in this case, the columns of a specific row from the .tsv file
That way, we are able to assign each column of the .tsv file
to a property of the class objects.
=end

  def initialize (line = "")
    newdata = line.split("\t")
    gene_id = newdata[0]
    name = newdata[1] 
    phenotype = newdata[2].partition("\n")[0]#
    
    #this is pretended to by the answers to the bonus 1
    #.................start answers to the bonus 1.......................
    match_id = Regexp.new(/A[Tt]\d[Gg]\d\d\d\d\d/)
   
    
    if match_id.match(gene_id)
    @gene_id = gene_id
    else
    puts "WARNING: the gen id '#{id}' is not in the correct format"
    @gene_id = "null"
    end
   #.................end answers to the bonus 1....................    
    
    @gene_name = name
    @mutant_phenotype = phenotype
      
  end 
end