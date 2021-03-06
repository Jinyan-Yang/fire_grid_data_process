# use agcd met as well?
# http://climate-cms.wikis.unsw.edu.au/AGCD

# get need packages and functions
library(raster)
source('r/functions_awap.R')

# read dates
har.score.df.gps <- read.csv('cache/hazard.score.gps.csv')
# nrow(har.score.df.gps[is.na(har.score.df.gps$Date) & is.na(har.score.df.gps$Year),])
har.score.df.gps$Date <- gsub(pattern = '2111',replacement = '2011',har.score.df.gps$Date)
har.score.df.gps$Date.formated <- as.Date(har.score.df.gps$Date)

# date.vec <- unique(har.score.df.gps$Date.formated)
# date.vec <- date.vec[order(date.vec)]

# mon.date <- format(as.Date(date.vec),format='%Y-%m')
mon.1st.vec <- as.Date(paste0(har.score.df.gps$Year,'-',har.score.df.gps$month,'-1'))
mon.pastmon.vec <- mon.1st.vec - 1

mon.pastmon.vec <- mon.pastmon.vec[!duplicated(mon.pastmon.vec)]
mon.pastmon.vec <- mon.pastmon.vec[!is.na(mon.pastmon.vec)]

mon.pastmon.1st.vec <- as.Date(paste0(format(mon.pastmon.vec,format='%Y-%m'),'-1'))
# data downloading

for (i in seq_along(mon.pastmon.1st.vec)) {
  get_awap_data(start = mon.pastmon.1st.vec[i],
                end = mon.pastmon.vec[i],
                measure_i = 'maxave',
                fold.work = 'data/met/dailyTmax')
}
library(devtools)
install_github("https://github.com/swish-climate-impact-assessment/awaptools")

# library(awaptools)
# get_awap_data(start = '2016-03-05',end = '2016-03-06', 'maxave')
# tmp.url <- 'http://www.bom.gov.au/web03/ncc/www/awap/rainfall/totals/daily/grid/0.05/history/nat/2012033120120331.grid.Z'
# download.file(tmp.url,destfile = 'test.z')

get_awap_data('2010-1-1','2020-12-31','maxave','data/met/tmax/')

get_awap_data('2010-1-1','2020-12-31','minave','downloads/dailyTmin')

get_awap_data('2010-1-1','2020-12-31','totals','downloads/precipitation')

get_awap_data('2010-1-1','2020-12-31','vprph09','downloads/dailyVP09')

get_awap_data('2010-1-1','2020-12-31','vprph15','downloads/dailyVP15')

get_awap_data('2010-1-1','2020-12-31','solarave','downloads/dailyPAR')



# read in modis sites coords
modis.df.tussock <- read.csv('cache/chosen sites.csv')
# modis.df.tussock <- modis.df.tussock[seq(1,20,by=2),]
names(modis.df.tussock) <- c('veg_type','x','y','map','map.level')
modis.df.tussock <- modis.df.tussock[,c('x','y','veg_type','map','map.level')]
modis.df.tussock$type <- 'tussock'

modis.df.pasture <- read.csv('cache/chosen pasture sites.csv')
modis.df.pasture <- modis.df.pasture[,c('x','y','DLCD_v2.1_MODIS_EVI_13_20140101.20151231','map','map.level')]
names(modis.df.pasture) <- c('x','y','veg_type','map','map.level')
modis.df.pasture$type <- 'pasture'

modis.site.info.df <- rbind(modis.df.tussock,modis.df.pasture)
modis.site.info.df <- modis.site.info.df[modis.site.info.df$map<1000,]
modis.site.info.df <- modis.site.info.df[modis.site.info.df$map<900 & modis.site.info.df$veg_type=='19' | modis.site.info.df$veg_type=='9',]

# get awap for coord
get.awap.coord.func <- function(cood.df,met.nm,measure_i,sdate){
  #######################################################
  # inputs:
  # cood.df is the data frame with lat and lon
  # met.nm is the foler name of the met variable;
  # measure_i is the met varible names in the grided data
  # sdate is the date of the met needed
  
  # output:
  # a data frame of the met with coordinates
  ########################################################
  
  fname <- sprintf("downloads/%s/%s_%s%s.grid",met.nm,measure_i,gsub("-","",sdate),gsub("-","",sdate))
  print(fname)
  # data reading
  tmp <- raster(fname)
  sp <- SpatialPoints(cood.df)
  cood.df$met.var <- extract(tmp, sp, method='bilinear')
  cood.df$Date <- sdate
  return(cood.df)
}

# loop through all dates
read.site.met.func <- function(met.nm,measure_i,modis.site.info.df){
  #######################################################
  # inputs:
  # met.nm is the foler name of the met variable;
  # measure_i is the met varible names in the grided data
  
  # output:
  # a data frame of the met with coordinates
  
  # note 
  # date.vec is fixed but should be an input in the future
  ########################################################
  out.nm <- sprintf('cache/met.modis.%s.rds',met.nm)
  
  if(!file.exists(out.nm)){
    
    date.vec <- seq(as.Date('2011-1-1'),
                    as.Date('2020-12-31'),
                    by='day')
    
    tmp.ls <- list()
    for (i in seq_along(date.vec)) {
      tmp.ls[[i]] <- get.awap.coord.func(modis.site.info.df[,c('x','y')],
                                         met.nm,measure_i,
                                         date.vec[i])
      
    }
    tmp.rain.df <- do.call(rbind,tmp.ls)
    saveRDS(tmp.rain.df,out.nm)
  }else{
    tmp.rain.df <- readRDS(out.nm)
  }
  
  return(tmp.rain.df)
}

# 
tmp.rain.df <- read.site.met.func('precipitation','totals',modis.site.info.df)
modis.site.met.df <- merge(modis.site.info.df,tmp.rain.df,by=c('x','y'),all.y=T)
names(modis.site.met.df)[names(modis.site.met.df)=='met.var'] <- 'Rain'

tmp.par.df <- read.site.met.func('dailyPAR','solarave',modis.site.info.df)
tmp.tmax.df <- read.site.met.func('dailyTmax','maxave',modis.site.info.df)
tmp.tmin.df <- read.site.met.func('dailyTmin','minave',modis.site.info.df)

tmp.vp09.df <- read.site.met.func('dailyVP09','vprph09',modis.site.info.df)
tmp.vp15.df <- read.site.met.func('dailyVP15','vprph15',modis.site.info.df)

modis.site.met.df$rad <- tmp.par.df$met.var
modis.site.met.df$tmax <- tmp.tmax.df$met.var
modis.site.met.df$tmin <- tmp.tmin.df$met.var
modis.site.met.df$vp9 <- tmp.vp09.df$met.var
modis.site.met.df$vp15 <- tmp.vp15.df$met.var


vp.sat <- 6.11*exp(17.27*modis.site.met.df$tmin / (237.3+modis.site.met.df$tmin))
modis.site.met.df$RHmax <- 100 * modis.site.met.df$vp9 / vp.sat
modis.site.met.df$RHmax[modis.site.met.df$RHmax>100] <-100

vp.sat.l <- 6.11*exp(17.27*modis.site.met.df$tmax / (237.3+modis.site.met.df$tmax))
modis.site.met.df$RHmin <- 100*modis.site.met.df$vp15 / vp.sat.l
modis.site.met.df$RHmin[modis.site.met.df$RHmin>100] <-100

saveRDS(modis.site.met.df,'cache/modis.met.rds')


