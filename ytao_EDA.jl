# EDA (Version 1)

using DataFrames, CSV, Plots, StatsPlots, StatsBase, Missings

df = DataFrame(CSV.read("19-21VAERSCOMB.csv", DataFrame));
summary(df) #size of the dataset
first(df, 10) #display the first 10 rows
show(names(df)) #display colnames
df = df[(.!ismissing.(df.AGE_YRS)) .& (df.AGE_YRS .>= 16), :] #filter age >= 16

vax_ct = countmap(df[!, :VAX_NAME])
sort(vax_ct, byvalue=true, rev=true)

death_ct = countmap(df[!, :DIED])
sort(death_ct, byvalue=true, rev=true)

threat_ct = countmap(df[!, :L_THREAT])
sort(threat_ct, byvalue=true, rev=true)

hos_ct = countmap(df[!, :HOSPITAL])
sort(hos_ct, byvalue=true, rev=true)

#Days in hospital Histogram
histogram(filter(x -> !(ismissing(x) || isnothing(x) || isnan(x)), df[!, :HOSPDAYS]),
    bins=600,xlim=(0,100),xlabel="HOSPDAYS",labels="Frequency")

#Age Histogram
histogram(filter(x -> !(ismissing(x) || isnothing(x) || isnan(x)), df[!, :AGE_YRS]),
    xlabel="AGE",labels="Frequency")