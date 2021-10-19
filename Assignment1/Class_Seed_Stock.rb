class Seed_Stock
  attr_accessor :seed_stock
  attr_accessor :gene_id
  attr_accessor :last_planted
  attr_accessor :storage
  attr_accessor :grams_remaining
  
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
    seed_stock = newdata[0]
    gene_id = newdata[1] 
    last_planted = newdata[2]
    storage = newdata[3]
    grams_remaining = newdata[4].partition("\n")[0].to_i
    
    @seed_stock = seed_stock
    @gene_id = gene_id
    @last_planted = last_planted
    @storage = storage
    @grams_remaining = grams_remaining
    
      
  end
end