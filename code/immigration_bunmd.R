## An example comparing foreign born and native longevity
## Using BUNMD

## 1) read in "complete" sample
## 2) create analysis variables
## 3) example 1: 1 cohort only
## 4) example 2: a bunch of cohorts
## 5) example 3: cubans by race
## 6) note on regression coefficients


## 1) read in "complete" sample
## Note: we already created a small file with !is.na(cweight)
library(data.table)
library(memisc)
source("coef_plot_fun.R")

path <- "~/Documents/data/matched_data/"
dt <- fread(paste0(path, "small_berkeley_unified_mortality_file_v0.csv"))
nrow(dt)
## [1] 18982919 (seems big!)

## 2) create analysis variables

## code countries with a lot of immigrants
dt[, country := NULL]
dt[bpl ==  15000, country := "Canada"]
dt[bpl ==  20000, country := "Mexico"]
dt[bpl ==  25000, country := "Cuba"]
dt[bpl ==  26030, country := "Jamaica"]
dt[bpl ==  41000, country := "England"]
dt[bpl ==  41400, country := "Ireland"]
dt[bpl ==  43300, country := "Greece"]
dt[bpl ==  43400, country := "Italy"]
dt[bpl ==  43600, country := "Portugal"]
dt[bpl ==  45010, country := "Austria"]
dt[bpl ==  45200, country := "Czechoslovakia"]
dt[bpl ==  45310, country := "Germany"]
dt[bpl ==  45500, country := "Poland"]
dt[bpl ==  45700, country := "Yugoslavia"]
dt[bpl ==  46500, country := "Russia"]
dt[bpl ==  50000, country := "China"]
## dt[bpl ==  50220, country := "Korea"]
## dt[bpl ==  50100, country := "Japan"]
dt[bpl ==  51500, country := "Philippines"]
## dt[bpl ==  54100, country := "Syria"]
dt[bpl < 1300,    country := "USA"]

## prepare variables for regression
dt[, Byear := as.factor(byear)]
dt[, Byear := relevel(Byear, ref = "1910")]

dt[race == 1, Race := "White"]
dt[race == 2, Race := "Black"]
dt[race == 3, Race := "Other"]
dt[race == 4, Race := "Asian"]
dt[race == 5, Race := "Hispanic"]
dt[race == 6, Race := "Native"]
dt[, Race := relevel(as.factor(Race), ref = "White")] ## capital "W"?


dt[, country := relevel(factor(country), ref = "USA")]


## 3) example 1: 1 cohort only

#####################################
## example 1: Cohort born in 1915  ##
#####################################

tab <- table(dt[byear == 1915]$death_age)

head(tab)
##    72    73    74    75    76    77
## 20259 42086 44279 45199 47473 50175
tail(tab)
##    85    86    87    88    89    90
## 62710 62744 60327 59182 54581 23996

## Notice: the end-ages have only half the deaths, because of Lexis
## triangles.

my.dt.1 <- dt[byear == 1915 &
            death_age %in% 73:89 & ## we omit first and last ages
            age_first_application < 65] ## we restrict to those in the US before age 65
##
## male
m.immig.male <- lm(death_age ~ country,
                   data = my.dt.1,
                   weight = cweight,
                   subset = sex  == 1)
## female
m.immig.female <- update(m.immig.male,
                         subset = sex == 2)
##
## figure
##  pdf("birth_place_fig1.pdf", width = 6, height = 6)

par(mfrow = c(2,1),
    mar = c(5, 4, 4, 2) +.1)
color_coef_plot.fun(m.immig.female, "country", labeled_color.vec,
                    xlim = c(-1, 2))
text(0, 16.5, "Natives", pos = 2, col = "darkgrey", cex = .6)
title("Foreign-born female ages of death, cohort 1915")
color_coef_plot.fun(m.immig.male, "country", labeled_color.vec,
                    xlim = c(-1, 2))
title("Foreign-born male ages of death, cohort 1915")
text(0, 16.5, "Natives", pos = 2, col = "darkgrey", cex = .6)
## dev.off()
## system("open birth_place_fig1.pdf")

## sample size table

tab.1 <- my.dt.1[, round(xtabs(cweight ~ country + sex))]
tab.2 <- my.dt.2[, round(xtabs(cweight ~ country + sex))]
format(cbind(tab.1, tab.2), big.mark = ",")

#########################################
## example 2: Cohorts born in 1910-19  ##
#########################################
my.dt.2 <- dt[byear %in% 1910:1919 &
            dyear %in% 1988:2005 &
            age_first_application < 65]
