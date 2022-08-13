# Code for getting AE frequency

using DataFrames, CSV, Missings

df = DataFrame(CSV.read("19-21VAERSCOMB.csv", DataFrame)); #load data
df = df[(.!ismissing.(df.AGE_YRS)) .& (df.AGE_YRS .>= 16), :]; #filter age
#labeling of events as serious or non-serious
a = (df.DIED .== "Y") .| (df.L_THREAT .== "Y") .| (df.HOSPITAL .== "Y") .| (df.X_STAY .== "Y") .| (df.DISABLE .== "Y")
df.SERIOUS_EVENT = replace(a, missing => 0)
show(names(df))

# one observation is associated with 5 symptom columns, calculate the frequency/counts for vaccine-AE pairs by column
# rename column names: symptom# to symptom 
# drop any missing
symp1_freq = dropmissing(rename!(combine(groupby(df, [:VAX_NAME, :SYMPTOM1]), 
            nrow => :COUNT), :SYMPTOM1 => :SYMPTOM), :SYMPTOM);
symp2_freq = dropmissing(rename!(combine(groupby(df, [:VAX_NAME, :SYMPTOM2]), 
            nrow => :COUNT), :SYMPTOM2 => :SYMPTOM), :SYMPTOM);
symp3_freq = dropmissing(rename!(combine(groupby(df, [:VAX_NAME, :SYMPTOM3]), 
            nrow => :COUNT), :SYMPTOM3 => :SYMPTOM), :SYMPTOM);
symp4_freq = dropmissing(rename!(combine(groupby(df, [:VAX_NAME, :SYMPTOM4]), 
            nrow => :COUNT), :SYMPTOM4 => :SYMPTOM), :SYMPTOM);
symp5_freq = dropmissing(rename!(combine(groupby(df, [:VAX_NAME, :SYMPTOM5]), 
            nrow => :COUNT), :SYMPTOM5 => :SYMPTOM), :SYMPTOM);

# concatenate 5 frequency tables, note that vaccine-AE pairs may not be unique at this step       
symp_freq_raw = reduce(vcat, [symp1_freq, symp2_freq, symp3_freq, symp4_freq, symp5_freq]);

# recalculate frequency/counts by summing up the counts for non-unique vaccine-AE pairs, SORTED
symp_freq = sort!(combine(groupby(symp_freq_raw, [:VAX_NAME, :SYMPTOM]), :COUNT => sum), :COUNT_sum, rev = true)