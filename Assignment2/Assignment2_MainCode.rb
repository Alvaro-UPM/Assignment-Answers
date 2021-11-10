=begin
Personal note:
I know that this code could be confusing (especially the direct and indirect interactions code), 
but it is the way that I found to obtain the results without (apparently) errors.
I think it takes me too long time to get to a (more or less) "good" approach for the assignment. 
I would have liked to do that sooner and, that way, 
could have had more time to done better and to enjoy even more the task (and also to get deeper interactions).
=end


=begin
Firstly, we simply open the file and we obtain the lines (using File.readlines that separate at "\n".
Since each line is a AGI and the final "\n", we remove this "\n" from each line and we get the "clean" AGIs from our file in an array.
Later, we enter these array in our class Gen as input.
Note that subnetwork means that we are using one of the subnetworks analyzed in the scientific paper of the task.
=end

subnetwork = File.new("/home/osboxes/Course/Assignment-Answers/Assignment2/ArabidopsisSubNetwork_GeneList.txt", "r")

subnetwork_lines = File.readlines(subnetwork)
subnetwork_lines
subnetwork_array = []
i=0
subnetwork_lines.each do |x|
  subnetwork_array[i] = subnetwork_lines[i].partition("\n")[0]
  i=i+1
end
subnetwork_array


require "./Gene_Class.rb"

=begin
Here we are requiring the Gene class.
We use "./" and the name of the file
because we are going to have the files
in the same folder.
=end

i=0
subnetwork_gen = []
subnetwork_array.each do |x|
  subnetwork_gen[i] = Gen.new(x) #apologies for the confusion between "gen" and "gene"
i=i+1
end
subnetwork_gen



=begin
Next, we code for the obtain the direct interactions between our original 168 AGIs list
=end

original_agi = [] #We first introduce again the AGIs that we were able to enter in our class Gen in a new array (for preventing errors)
m=0
subnetwork_gen.each do |x|
  original_agi[m] = subnetwork_gen[m].gen_agi
  m=m+1
end

=begin
Next, we compare itiratively each original AGI with each first interactor obtained in our class Gen. 
And if they match we introduce that original AGI and the one from which we use it first interaction 
in an array of arrays direct interactions (each array of that array, two original AGIs list genes that interact)
direct_interactions = []
=end

direct_interactions = []
each_group_interactor = []
k=0 #direct_interactions array's iterative parameter (+1 each time we add a new direct interaction)
l=0 #iterative parameter of the AGIs original introduced the Gene class, to go through them ("each_group_interactor array")
#and pick up their Gen class's AGIs
subnetwork_gen.each do |x|
  each_group_interactor = subnetwork_gen[l].gen_interactions
  i=0 #iterative parameter that take every single direct interaction ("each_interactor") of the group that is running at that moment
  each_interactor = []
    each_group_interactor.each do |x|
      each_interactor = each_group_interactor[i]
      j=0 #iterative parameter to obtain each original AGI into an array called "each_original_agi"
      each_original_agi = []
        original_agi.each do |x|
        each_original_agi = original_agi[j]
          if each_interactor == each_original_agi
            direct_interactions[k] = subnetwork_gen[l].gen_agi, original_agi[j]
               # if we have "match" then, we get together as an array into the "direct_interactions" array both genes: 
              # the original two AGIs that interact directly between them
            k=k+1 #if we have match we add +1 index to the "direct_interactions" array
          end
          j=j+1
        end
        i=i+1
    end
    l=l+1
#we add +1 to the iterative parameters at the correct moment
end
direct_interactions #final "direct_interactions" array



=begin
Next, we use a similar strategy for obtained indirect interactions 
(mediated for other gene that is not in the origina AGIs list). 
We obtain a final array of array and, in this case, each array contains 3 genes. 
One of the original genes, the "mediator" gene (always in the middle position) 
and the other original gene that interact indirectly with the first one.
=end

indirect_interactions = []
each_group_interactor = []
k=0 #indirect_interactions array's iterative parameter (+1 each time we add a new indirect interaction)
l=0 #iterative parameter of the AGIs original introduced the Gene class, to go through them ("each_group_interactor array")
#and pick up their respective second interactions
subnetwork_gen.each do |x|
  n=0 # second interactions iterative parameter ("each_subgroup_interactor array")
  #(it goes to zero when start with a new original AGI introduced in the class)
  each_group_interactor = subnetwork_gen[l].gen_interactions2
  each_subgroup_interactor = []
  each_group_interactor.each do |x|
    each_subgroup_interactor = subnetwork_gen[l].gen_interactions2[n]
    i=0 #iterative parameter that take every single second interaction ("each_interactor") of the subgroup that is running
      #at that moment
    each_interactor = []
      each_subgroup_interactor.each do |x|
        each_interactor = each_subgroup_interactor[i] 
        j=l #this is done to establish j (the original AGI iterative parameter) as the same value of l 
        #(the iterative parameter of the AGIs original introduced the Gene class). This way we do not repeat comparations.
        each_original_agi = []
          original_agi.each do |x|
          each_original_agi = original_agi[j] #we use j to create a new array with the original AGI ("each_original_agi")
            #(since j=l at the beginning of each loop, we do not repeat indirect interactions between the original AGIs)
            if each_interactor == each_original_agi 
              indirect_interactions[k] = subnetwork_gen[l].gen_agi, subnetwork_gen[l].gen_interactions[n], original_agi[j]
              # if we have "match" then, we get together as an array into the "indirect_interactions" array three genes:
              # the original two AGIs that interact indirectly and the "mediator" gene (in the middle position)
              k=k+1 #if we have match we add +1 index to the "indirect_interactions" array
            end
            j=j+1
          end
          i=i+1
      end
      n=n+1
      end
      l=l+1
#we add +1 to the iterative parameters at the correct moment
  end
indirect_interactions #final "indirect_interactions" array