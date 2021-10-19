class Cross
  attr_accessor :parent1
  attr_accessor :parent2
  attr_accessor :f2_wild
  attr_accessor :f2_p1
  attr_accessor :f2_p2
  attr_accessor :f2_p1p1
  attr_accessor :chisquare
  
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
    parent1 = newdata[0]
    parent2 = newdata[1] 
    f2_wild = newdata[2].to_f
    f2_p1 = newdata[3].to_f
    f2_p2 = newdata[4].to_i.to_f
    f2_p1p2 = newdata[5].partition("\n")[0].to_f
    
    f2_wild_expected = ((f2_wild+f2_p1+f2_p2+f2_p1p2)/16)*9
    f2_p1_expected  = ((f2_wild+f2_p1+f2_p2+f2_p1p2)/16)*3
    f2_p2_expected = ((f2_wild+f2_p1+f2_p2+f2_p1p2)/16)*3
    f2_p1p2_expected  = (f2_wild+f2_p1+f2_p2+f2_p1p2)/16
    chisquare = (((f2_wild-f2_wild_expected)**2)/f2_wild_expected)+(((f2_p1-f2_p1_expected)**2)/f2_p1_expected)+(((f2_p2-f2_p2_expected)**2)/f2_p2_expected)+(((f2_p1p2-f2_p1p2_expected)**2)/f2_p1p2_expected)
    
    @parent1 = parent1
    @parent2 = parent2
    @f2_wild = f2_wild
    @f2_p1 = f2_p1
    @f2_p2 = f2_p2
    @f2_p1p2 = f2_p1p2
    @chisquare = chisquare
    
  end
   
end