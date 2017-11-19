load.datapackage=function(datapackage){
  
  #### from github  ####
  if (is.git(datapackage)){
    
    path=getwd()
    git2r::clone(datapackage, path) 
    
  }


  #### from local file  ####
  
  path.expand(paste0(path,file,".zip"))

  
  
  #### from zip url #### 
  
  temp <- tempfile()
  download.file("www.path.url",temp)
  con <- unz(temp, "datapackage.dat")
  datapackage <- jsonlite::fromJSON()
  unlink(temp)
  
  #### from zip local #### 
  unzip(file)
}

# https://github.com/datasets/gdp


is.zip=function(x){
  
}