## male
m.immig.male.2 <- lm(death_age ~ country +  Byear,
                   data = my.dt.2,
                   weight = cweight,
                   subset = sex  == 1)
## female
m.immig.female.2 <- update(m.immig.male.2,
                         subset = sex == 2)

## figure
pdf("birth_place_fig2.pdf", width = 6, height = 6)
par(mfrow = c(2,1),
    mar = c(5, 4, 4, 2) +.1)
color_coef_plot.fun(m.immig.female.2, "country", labeled_color.vec,
                    xlim = c(-1, 2))
text(0, 16.5, "Natives", pos = 2, col = "darkgrey", cex = .6)
title("Foreign-born female ages of death, cohorts 1910-19")
color_coef_plot.fun(m.immig.male.2, "country", labeled_color.vec,
                    xlim = c(-1, 2))
title("Foreign-born male ages of death, cohorts 1910-19")
text(0, 16.5, "Natives", pos = 2, col = "darkgrey", cex = .6)
dev.off()
system("open birth_place_fig2.pdf")


## sample size table
tab.1 <- my.dt.1[, round(xtabs(cweight ~ country + sex))]
tab.2 <- my.dt.2[, round(xtabs(cweight ~ country + sex))]
format(cbind(tab.1, tab.2), big.mark = ",")


##########################################################
## example 3: Racial disparities among Cuban Immigrants ##
##########################################################



my.dt.3 <- dt[country %in% c("Cuba") &
              byear %in% 1900:1920 &
              dyear %in% 1988:2005 &
              age_first_application < 65]

m.cuba.m <-  lm(death_age ~ Race +  Byear,
                data = my.dt.3,
                subset = sex == 1,
                weight = cweight)
m.cuba.f <- update(m.cuba.m,
                   subset = sex == 2)
mtable(m.cuba.m, m.cuba.f)

## ====================================================
##                           m.cuba.m      m.cuba.f
## ----------------------------------------------------
##   (Intercept)              83.807***     86.115***
##                            (0.111)       (0.104)
##   Race: Black/White        -0.488        -0.825***
##                            (0.252)       (0.226)
##   Race: Other/White        -0.052        -0.297
##                            (0.239)       (0.219)
##   Race: Asian/White         0.757         3.142**
##                            (1.681)       (1.085)
##   Race: Hispanic/White      1.898***      2.285***
##                            (0.097)       (0.080)
##   Byear: 1900/1910          5.846***      6.649***
##                            (1.376)       (1.040)
##   Byear: 1901/1910          5.870***      4.586***
##                            (1.442)       (1.343)
##   Byear: 1902/1910          4.531***      4.355***
##                            (0.774)       (0.720)
##   Byear: 1903/1910          4.284***      4.595***
##                            (0.586)       (0.493)
##   Byear: 1904/1910          5.982***      3.601***
##                            (0.408)       (0.414)
##   Byear: 1905/1910          3.273***      3.446***
##                            (0.343)       (0.348)
##   Byear: 1906/1910          2.831***      2.349***
##                            (0.252)       (0.286)
##   Byear: 1907/1910          2.770***      1.769***
##                            (0.249)       (0.230)
##   Byear: 1908/1910          1.451***      1.281***
##                            (0.202)       (0.192)
##   Byear: 1909/1910          0.270         0.301
##                            (0.171)       (0.164)
##   Byear: 1911/1910         -0.145        -0.757***
##                            (0.150)       (0.141)
##   Byear: 1912/1910         -0.806***     -1.470***
##                            (0.164)       (0.144)
##   Byear: 1913/1910         -1.485***     -2.245***
##                            (0.165)       (0.146)
##   Byear: 1914/1910         -2.056***     -3.075***
##                            (0.170)       (0.153)
##   Byear: 1915/1910         -2.885***     -4.032***
##                            (0.176)       (0.163)
##   Byear: 1916/1910         -3.763***     -4.759***
##                            (0.177)       (0.165)
##   Byear: 1917/1910         -4.595***     -5.768***
##                            (0.176)       (0.167)
##   Byear: 1918/1910         -5.328***     -6.556***
##                            (0.170)       (0.165)
##   Byear: 1919/1910         -6.201***     -7.439***
##                            (0.170)       (0.171)
##   Byear: 1920/1910         -7.272***     -8.464***
##                            (0.168)       (0.169)
##   Race: Native/White                    -10.559
##                                          (5.760)
## ----------------------------------------------------
##   R-squared                 0.271         0.300
##   N                     20341         22565
## ====================================================
##   Significance: *** = p < 0.001; ** = p < 0.01;
##                 * = p < 0.05


