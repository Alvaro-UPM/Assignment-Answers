=begin
Here, we simply open the file and we obtain the lines (using File.readlines that separate at "\n".
Since each line is a AGI and the final "\n", we remove this "\n" from each line and we get the "clean" AGIs from our file in an array.
Later, we enter these array in our class Gen as input.
Note that subnetwork means that we are using one of the subnetworks analyzed in the scientific paper of the task.
=end

subnetwork = File.new("./ArabidopsisSubNetwork_GeneList.txt", "r")

subnetwork_lines = File.readlines(subnetwork)
subnetwork_lines
subnetwork_array = []
i=0
subnetwork_lines.each do |x|
  subnetwork_array[i] = subnetwork_lines[i].partition("\n")[0]
  i=i+1
end
subnetwork_array


=begin
Here we are requiring the class.
We use "./" and the name of the file
because we are going to have the files
in the same folder.
=end

require "./Gene_Class.rb"

i=0
subnetwork_gen = []
subnetwork_array.each do |x|
  subnetwork_gen[i] = Gen.new(x)
i=i+1
end
subnetwork_gen


=begin
Here, we code for the obtain the direct interactions between our original 168 AGIs list
=end

original_agi = [] #We first introduce again the AGIs that we were able to enter in our class Gen in a new array (for preventing errors)
m=0
subnetwork_gen.each do |x|
  original_agi[m] = subnetwork_gen[m].gen_agi
  m=m+1
end
  
#Next, we compare itiratively each original AGI with each first interactor obtained in our class Gen. 
#And if they match we introduce that original AGI and the one from which we use it first interaction 
#in an array of arrays direct interactions (each array of that array, two original AGIs list genes that interact)
direct_interactions = []
each_group_interactor = []
k=0
l=0
subnetwork_gen.each do |x|
  each_group_interactor = subnetwork_gen[l].gen_interactions
  i=0
  each_interactor = []
    each_group_interactor.each do |x|
      each_interactor = each_group_interactor[i]
      j=0
      each_agi = []
        original_agi.each do |x|
        each_agi = original_agi[j]
          if each_interactor == each_agi
            direct_interactions[k] = subnetwork_gen[l].gen_agi, original_agi[j]
            k=k+1
          end
          j=j+1
        end
        i=i+1
    end
    l=l+1
end
direct_interactions


=begin
Here, we use a similar strategy for obtained indirect interactions 
(mediated for other gene that is not in the origina AGIs list). 
We obtain a final array of array and, in this case, each array contains 3 genes. 
One of the original genes, the "mediator" gene (always in the middle position) 
and the other original gene that interact indirectly with the first one.
=end

indirect_interactions = []
each_group_interactor = []
k=0
l=0
subnetwork_gen.each do |x|
  n=0
  each_group_interactor = subnetwork_gen[l].gen_interactions2
  each_subgroup_interactor = []
  each_group_interactor.each do |x|
    each_subgroup_interactor = subnetwork_gen[l].gen_interactions2[n]
    i=0
    each_interactor = []
      each_subgroup_interactor.each do |x|
        each_interactor = each_subgroup_interactor[i]
        j=l
        each_agi = []
          original_agi.each do |x|
          each_agi = original_agi[j]
            if each_interactor == each_agi
              indirect_interactions[k] = subnetwork_gen[l].gen_agi, subnetwork_gen[l].gen_interactions[n], original_agi[j]
              k=k+1
            end
            j=j+1
          end
          i=i+1
      end
      n=n+1
      end
      l=l+1
  end
indirect_interactions