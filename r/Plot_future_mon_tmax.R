#####
read.climate.func <- function(var.in.nm,future_s,exclude.nm = 'noVeg'){
  rcp45_mid.fn <- list.files(path = 'data/met/future/',
                             pattern = var.in.nm,recursive = T,full.names = T)
  
  rcp45_mid.fn <- rcp45_mid.fn[!rcp45_mid.fn %in% grep(exclude.nm, rcp45_mid.fn)]
  rcp45_mid.fn <- rcp45_mid.fn[grep(future_s, rcp45_mid.fn)]
  
  rcp45.mid.h.c <- sapply(rcp45_mid.fn, function(fn.in){
    
    x <- readRDS(fn.in)
    return(x[[1]])
  })
  
  print(rcp45_mid.fn)
  raster.new = stack(rcp45.mid.h.c)
  return(raster.new)
}
'data/met/future/ACCESS1-0/history/history_20002015_monthly_tmax.rds'
# ####
pr.hist <- read.climate.func(var.in.nm = 'monthly_tmax.rds',
                             future_s =  'history',
                             exclude.nm = '')
mean.ra.hist <- calc(pr.hist, fun = mean)


# 
pr.rcp45.mid <- read.climate.func(var.in.nm = 'monthly_tmax.rds',
                                  future_s =  'rcp45_mid',
                                  exclude.nm = '')
mean.ra.45.mid <- calc(pr.rcp45.mid, fun = mean)
# plot(mean.ra.2 - mean.ra.hist)
# 
pr.rcp45.long <- read.climate.func(var.in.nm = 'monthly_tmax.rds',
                                   future_s =  'rcp45_long',
                                   exclude.nm = '')
mean.ra.45.long<- calc(pr.rcp45.long, fun = mean)
# plot(mean.ra.long - mean.ra.hist)
# 
pr.rcp85.mid <- read.climate.func(var.in.nm = 'monthly_tmax.rds',
                                  future_s =  'rcp85_mid',
                                  exclude.nm = '')
mean.ra.85.mid <- calc(pr.rcp45.mid, fun = mean)
# 
pr.rcp85.long <- read.climate.func(var.in.nm = 'monthly_tmax.rds',
                                   future_s =  'rcp85_long',
                                   exclude.nm = '')
mean.ra.85.long<- calc(pr.rcp85.long, fun = mean)
# plot((mean.ra.85.long - mean.ra.hist))
# 
############
pdf('figures/future_mon_tmax.pdf',width = 8,height = 7)

# 
mean.ra.hist <- mask(mean.ra.hist, shape.vic)
break.vec <- seq(10,35,by=5)
library(raster)
plot(mean.ra.hist-275.25,main = ' Current',breaks = break.vec,col=(topo.colors(length(break.vec)-1)))

# 
mean.ra.45.mid <- mask(mean.ra.45.mid, shape.vic)
break.vec <- seq(0,2,by=0.5)
library(raster)
plot((mean.ra.45.mid-mean.ra.hist),main = ' RCP4.5 (2045-2060) - Current',
     breaks = break.vec,col=(topo.colors(length(break.vec)-1)))
# library(oz)
# vic(add=T,col='grey',lwd=3)
# 
# break.vec <- seq(20,160,by=20)
mean.ra.45.long <- mask(mean.ra.45.long, shape.vic)
library(raster)
plot((mean.ra.45.long-mean.ra.hist),main = ' RCP4.5 (2085-2100) - Current',
     breaks = break.vec,col=(topo.colors(length(break.vec)-1)))
# library(oz)
# vic(add=T,col='grey',lwd=3)
# 
# break.vec <- seq(20,160,by=20)
mean.ra.85.mid <- mask(mean.ra.85.mid, shape.vic)
library(raster)
plot((mean.ra.85.mid-mean.ra.hist),main = ' RCP8.5 (2045-2060) - Current',
     breaks = break.vec,col=(topo.colors(length(break.vec)-1)))
# library(oz)
# vic(add=T,col='grey',lwd=3)
# 
break.vec <- seq(2,4,by=0.5)
mean.ra.85.long <- mask(mean.ra.85.long, shape.vic)
library(raster)
plot((mean.ra.85.long-mean.ra.hist),main = ' ',
     breaks = break.vec,col=(topo.colors(length(break.vec)-1)))
# library(oz)
# vic(add=T,col='grey',lwd=3)
dev.off()
# plot only the end of century#######
png('figures/future_tmax.png',width = 800,height = 300)
par(mfrow=c(1,2),mar=c(3,3,1,5))

# a
mean.ra.hist <- mask(mean.ra.hist, shape.vic)
break.vec <- seq(10,35,by=5)

plot(mean.ra.hist-275.25,
     breaks = break.vec,
     col=(topo.colors(length(break.vec)-1)),
     box=FALSE,bty='n',
     xaxt='n')

legend('topleft',legend = '(a) Temperature-current',bty='n')
# b
break.vec <- seq(2,4,by=0.5)
mean.ra.85.long <- mask(mean.ra.85.long, shape.vic)

plot((mean.ra.85.long-mean.ra.hist),main = '',
     breaks = break.vec,
     col=(heat.colors(length(break.vec)-1)),
     box=FALSE,bty='n',
     xaxt='n')

legend('topleft',legend = '(b) Temperature-2100 RCP8.5',bty='n')
dev.off()