## check to see what happens if we restrict only to 1-time appliers

m.cuba.f.tilde <- update(m.cuba.f,
                         subset = sex == 2 & number_apps == 1)
m.cuba.m.tilde <- update(m.cuba.f,
                         subset = sex == 1 & number_apps == 1)

mtable(m.cuba.f, m.cuba.f.tilde, m.cuba.m, m.cuba.m.tilde)

## check on "race_change"

m.cuba.m.star <- update(m.cuba.m, . ~ . + race_change)
m.cuba.f.star <- update(m.cuba.m.star,
                        subset = sex == 2)
mtable(m.cuba.m, m.cuba.f, m.cuba.m.star, m.cuba.f.star)

================================================================================
                          m.cuba.m      m.cuba.f    m.cuba.m.star  m.cuba.f.star
----------------------------------------------------------------------------------
  (Intercept)              83.807***     86.115***     83.807***      86.109***
                           (0.111)       (0.104)       (0.111)        (0.104)
  Race: Black/White        -0.488        -0.825***     -0.484         -0.871***
                           (0.252)       (0.226)       (0.252)        (0.226)
  Race: Other/White        -0.052        -0.297        -0.042         -0.450*
                           (0.239)       (0.219)       (0.244)        (0.224)
  Race: Asian/White         0.757         3.142**       0.816          2.486*
                           (1.681)       (1.085)       (1.703)        (1.103)
  Race: Hispanic/White      1.898***      2.285***      1.954***       1.652***
                           (0.097)       (0.080)       (0.280)        (0.212)

Doesn't see to change the results to much.

## Let's check on first names

## get top 20 names by race

get.top20 <- function(dt)
{
    foo <- dt[ , .N, by = fname]
    bar <- foo[order(-N)][1:20]
    bar
}

get.top20(my.dt.3[Race == "White"])
get.top20(my.dt.3[Race == "Hispanic"])
get.top20(my.dt.3[Race == "Black"])

foo <- my.dt.3[ , .N, by = .(fname, Race)]
foo[order(-N)][1:30]

## we can do indirectly to see if there's eni variance and if that predicts name

tt <- my.dt.3[, table(fname, Race)]
ptt <- round(prop.table(tt, 2), 6)

tth <- my.dt.3[Race %in% c("White", "Hispanic") & sex == 1, table(fname, Race == "Hispanic")]
ptth <- prop.table(tth, 2)
eni_hisp.vec <- ptth[,"TRUE"]/(ptth[, "TRUE"] + ptth[, "FALSE"])
N.vec <- apply(tth, 1, sum)
## pyramid
s <- N.vec > 20
par(mfrow = c(1,1))
plot(eni_hisp.vec[s], N.vec[s], log = "y", type = "n")
text(eni_hisp.vec[s], N.vec[s], names(eni_hisp.vec)[s], cex = .5)

tth <- my.dt.3[Race %in% c("White", "Hispanic") & sex == 2, table(fname, Race == "Hispanic")]
ptth <- prop.table(tth, 2)
eni_hisp.vec <- ptth[,"TRUE"]/(ptth[, "TRUE"] + ptth[, "FALSE"])
N.vec <- apply(tth, 1, sum)
## pyramid
s <- N.vec > 20
par(mfrow = c(1,1))
plot(eni_hisp.vec[s], N.vec[s], log = "y", type = "n")
text(eni_hisp.vec[s], N.vec[s], names(eni_hisp.vec)[s], cex = .5)


eni.dt <- data.table(fname = names(eni_hisp.vec), "eni_hisp" = eni_hisp.vec, "N" = N.vec)

out <- merge(my.dt.3,  eni.dt, by = "fname")

## model
m.cuba.eni <- lm(death_age ~ eni_hisp + Byear + as.factor(sex),
                 data = out,
                 subset = N >= 25 & sex == 2)
mtable(m.cuba.eni)


m.cuba.eni.f <- lm(death_age ~ eni_hisp + Byear,
                 data = out,
                 subset = N >= 25 & sex == 2)
m.cuba.eni.m <- update(m.cuba.eni.f,
                       subset = N >= 25 & sex == 1)
mtable(m.cuba.eni, m.cuba.eni.m, m.cuba.eni.f)


## check names

my.dt.3[Race == "Asian", .( fname, lname, mother_fname,  mother_lname, father_lname)]

########## all done