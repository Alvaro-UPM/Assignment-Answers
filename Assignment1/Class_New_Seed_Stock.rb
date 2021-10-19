class New_Seed_Stock < Seed_Stock
  
=begin
In this case we use a different strategy.
This class inherits from Seed_Stock class.
We just produce a now value of the property @grams_remaining.
In the initialize methods we introduce "two variables" (between brackets).
The first one is use with "super", that way, it acts as the "line" input
for the "super" class (Seed_Stock). So, we can type there lines from a .tsv
file as the same way we do with the other classes. The second "variable"
is use to specify the munber of grams from each stock that are going to be planted.
end
=end
  
  def initialize (line, grams_planted)
    super(line)
    new_grams_remaining = grams_remaining.to_i - grams_planted.to_i
    if new_grams_remaining <= 0
      new_grams_remaining = 0
      puts "WARNING: we have run out of Seed Stock #{@seed_stock}"
    end
  @grams_remaining = new_grams_remaining
  end
end