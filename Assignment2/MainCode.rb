=begin
First, we simply open the file and we obtain the lines (using File.readlines that split at "\n").
Since each line is a AGI and the final "\n", we remove this "\n" from each line and we get the "clean" AGIs 
from our file in an array ("original_agi").
Later, we introduce the strings (element) of this array in our class "Interactions" as input.
=end

original_list = File.new("./ArabidopsisSubNetwork_GeneList.txt", "r")

original_list_lines = File.readlines(original_list)

original_agi = []
i=0
original_list_lines.each do |x|
  original_agi[i] = original_list_lines[i].partition("\n")[0].downcase
    # We convert it into downcase (lowercase) to make more easy the future "comparations" between them to obtain the interactions
  i=i+1
end



require "./Interactions_Class.rb"
=begin
Here we are requiring the Interactions class.
We use "./" and the name of the file
because we are going to have the files
in the same folder.

This class create an instance for each original AGI
in which we have as attributes: 
gen_agi (a string with original AGI), 
gen_interactions (an array with the AGIs of its direct interactions in BAR database),
gen_interactions2 (an array of arrays with the AGIs of the interactions of each of its "gen_interactions" in BAR database).
=end

i=0
interactions_arr = []
original_agi.each do |x|
  interactions_arr[i] = Interactions.new(x) 
i=i+1
end


=begin
Here, we code for the obtain the direct interactions between our original 168 AGIs list

For that, we compare itiratively each original AGI with each first interactor (gen_interactions) obtained in our Interactions class. 
And if they match we introduce that original AGI and the one from which we use it first interaction 
in an array of arrays called "original_direct interactions" (in each array of that array
there are two original AGIs list genes that interact directly)
=end

original_direct_interactions = []
each_group_interactor = []
k=0 # original_direct_interactions array's iterative parameter (+1 each time we add a new direct interaction)
l=0 # iterative parameter of the AGIs original introduced the Gene class, to go through them ("each_group_interactor array")
# and pick up their Interactions class's AGIs
interactions_arr.each do |x|
  each_group_interactor = interactions_arr[l].gen_interactions
  i=0 # iterative parameter that take every single direct interaction ("each_interactor") of the group that is running at that moment
  each_interactor = []
    each_group_interactor.each do |x|
      each_interactor = each_group_interactor[i]
      j=l # iterative parameter to obtain each original AGI into an array called "each_original_agi"
      # j is equal to l (the iterative parameter of the AGIs original introduced the Gene class) to avoid repeating comparations.
      each_original_agi = []
        original_agi.each do |x|
        each_original_agi = original_agi[j]
          if each_interactor == each_original_agi
            original_direct_interactions[k] = interactions_arr[l].gen_agi, original_agi[j]
               # if we have "match" then, we get together as an array into the "direct_interactions" array both genes: 
              # the original two AGIs that interact directly between them
            k=k+1 #if we have match we add +1 index to the "direct_interactions" array
          end
          j=j+1
        end
        i=i+1
    end
    l=l+1
# we add +1 to the iterative parameters at the correct moment
end
original_direct_interactions #final "direct_interactions" array



=begin
Here, we use a similar strategy for obtained indirect interactions 
(mediated for other gene that is not in the origina AGIs list). 
We obtain a final array of array and, in this case, each array contains 3 genes. 
One of the original genes, the "mediator" gene (always in the middle position) 
and the other original gene that interact indirectly with the first one.
=end

original_indirect_interactions = []
each_group_interactor = []
k=0 # original_indirect_interactions array's iterative parameter (+1 each time we add a new indirect interaction)
l=0 # iterative parameter of the AGIs original introduced into the Gene class, to go through them ("each_group_interactor array")
# and pick up their respective second interactions
interactions_arr.each do |x|
  n=0 # second interactions iterative parameter ("each_subgroup_interactor array")
  #(it goes to zero when start with a new original AGI introduced in the class)
  each_group_interactor = interactions_arr[l].gen_interactions2
  each_subgroup_interactor = []
  each_group_interactor.each do |x|
    each_subgroup_interactor = interactions_arr[l].gen_interactions2[n]
    i=0 # iterative parameter that take every single second interaction ("each_interactor") of the subgroup that is running at that moment
    each_interactor = []
      each_subgroup_interactor.each do |x|
        each_interactor = each_subgroup_interactor[i] 
        j=l # j is equal to l (the iterative parameter of the AGIs original introduced the Gene class) to avoid repeating comparations.
        each_original_agi = []
          original_agi.each do |x|
          each_original_agi = original_agi[j] #we use j to create a new array with the original AGI ("each_original_agi")
            #(since j=l at the beginning of each loop, we do not repeat indirect interactions between the original AGIs)
            if each_interactor == each_original_agi 
              original_indirect_interactions[k] = interactions_arr[l].gen_agi, interactions_arr[l].gen_interactions[n], original_agi[j]
              # if we have "match" then, we get together as an array into the "indirect_interactions" array three genes (see in line below): 
              # the original two AGIs that interact indirectly and the "mediator" gene (in the middle position)
              k=k+1 # if we have match we add +1 index to the "indirect_interactions" array
            end
            j=j+1
          end
          i=i+1
      end
      n=n+1
      end
      l=l+1
