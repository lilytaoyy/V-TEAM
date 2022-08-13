using CSV, DataFrames,FreqTables, Plots, StatsPlots, StatsBase, Missings, StatsBase;

df = DataFrame(CSV.read("//files.brown.edu/Home/bmosong/Desktop/19-21VAERSCOMB_clean.csv", DataFrame));

# Adrew's code starts here
# Convert SYMPTOMS strings back to an array of strings 
a = fill([], size(df,1));

for rownumber in 1:size(df, 1)
    str_symptoms = df[rownumber,:SYMPTOMS]
    str_index_start = findfirst(isequal('['), str_symptoms)+2
    str_index_end = findfirst(isequal(']'), str_symptoms)-2
    a[rownumber] = split(df[rownumber,:SYMPTOMS][str_index_start:str_index_end], "\", \"")
end;

df.SYMPTOMS = a;

# Create dictionary for VAX_NAME:SYMPTOM
# Step 1: create the dict 
vax_to_symptoms_dict = Dict{String, Set{String}}()
# Step 2: populate the keys (VAERS_ID) of the dict
for rownumber in 1:size(df, 1)
    vax_name = df[rownumber, :VAX_NAME]
    if !haskey(vax_to_symptoms_dict, vax_name)
        # this is the set where we will store all of the symptoms for this VAX_NAME
        vax_to_symptoms_dict[vax_name] = Set{String}()
    end
end
# Step 3: populate the values (SYMPTOMS) of the dict
for rownumber in 1:size(df, 1)
    vax_name = df[rownumber, :VAX_NAME]
    symptoms = df[rownumber, :SYMPTOMS]
    for symptom in symptoms 
        push!(vax_to_symptoms_dict[vax_name], symptom)
    end
end
# View dict
vax_to_symptoms_dict

function get_freqtable(df, vax_name, symptom)
    temp = select(df, ["VAX_NAME", "SYMPTOMS"])
    # Create dummy variable for vax_name
    temp.TARGET_VAX= (temp.VAX_NAME .== vax_name)
    # Create dummy variable for symptom
    temp.TARGET_SYMPTOM = zeros(size(temp, 1))
    for rownumber in 1:size(temp, 1)
        if symptom in temp[rownumber,:SYMPTOMS]
            temp[rownumber,:TARGET_SYMPTOM] = 1
        end
    end
    
    # Create frequency table
    tbl = freqtable(temp, :TARGET_VAX, :TARGET_SYMPTOM)
    return tbl
end;

function get_PRR(tbl)
    # Calculate PRR
    a = tbl[2,2]
    b = tbl[2,1]
    c = tbl[1,2]
    d = tbl[1,1]
    PRR = (a/(a+b))/(c/(c+d))
    
    return PRR
end;

# Andrews code ends here


#=
Analysing top 5 symptoms in top 5 vaccines
COVID19 (COVID19 (PFIZER-BIONTECH)), ZOSTER (SHINGRIX), COVID19 (COVID19 (MODERNA)), 
PNEUMO (PNEUMOVAX), COVID19 (COVID19 (JANSSEN)) 
=#

list_symptoms_mostlikely = Dict{String, Vector{String}}()

for vax in ["COVID19 (COVID19 (PFIZER-BIONTECH))", 
            "ZOSTER (SHINGRIX)",
            "COVID19 (COVID19 (MODERNA))",
            "PNEUMO (PNEUMOVAX)",
            "COVID19 (COVID19 (JANSSEN))"]
    # Create dict of most reported symptoms for each vaccine
    df_vax = filter(row -> row.VAX_NAME == vax, df)

    symptoms_all_dupes = reduce(vcat, df_vax.SYMPTOMS)
    symptoms_freq_dict = StatsBase.countmap(symptoms_all_dupes)
    list_symptoms = unique(reduce(vcat, df_vax.SYMPTOMS))
    freq_per_symptom = [symptoms_freq_dict[val] for val in list_symptoms]
    perm = sortperm(freq_per_symptom; rev=true)
    # only pick the top 5 symptoms for each of the vaccine
    list_symptoms_mostlikely[vax] = list_symptoms[perm[1:5]]
end

prr_dict = Dict()

for (vax, symptoms) in list_symptoms_mostlikely
    symp_prr = []
    for symptom in symptoms 
        push!(symp_prr, string(symptom, "(PRR: ", 
                round(get_PRR(get_freqtable(df, vax, symptom)); digits=2), ")"))
    end 
    prr_dict[vax] = symp_prr
end
prr_dict