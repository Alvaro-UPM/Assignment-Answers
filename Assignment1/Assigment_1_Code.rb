require "./Class_Gene.rb"
=begin
Here we are requiring the class.
We use "./" and the name of the file
because we are going to have the files
in the same folder in which we are running the code
=end

gene_information = File.new("./StockDatabaseDataFiles/gene_information.tsv", "r") 
=begin
Opening the file "gene_information.tsv".
We type "StockDatabaseDataFiles/"
before the file name because know that the file is going
to be inside a folder called "StockDatabaseDataFiles".
At the same time, his folder "StockDatabaseDataFiles"
is inside the folder in which we are running the code,
so we type "./" before all.
=end

gene_information_lines = File.readlines(gene_information) #we separate the file into lines (each line contains the properties we want for a class object) 
gene_information_lines.delete(gene_information_lines[0]) #we remove the headers

=begin
We do the following loop to create an array in which its elements 
are instances of the class. Each instance correspond to a row from the .tsv file.
And the properties of that instances correspond with the "string" of each column of that row.
The way we achieve that is explain with comments inside the classes files).

**We are going to use exactly the same strategy and steps
for creating the instances of the following classes:
"Seed_Stock", "New_Seed_Stock" and "Cross"**
=end

i=0
genes_array = []
gene_information_lines.each do |x|
  genes_array[i] = Gene.new(x)
  i=i+1
end
genes_array #just to check that the array has been correctly filled with the class instances (or objects) we want


require "./Class_Seed_Stock.rb" 

seed_stock_data = File.new("./StockDatabaseDataFiles/seed_stock_data.tsv", "r")

seed_stock_data_lines = File.readlines(seed_stock_data)
seed_stock_data_lines.delete(seed_stock_data_lines[0])
i=0
seed_stock_array = []
seed_stock_data_lines.each do |x|
  seed_stock_array[i] = Seed_Stock.new(x)
  i=i+1
end
seed_stock_array #checking

=begin
# Next, we have the key code to "simulate" planting
a specific number (here we choose 7)
of grams of seeds from each stock.
The way to achieve is explain inside the "Class_New_Seed_Stock" file.
=end
#...................start "simulate" planting code.................
require "./Class_New_Seed_Stock.rb" 

i=0
new_seed_stock_array = []
seed_stock_data_lines.each do |x| #we use the same lines as the previous one
  new_seed_stock_array[i] = New_Seed_Stock.new(x, 7) 
=begin
Here we have to specify the number of grams we are going to plant when doing "New_Seed_Stock.new".
This is integrate inside the class definition
=end
  i=i+1
end
new_seed_stock_array #checking
=begin
Here we obtain an array that is almost the same of "seed_stock_array",
but with 7 grams less (or 0 if there was less originally) in the "grams_remaining" property
=end
#...................end "simulate" planting code.................

require "./Class_Cross.rb"

cross_data = File.new("./StockDatabaseDataFiles/cross_data.tsv", "r")

cross_data_lines = File.readlines(cross_data)
cross_data_lines.delete(cross_data_lines[0])
i=0
cross_array = []
cross_data_lines.each do |x|
  cross_array[i] = Cross.new(x)
  i=i+1
end
cross_array #checking

=begin
In order to obtain the gene names of the genes that are related
we create a new class called "Gene_to_Seed_Stock" in which we combine
both gene_information.tsv and seed_stock_data.tsv in an new array of instance
with their columns as properties
=end
require "./Class_Gene_to_Seed_Stock.rb"

i=0
genes_seed_stock_array = []
gene_information_lines.each do |x|
  y = seed_stock_data_lines[i]
  genes_seed_stock_array[i] = Gene_to_Seed_Stock.new(x, y)
  i=i+1
end
genes_seed_stock_array #the new combined array

#we define this function to "traduce" a seed_stock to a gene_name using the genes_seed_stock_array
def seed_stock_to_gene (array, seed_stock)
 
  array.each do |x|
    if x.seed_stock == seed_stock
      return x.gene_name
    end
  end
  
end

=begin
#with this recorring the cross_array and using the "seed_stock_to_gene" function,
we are able to ask for the names of the genes that are genetically related 
=end
i=0
  cross_array.each do |chisquare|
  if cross_array[i].chisquare > 8
    puts "Recording: #{seed_stock_to_gene(genes_seed_stock_array, "#{cross_array[i].parent1}")} is genetically linked to #{seed_stock_to_gene(genes_seed_stock_array, "#{cross_array[i].parent2}")} with a chisquare score #{cross_array[i].chisquare}"
  end
  i=i+1
  end


#code to create a new .tsv file with the new state of the seeds stock
#.............start code to create a new file.......................
require "csv" #requiring csv to create a .csv file (but eventually making it .tsv)

CSV.open("new_stock_file.tsv", "w") do |tsv|
  tsv << ["Seed_Stock""\t""Mutant_Gen_ID""\t""Last_planted""\t""Storage""\t""Grams_Remaining"] #we manually add the headers that we want
  new_seed_stock_array.each do |x|
    tsv << [x.seed_stock.to_s+"\t"+x.gene_id.to_s+"\t"+x.last_planted.to_s+"\t"+x.storage.to_s+"\t"+x.grams_remaining.to_s]

=begin
Somehow, here we create a handmade .tsv file.
First, we use the method to create a .csv file, but we add "\t"
in the places that we want to separate the string into different columns.
So, finally we actually get a .tsv file (at least I think so).
=end
  end
end
#............end code to create a new file.......................