# we add +1 to the iterative parameters at the correct moment
  end
original_indirect_interactions #final "indirect_interactions" array

all_interactions = original_direct_interactions + original_indirect_interactions

# we combine the direct and indirect interactions in an array called "all_interactions"

=begin
In order to establish the final interaction networks, we create a new array called "all_uniq" in which
each element is one of the genes that we have in all_interactions (without repetitions).
We are going to compare the elements in this array with the elements of each "interaction_group" in all_interactions
and we introduce all the groups that match with the same gene inside the same interaction network
(because they have, at least, one gene in common). But, after doing this process one time process
we could still having "interaction groups" with genes in common.
So, we create a code to repeat this process until the "interaction networks" obtained is equal to the last one,
because that means that we manage to get to the "final interactions networks" in which there are no more genes in common
between the different networks.
=end
all_uniq = []
i=0
all_interactions.each do |x|
  all_uniq = all_uniq.concat(all_interactions[i]).uniq
  i=i+1
end

# We use this code to achieve the "final_interaction_networks" array 
# using the strategy that we have explained in the last comment.
#...................
final_interaction_networks = []
breaker = 0 # we define breaker to do a while in which we itinerate
# looking for more genes in common between all the interaction networks
# until the interaction networks obtained are exactly the same as the previous one (and we change breaker to value 1)
while breaker == 0
  interaction_groups = []
  each=0
  all_uniq.each do |x|
    concat = [] #we define this empty for each "all_uniq" to make it easier to do the future concat
    #(and not mixing between itinerations)
    match_uniq = Regexp.new(/#{all_uniq[each]}/i) #regular expression for each "all_uniq" element
    m=0
    all_interactions.each do |x|
      group = all_interactions[m]
      n=0
      group.each do |x|
      agi = group[n]
        if match_uniq.match(agi) # if there is match between the "all_uniq" element and one agi of the interaction networks
          interaction_groups[each] = concat.concat(group)
        end
        n=n+1
        end
      m=m+1
      end
      interaction_groups = interaction_groups.uniq.compact
      each=each+1
  end
  if all_interactions != interaction_groups #if the interaction networks are not equal to the previous one (the first are "all_interactions)
    # then set "all_interactions" as the new "interaction_groups"
    all_interactions = interaction_groups
  else
    final_interaction_networks = interaction_groups # else, set "final_interaction_groups" as the actual "interaction_groups"
    breaker = 1 # and change the breaker value to 1 in order to end the initial while loop
  end
end
final_interaction_networks # here we have the final interaction networks that connect the genes of our original AGIs list
# including in th networks the "intermediates" genes that are not in our original list
#..................

=begin
Here, we use exactly the same strategy to get only the original genes of each "final_interaction_networks" element.
And we put them in a new array called "original_interaction_networks".
=end
original_interaction_networks = []
original_agi.each do |x|
    concat = []
    match_original = Regexp.new(/#{original_agi[each]}/i) 
    m=0
    final_interaction_networks.each do |x|
      group = final_interaction_networks[m]
      n=0
      group.each do |x|
      agi = group[n]
        if match_original.match(agi)
          agi_arr = [agi]
          original_interaction_networks[each] = concat.concat(agi_arr)
        end
        n=n+1
        end
      m=m+1
      end
      original_interaction_networks = original_interaction_networks.uniq.compact
      each=each+1
  end
original_interaction_networks



require "./InteractionNetwork_Class"

# We introduce the interaction networks inside the InteractionNetwork class to use its method get_kegg and get_go
# in order to get the KEGG and GO annotations
i=0
interaction_networks = []
original_interaction_networks.each do |x|
  interaction_networks[i] = InteractionNetwork.new(x) 
i=i+1
end


#...................Final Report.............
=begin
#In the report attached we do this but using the "all_interactions" array, that is using
all the direct and indirect interactions between the original list but without the integration of them into interaction networks.
I am sorry about that.
=end

report = File.open('report.txt','w')

i=0
interaction_networks.compact.each do |x|
  x = """Interaction Network #{i}
  These genes of the original list interact with each other direct or indirectly:
  #{interaction_networks[i].interaction_network}.
  
  Taking all of them into account we get the following KEGG annotations:
  #{interaction_networks[i].get_kegg}
  
  And the the following GO annotations:
  #{interaction_networks[i].get_go}
  """
  report.puts(x)
  i=i+1
end
report.close
  