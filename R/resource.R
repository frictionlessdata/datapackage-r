#' Resource class
#'
#' @docType class
#' @importFrom R6 R6Class
#' @export
#' @include helpers.R
#' @return Object of \code{\link{R6Class}} .
#' @format \code{\link{R6Class}} object.

# Module API

Resource <- R6Class(
  
  "Resource",
  
  # Public
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  initialize= function(){
    # Set attributes
    private$currentDescriptor = descriptor
    private$nextDescriptor = descriptor
    private$dataPackage = dataPackage
    private$basePath = basePath
    private$relations = NULL
    private$strict = strict
    private$errors = list()
    
    # Build instance
    private$build_()
  }
  
  load = function (descriptor={}, basePath, strict=FALSE) {

    # static async  
    
    # Get base path
    if (isUndefined(basePath)) {
      
      basePath = locateDescriptor(descriptor)
      
    }
    
    # Process descriptor
    descriptor = retrieveDescriptor(descriptor)
    descriptor = dereferenceResourceDescriptor(descriptor, basePath)
    
    return (Resource$new(descriptor, basePath, strict))
    
  },
  
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
    valid = function() {
     return (length(private$errors) == 0)
    },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  errors = function() {
    return (private$errors)
    },
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  profile = function() {
    return (private$profile)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  descriptor = function() {
    # Never use this.descriptor inside this class (!!!)
    return (private$nextDescriptor)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  name = function() {
      return (private$currentDescriptor[["name"]])
  },
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  inline = function() {
    return (!!private$sourceInspection$inline)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  local = function() {
    return (!!private$sourceInspection$local)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  remote = function() {
    return (!!private$sourceInspection$remote)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  multipart = function() {
    return (!!private$sourceInspection$multipart)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  tabular = function() {
    
    if (private$currentDescriptor[["profile"]] == 'tabular-data-resource') return (TRUE)
    
    if (is.null(private$strict)) {
      if (config.TABULAR_FORMATS.includes(private$currentDescriptor$format)) return (TRUE)
      if (private$sourceInspection$tabular) return (TRUE)
    }
    return (FALSE)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  source = function() {
    return (private$sourceInspection$source)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  headers = function() {
    if (is.null(private$tabular)) return (NULL)
    return (private$getTable()$headers)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  schema = function() {
    if (is.null(private$tabular)) return (NULL)
      return (private$getTable()$schema)
  },
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  iter = function(relations = FALSE, ... , options={}) {
  #async
    # Error for non tabular
    if (!isTRUE(private$tabular)) {
      DataPackageError$new('Methods iter/read are not supported for non tabular data')
    }
    # Get relations
    if (relations) {
      relations = private$getRelations()
    }
    return (iter(relations, options, private$getTable() ))
  },
  # https://github.com/frictionlessdata/datapackage-js#resource
  
    read(relations = FALSE, ... , options={}) {
      # Error for non tabular
      if (!this.tabular) {
        DataPackageError$new('Methods iter/read are not supported for non tabular data')
      }
      # Get relations
      if (relations) {
        relations = private$getRelations()
      }
      return (read(relations, ... , options, private$getTable() ))
    },
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  checkRelations = function() {
    # async
    private$read(relations = TRUE)
    return (TRUE)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  rawIter= function( stream = FALSE ) {
    # async
    
    # Error for inline
    if (this.inline) {
      DataPackageError$new('Methods iter/read are not supported for inline data')
    }
    byteStream = createByteStream(private$source, private$remote)
    return (stream) ? byteStream : new S2A(byteStream)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  rawRead = function() {
    
    return ( 
      
      Promise$new(resolve => {
        let bytes
        private$rawIter({stream = TRUE}).then(stream => {
          stream.on('data', data => {bytes = (bytes) ? Buffer.concat([bytes, data]) : data})
          stream.on('end', () => resolve(bytes))
        })
      })
      )
    
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  infer = function() {
    # async
    
    descriptor = private$currentDescriptor
    
    # Blank -> Stop
    
    if (private$sourceInspection.blank) {
        return (descriptor)
    }
    # Name
    
    if (!descriptor.name) {
      descriptor$name = private$sourceInspection$name
    }
    # Only for non inline
    if (!private$inline) {
      
      # Format
      if (is.null(descriptor$format)) {
        descriptor$format = private$sourceInspection$format
      }
      # Mediatype
      if (!descriptor.mediatype) {
        descriptor.mediatype = `text/${descriptor.format}`
      }
      # Encoding
      if (descriptor.encoding == config.DEFAULT_RESOURCE_ENCODING) {
        if (!config.IS_BROWSER) {
          jschardet = require('jschardet')
          iterator = await this.rawIter()
          bytes = (await iterator.next()).value
          encoding = jschardet.detect(bytes).encoding.toLowerCase()
          descriptor.encoding = (encoding === 'ascii') ? 'utf-8' : encoding
        }
      }
    }
    # Schema
    if (is.null(descriptor[["schema"]]) | isUndefined( descriptor[["schema"]] ) ) {
      if (private$tabular) {
        descriptor[["schema"]] = infer( private$getTable() )
      }
    }
    # Profile
    if (descriptor[["profile"]] == config.DEFAULT_RESOURCE_PROFILE) {
      if (private$tabular) {
        descriptor[["profile"]] = 'tabular-data-resource'
      }
    }
    # Save descriptor
    private$currentDescriptor = descriptor
    private$build()
    return (descriptor)
  },
  
  # https://github.com/frictionlessdata/datapackage-js#resource
  
  commit = function(strict = {} ) {
    if (tableschema.r::is.binary(strict)) private$strict = strict
    else if (isEqual(private$currentDescriptor, private$nextDescriptor)) return (FALSE)
    
    private$currentDescriptor = private$nextDescriptor
    private$table = NULL
    private$build()
    
    return (TRUE)
  }
  # https://github.com/frictionlessdata/datapackage-js#resource
  save = function (target) {
    
      return (
        new Promise(
          (resolve, reject) => {
            contents = JSON.stringify(private$currentDescriptor, NULL, 4)
            fs.writeFile(target, contents, error => (!error) ? resolve() : reject(error))
          })
        )
  },
  
  private = list(
    
    # Private
    
    constructor(descriptor={}, {basePath, strict=false, dataPackage}={}) {
      
      # Handle deprecated resource.path.url
      if (descriptor[["url"]]) {
        
        warning( 
          stringr::str_interp(
          'Resource property "url: <url>" is deprecated.
          Please use "path: <url>" instead.'))
        
        descriptor[["path"]] = descriptor[["url"]]
        
        rm(descriptor[["url"]])
      }
      
      # Set attributes
      private$currentDescriptor = cloneDeep(descriptor)
      private$nextDescriptor = cloneDeep(descriptor)
      private$dataPackage = dataPackage
      private$basePath = basePath
      private$relations = NULL
      private$strict = strict
      private$errors = []
      
      # Build resource
      
      private$build()
    },
    
    build = function() {
      # Process descriptor
      private$currentDescriptor = expandResourceDescriptor(private$currentDescriptor)
      private$nextDescriptor = private$currentDescriptor
      # Inspect source
      private$sourceInspection = inspectSource(
        private$currentDescriptor.data, private$currentDescriptor.path, private$basePath)
      # Instantiate profile
      private$profile = Profile$new(private$currentDescriptor[["profile"]])
      # Validate descriptor
      private$errors = list()
      
      const {valid, errors} = private$profile.validate(private$currentDescriptor)
      if (!valid) {
        private$errors = errors
        if (private$strict) {
          message = stringr::str_interp('There are ${length(errors)} validation errors (see errors[["error"]] )')
          DataPackageError$new(message, errors)
        }
      }
    },
    
    getTable = function () {
      if (!private$table) {
        # Resource -> Regular
        if (!private$tabular) {
          return (NULL)
        }
        # Resource -> Multipart
        if (private$multipart) {
          DataPackageError$new('Resource.table does not support multipart resources')
        }
        # Resource -> Tabular
        options = {}
        schemaDescriptor = private$currentDescriptor[["schema"]]
        schema = schemaDescriptor ? new Schema(schemaDescriptor) : NULL
        private$table = Table$new(private$source, {schema, ...options})
      }
      return (private$table)
    },
    
    getRelations = function() {
      # async
      
      if (is.null(private$relations) | isUndefined(private$relations) ) {
        # Prepare resources
        resources = list()
        
        if ( private$getTable() && private$getTable()[["schema"]] ) {
          
          for (fk in private$getTable()[["schema"]][["foreignKeys"]] ) {
            
            resources[ resource[["reference"]][[fk]] ] = resources[ resource[["reference"]][[fk]] ] || list()
            
            for (field in fields[["reference"]][[fk]] ) {
              
              push(field, resources[ resource[["reference"]][[fk]] ] )
            }
          }
        }
        # Fill relations
        private$relations = {}
        for (const [resource] of Object.entries(resources)) {
          if (resource && !private$dataPackage) continue
          private$relations[resource] = private$relations[resource] || []
          const data = resource ? private$dataPackage.getResource(resource) : this
          if (data.tabular) {
            private$relations[resource] = await data.read({keyed: TRUE})
          }
        }
      }
      return (private$relations)
    },
    # Deprecated
    table = function() {
      return (private$getTable())
    }
    
    )
)





# Internal

inspectSource = function (data, path, basePath) {
  inspection = {}
  
  # Normalize path
  
  if (path && !isArray(path)) {
    path = [path]
  }
  # Blank
  if (!data && !path) {
    inspection.source = NULL
    inspection.blank = TRUE
    
    # Inline
  } else if (data) {
    
    inspection.source = data
    inspection.inline = TRUE
    inspection.tabular = isArray(data) && data.every(isObject)
    
    # Local/Remote
  } else if (path.length === 1) {
    
    # Remote
    if (helpers.isRemotePath(path[0])) {
      inspection.source = path[0]
      inspection.remote = TRUE
    } else if (basePath && helpers.isRemotePath(basePath)) {
      inspection.source = urljoin(basePath, path[0])
      inspection.remote = TRUE
      
      # Local
    } else {
      # Path is not safe
      if (!helpers.isSafePath(path[0])) {
        DataPackageError$new(stringr::str_interp('Local path "${path[0]}" is not safe'))
      }
      
      # Not base path
      
      if (!basePath) {
        DataPackageError$new(`Local path "${path[0]}" requires base path`)
      }
      
      inspection.source = [basePath, path[0]].join('/')
      inspection.local = TRUE
    }
    
    # Inspect
    
    inspection.format = pathModule.extname(path[0]).slice(1)
    inspection.name = pathModule.basename(path[0], `.${inspection.format}`)
    inspection.tabular = config.TABULAR_FORMATS.includes(inspection.format)
    
    # Multipart Local/Remote
  } else if (path.length > 1) {
    const inspections = path.map(item => inspectSource(NULL, item, basePath))
    assign(inspection, inspections[0])
    inspection.source = inspections.map(item => item.source)
    inspection.multipart = TRUE
  }
  return (inspection)
}



createByteStream = function (source, remote) {
  # async
  
  let stream
  
  # Remote source
  if (remote) {
    if (config.IS_BROWSER) {
      const response = await axios.get(source)
      stream = new Readable()
      stream.push(response.data)
      stream.push(NULL)
    } else {
      const response = await axios.get(source, {responseType: 'stream'})
      stream = response.data
    }
    
    # Local source
  } else {
    if (config.IS_BROWSER) {
      throw new DataPackageError('Local paths are not supported in the browser')
    } else {
      stream = fs.createReadStream(source)
    }
  }
  return (stream)
}