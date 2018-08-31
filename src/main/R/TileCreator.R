
library(R6)
library(dplyr)
library(data.table)


TileCreator <- R6Class("TileCreator",
                                 
  private = list(
    sc = NULL,
    tileSize = 256, 
    debug = NULL,
    
    
    ## see geosphere::mercator
    calcTile = function(zoom, lat, lon) {
      latRad <- pi/180 * lat
      n <- 2^zoom
      xTile <- n * ((lon + 180) / 360)
      yTile <- n * (1 - (log(tan(latRad) + 1 / cos(latRad)) / pi)) / 2
      return(data.table(x=xTile, y=yTile))
    },
    
    
    calcPosition = function(dat, xx, yy) {
      dat[, x := x - xx]
      dat[, y := y - yy]
      dat[, y := 1.0 - y]
      
      dat[, u := x * private$tileSize]
      dat[, v := y * private$tileSize]
      
      dat[, x := floor(u)]
      dat[, y := floor(v)]
      
      dat[, u := NULL]
      dat[, v := NULL]
    }
  ),
                       
  
  public = list(
    initialize = function(host, port, keyspace, table, debug=FALSE) {
      require(sparklyr)
      private$debug <- debug
      
      # fill config
      config <- spark_config()
      config[["sparklyr.defaultPackages"]] <- c("datastax:spark-cassandra-connector:2.3.0-s_2.11")
      config[["spark.cassandra.connection.host"]] <- host
      config[["spark.cassandra.connection.port"]] <- as.integer(port)
      cat("config created!\n")
      
      # create spark connection
      private$sc <- spark_connect(master = "local[*]",
                                  version = "2.3.0",
                                  hadoop_version = 2.7, 
                                  config = config)
      cat("spark connection created!\n")
      
      cass_tbl <- private$sc %>% spark_read_source(
        name = table,
        source = "org.apache.spark.sql.cassandra", 
        options = list(keyspace = keyspace,
                       table    = table))
      cat("table init complete!\n")
    },
    
    
    getData = function(zoom, x, y) {
      require(DBI)
      
      dbGetQuery(private$sc, paste0("select x, y, lat, lng as lon from points where zoom = ", zoom, " and x = ", x, " and y = ", y)) %>% 
        as.data.table()
    },
    
    
    render = function(zoom, x_from, x_to, y_from, y_to) {
      zoom <- as.integer(zoom)
      x_from <- as.integer(x_from) 
      x_to <- as.integer(x_to)
      y_from <- as.integer(y_from) 
      y_to <- as.integer(y_to)
      
      for (x in x_from:x_to) {
        for (y in y_from:y_to) {
          self$renderTile(zoom, x, y)
        }
      }
    }, 
    
    
    renderTile = function(zoom, x, y) {
      require(ggplot2)
      
      filename <- paste0(zoom, "_", x, "_", y, ".png")
      fileNameWithPath <- paste0("tile/", filename)
      
      if (file.exists(fileNameWithPath)) {
        if (private$debug) {
          cat(paste0("chached zoom=", zoom, ", x=", x, ", y=", y, "\n")) 
        }
        return(NULL)
      }
      
      dat <- self$getData(zoom, x, y)
      if (nrow(dat) == 0) {
        return(NULL)
      }
      
      datTile <- private$calcTile(zoom, dat$lat, dat$lon)
      private$calcPosition(datTile, x, y)
      
      
      p <- ggplot(datTile) + 
        geom_point(aes(x=x, y=y), colour = "blue", alpha=0.4, size=1.5) +
        ylim(1, private$tileSize) + 
        xlim(1, private$tileSize)
      
      p <- p +
        theme(panel.background=element_blank(), 
              panel.grid.major=element_blank(), 
              panel.grid.minor=element_blank(), 
              panel.spacing=unit(c(0, 0, 0, 0), "cm"),
              axis.ticks=element_blank(), 
              axis.text.x=element_blank(), 
              axis.text.y=element_blank(), 
              axis.title.x=element_blank(), 
              axis.title.y=element_blank(),
              plot.background = element_rect(fill = "transparent",colour = NA),
              plot.margin = unit(c(-15, -15, -15, -15), "pt"),  
              legend.position = 'none') +
        labs(x=NULL, y=NULL)
      
      png(fileNameWithPath, width=private$tileSize, height=private$tileSize, units="px", bg = "transparent")
      print(p)
      dev.off() 
      
      if (private$debug) {
        cat(paste0("rendered zoom=", zoom, ", x=", x, ", y=", y, ", points=", nrow(datTile), "\n")) 
      }
      return(nrow(datTile))
    }
  )
)


## create instance of TileCreator
tileCreator <- TileCreator$new(host = "192.168.99.100", port = "9042", keyspace = "density", table = "points")

