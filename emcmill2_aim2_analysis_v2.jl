# LOAD IN PACKAGES AND DATA

using DataFrames, CSV, Plots, StatsPlots, StatsBase, Missings

df = DataFrame(CSV.read("Desktop/19-21VAERSCOMB_clean.csv", DataFrame));

size(df)

vax_ct = countmap(df[!, :VAX_NAME])

#SERIOUS_EVENT =1 is serious and SERIOUS_EVENT=0 is non-serious adverse event

#find most frequent serious adverse event - pull from SYMPTOM1, SYMPTOM2, SYMPTOM3, SYMPTOM4, SYMPTOM5
#find most frequent non-serious adverse event - pull from SYMPTOM1, SYMPTOM2, SYMPTOM3, SYMPTOM4, SYMPTOM5

df_nonserious = df[df.SERIOUS_EVENT .== 0, :]

df_serious = df[df.SERIOUS_EVENT .== 1, :]



# Frequency table of serious events
freq_serious = sort(freqtable(df, :SERIOUS_EVENT), rev=true);
freq_serious

# Frequency table of vaccines
freq_vax = sort(freqtable(df, :VAX_NAME), rev=true);
freq_vax






#function for aims analysis, to calc PRR from contingency tables created below

function get_freqtable(df, vax_name_str, symptom_str)
    test = select(df, ["VAX_NAME", "SYMPTOMS"])
    # Create dummy variable for vax_name
    test.VAX_IND = (test.VAX_NAME .== vax_name_str)
    # Create dummy variable for symptom
    test.SYMPTOM_IND = zeros(size(test, 1))
    for rownumber in 1:size(test, 1)
        if symptom_str in test[rownumber,:SYMPTOMS]
            test[rownumber,:SYMPTOM_IND] = 1
        end
    end
    # Create frequency table
    tbl = freqtable(test, :VAX_IND, :SYMPTOM_IND)
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

# PRR for #1 freq VAX = "COVID19 (COVID19 (PFIZER-BIONTECH))" and serious report
df.COVID19_PFIZER = (df.VAX_NAME .== "COVID19 (COVID19 (PFIZER-BIONTECH))");
tbl = freqtable(df, :COVID19_PFIZER, :SERIOUS_EVENT)

#PRR for Pfizer COVID-19
get_PRR(tbl)

#PRR for #2 freq VAX = "Zoster" and serious report
df.ZOSTER = (df.VAX_NAME .== "ZOSTER (SHINGRIX)");
tbl = freqtable(df, :ZOSTER, :SERIOUS_EVENT)

#PRR for Zoster
get_PRR(tbl)

#PRR for #3 freq VAX = "Moderna" and serious report
df.COVID19_MODERNA = (df.VAX_NAME .== "COVID19 (COVID19 (MODERNA))");
tbl = freqtable(df, :COVID19_MODERNA, :SERIOUS_EVENT)

#PRR for Moderna COVID-19
get_PRR(tbl)

#PRR for #4 freq VAX = "Pneumo" and serious report
df.PNEUMO = (df.VAX_NAME .== "PNEUMO (PNEUMOVAX)");
tbl = freqtable(df, :PNEUMO, :SERIOUS_EVENT)

#PRR for Pneumo
get_PRR(tbl)

#PRR for #5 freq VAX = "JANSSEN COVID-19" and serious report
df.COVID19_JANSSEN = (df.VAX_NAME .=="COVID19 (COVID19 (JANSSEN))");
tbl = freqtable(df, :COVID19_JANSSEN, :SERIOUS_EVENT)

#PRR for Janssen COVID-19
get_PRR(tbl)
