class Gene_to_Seed_Stock
  
  attr_accessor :gene_id
  attr_accessor :gene_name
  attr_accessor :mutant_phenotype
  
  attr_accessor :seed_stock
  attr_accessor :last_planted
  attr_accessor :storage
  attr_accessor :grams_remaining
  
    def initialize (line = "", line2 ="")
    newdata = line.split("\t")
    gene_id = newdata[0]
    name = newdata[1] 
    phenotype = newdata[2].partition("\n")[0]
    
    newdata = line2.split("\t")
    seed_stock = newdata[0]
    gene_id = newdata[1] 
    last_planted = newdata[2]
    storage = newdata[3]
    grams_remaining = newdata[4].partition("\n")[0].to_i
    
    match_id = Regexp.new(/A[Tt]\d[Gg]\d\d\d\d\d/)
   
    
    if match_id.match(gene_id)
    @gene_id = gene_id
    else
    puts "WARNING: the gen id '#{id}' is not in the correct format"
    @gene_id = "null"
    end    
    
    @gene_name = name
    @mutant_phenotype = phenotype
    
    @seed_stock = seed_stock
    @gene_id = gene_id
    @last_planted = last_planted
    @storage = storage
    @grams_remaining = grams_remaining
    
  end

end