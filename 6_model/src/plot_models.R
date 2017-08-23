
plot_models <- function(model.dir, save.pdf.as) {
  
  master.list <- dir(model.dir, pattern='*_lm.rds')
  
  graphics.off()
  pdf(file = save.pdf.as)
  
  for(i in master.list){
    lm.out <- readRDS(file = file.path(model.dir, i))
    
    par(mfrow=c(2,2), oma = c(1,1,1,1))
    for(j in 1:4){
      plot(lm.out, which=j)
      title(i)
    }
  }
  
  dev.off()
}
