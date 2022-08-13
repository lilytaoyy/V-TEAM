# AIM 3 Analysis: 
# What are the relative frequencies of serious vs. non-serious adverse events (and general, all AEs) 
# for different groups of vaccine distributors?

#loading librarys
using DataFrames, CSV, Missings, Pipe, StatsBase, Query,  HypothesisTests

# load the labelled data
df = DataFrame(CSV.read("./data/19-21VAERSCOMB_L.csv", DataFrame));

# rewriting the get frequency code into function
# this function takes in one column name(default), or two column names
# and calculate the overall frequency/counts for col-AE (or col1-col2-AE) pairs 
function get_freq(df, col1, col2 = nothing)
    
    # when only one column name specified
    if isnothing(col2)

        # one observation is associated with 5 symptom columns, 
        # calculate the frequency/counts for col1-AE pairs separately by symptom column
        count1 = dropmissing(rename!(combine(groupby(df, [Symbol(col1), :SYMPTOM1]), 
                    nrow => :COUNT), :SYMPTOM1 => :SYMPTOM), :SYMPTOM);
        count2 = dropmissing(rename!(combine(groupby(df, [Symbol(col1), :SYMPTOM2]), 
                    nrow => :COUNT), :SYMPTOM2 => :SYMPTOM), :SYMPTOM);
        count3 = dropmissing(rename!(combine(groupby(df, [Symbol(col1), :SYMPTOM3]), 
                    nrow => :COUNT), :SYMPTOM3 => :SYMPTOM), :SYMPTOM);
        count4 = dropmissing(rename!(combine(groupby(df, [Symbol(col1), :SYMPTOM4]), 
                    nrow => :COUNT), :SYMPTOM4 => :SYMPTOM), :SYMPTOM);
        count5 = dropmissing(rename!(combine(groupby(df, [Symbol(col1), :SYMPTOM5]), 
                    nrow => :COUNT), :SYMPTOM5 => :SYMPTOM), :SYMPTOM);
        
        # concatenating, note that col1-AE pairs may not be unique at this step            
        count_raw = reduce(vcat, [count1, count2, count3, count4, count5]);
        
        # recalculating frequency/counts by summing up the counts for non-unique col1-AE pairs
        count = combine(groupby(count_raw, [Symbol(col1), :SYMPTOM]), :COUNT => sum)

    # when two column names specified   
    else
        count1 = dropmissing(rename!(combine(groupby(df, [Symbol(col1), Symbol(col2), :SYMPTOM1]), 
                    nrow => :COUNT), :SYMPTOM1 => :SYMPTOM), :SYMPTOM);
        count2 = dropmissing(rename!(combine(groupby(df, [Symbol(col1), Symbol(col2), :SYMPTOM2]), 
                    nrow => :COUNT), :SYMPTOM2 => :SYMPTOM), :SYMPTOM);
        count3 = dropmissing(rename!(combine(groupby(df, [Symbol(col1), Symbol(col2), :SYMPTOM3]), 
                    nrow => :COUNT), :SYMPTOM3 => :SYMPTOM), :SYMPTOM);
        count4 = dropmissing(rename!(combine(groupby(df, [Symbol(col1), Symbol(col2), :SYMPTOM4]), 
                    nrow => :COUNT), :SYMPTOM4 => :SYMPTOM), :SYMPTOM);
        count5 = dropmissing(rename!(combine(groupby(df, [Symbol(col1), Symbol(col2), :SYMPTOM5]), 
                    nrow => :COUNT), :SYMPTOM5 => :SYMPTOM), :SYMPTOM);
        
        count_raw = reduce(vcat, [count1, count2, count3, count4, count5]);
        
        count = combine(groupby(count_raw, [Symbol(col1), Symbol(col2), :SYMPTOM]), :COUNT => sum)
    end
    return count
end


#get the manufacturer w/ the most frequent aderse event overall
tb1 = sort!(get_freq(df, "VAX_MANU"), :COUNT_sum, rev = true)

#get the manufacturer with most frequent non-serious adverse event overall
tb2 = sort!(filter(x -> x.SERIOUS_EVENT == 0, get_freq(df, "VAX_MANU", "SERIOUS_EVENT")), :COUNT_sum, rev = true)

#get the manufacturer with most frequent non-serious adverse event overall
tb3 = sort!(filter(x -> x.SERIOUS_EVENT == 1, get_freq(df, "VAX_MANU", "SERIOUS_EVENT")), :COUNT_sum, rev = true)

# top 10 manufacturers people got vaccines from
manu10 = sort!(combine(groupby(df, :VAX_MANU), nrow => :CT), :CT, rev=true)[1:11, 1][1:end .!= 7]

# get relative frequency of AE by manufacturer, sorted
filtered = filter(row -> row.VAX_MANU ∈ manu10, tb1);
sort(transform(groupby(filtered, :VAX_MANU), :COUNT_sum => (x -> x / sum(x)) => :freq), :freq, rev=true)

# get relative frequency of non-serious AE by manufacturer, sorted
filtered_n_serious = filter(row -> row.VAX_MANU ∈ manu10, tb2);
show(sort(transform(groupby(filtered_n_serious, :VAX_MANU), :COUNT_sum => (x -> x / sum(x)) => :freq), :freq, rev=true), allcols = true)

# get relative frequency of serious AE by manufacturer, sorted
filtered_serious = filter(row -> row.VAX_MANU ∈ manu10, tb3);
show(sort(transform(groupby(filtered_serious, :VAX_MANU), :COUNT_sum => (x -> x / sum(x)) => :freq), :freq, rev=true), allcols = true)

# hypothesis testing
# perform unequal variance t test to investigate the difference in mean # AE reports across distributors

# get counts
moderna = filter(x -> x.VAX_MANU .== "MODERNA", tb1).COUNT_sum;
pfizer = filter(x -> x.VAX_MANU .== "PFIZER\\BIONTECH", tb1).COUNT_sum;
seqirus = filter(x -> x.VAX_MANU .== "SEQIRUS, INC.", tb1).COUNT_sum;

# moderna vs. pfizer (top 2 distributors having the highest relative freq of non-serious AE)
UnequalVarianceTTest(moderna, pfizer)

# moderna vs. seqirus (top 2 distributors having the highest relative freq of serious AE)
UnequalVarianceTTest(moderna, seqirus)

