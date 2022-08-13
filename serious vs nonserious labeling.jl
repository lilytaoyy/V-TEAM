# LOAD IN PACKAGES AND DATA

using DataFrames, CSV, Plots, StatsPlots, StatsBase, Missings

df = DataFrame(CSV.read("Desktop/19-21VAERSCOMB_v2.csv", DataFrame));

#EXPLORATORY DATA ANALYSIS
summary(df) #size of the dataset
first(df, 10) #display the first 10 rows
show(names(df)) #display colnames

df = df[(.!ismissing.(df.AGE_YRS)) .& (df.AGE_YRS .>= 16), :] #filter age >= 16
vax_ct = countmap(df[!, :VAX_NAME])



sort(vax_ct, byvalue=true, rev=true)

size(df)

death_ct = countmap(df[!, :DIED])

sort(death_ct, byvalue=true, rev=true)
threat_ct = countmap(df[!, :L_THREAT])

sort(threat_ct, byvalue=true, rev=true)
hos_ct = countmap(df[!, :HOSPITAL])


sort(hos_ct, byvalue=true, rev=true)

#Days in hospital Histogram
histogram(filter(x -> !(ismissing(x) || isnan(x)), df[!, :HOSPDAYS]),
    bins=600,xlim=(0,100),xlabel="HOSPDAYS",labels="Frequency")


#Age Histogram
histogram(filter(x -> !(ismissing(x) || isnan(x)), df[!, :AGE_YRS]),
    xlabel="AGE",labels="Frequency")

#labeling of events as serious or non-serious
a = (df.DIED .== "Y") .| (df.L_THREAT .== "Y") .| (df.HOSPITAL .== "Y") .| (df.X_STAY .== "Y") .| 
(df.DISABLE .== "Y") .| (df.BIRTH_DEFECT .== "Y") 

df.SERIOUS_EVENT = replace(a, missing => 0)

show(names(df)) 







#count # of serious event
sum(df.SERIOUS_EVENT)

#SERIOUS_EVENT =1 is serious and SERIOUS_EVENT=0 is non-serious adverse event
#find most frequent serious adverse event - pull from SYMPTOM1, SYMPTOM2, SYMPTOM3, SYMPTOM4, SYMPTOM5
#find most frequent non-serious adverse event - pull from SYMPTOM1, SYMPTOM2, SYMPTOM3, SYMPTOM4, SYMPTOM5
df_nonserious = df[df.SERIOUS_EVENT .== 0, :]
df_serious = df[df.SERIOUS_EVENT .== 1, :]

df_SERIOUS = combine(groupby(combine(groupby(df, :VAERS_ID), 
            :SERIOUS_EVENT=>:SERIOUS_EVENT), :SERIOUS_EVENT), nrow => 
    :COUNT);
df_SERIOUS
