#' @include AllGenerics.R
NULL

#' @useDynLib flowWorkspace
NULL

#' @name flowWorkspace-package
#' @aliases 
#' flowWorkspace-package
#' flowWorkspace
#' @docType package
#' @importFrom Rcpp evalCpp
#' @title Import and replicate flowJo workspaces and gating schemes using flowCore.
#' @description Import flowJo workspaces into R. Generate the flowJo gating hierarchy and gates using flowCore functionality. Transform and compensate data in accordance with flowJo settings. Plot gates, gating hierarchies,  population statistics, and compare flowJo vs flowCore population summaries.
#' @details
#'   \tabular{ll}{
#'     Package: \tab flowWorkspace\cr
#'     Type: \tab Package\cr
#'     Version: \tab 0.5.40\cr
#'     Date: \tab 2011-03-04\cr
#'     License: \tab Artistic 2.0 \cr
#'     LazyLoad: \tab yes\cr
#'     Depends: \tab R (>= 2.16.0),Rcpp (>= 0.9.9)\cr
#'   }
#' @author Greg Finak, Mike Jiang
#' @references \url{http://www.rglab.org/}
NULL

#' @importClassesFrom XML XMLInternalDocument
setOldClass("XMLInternalDocument")

#' An R representation of a flowJo workspace.
#' 
#' Objects can be created by calls of the form \code{new("flowJoWorkspace.xml", ...)}.
#'
#' @section Slots: 
#' \describe{
#'   \item{\code{version}:}{Object of class \code{"character"}. The version of the XML workspace. }
#'   \item{\code{file}:}{Object of class \code{"character"}. The file name. }
#'   \item{\code{.cache}:}{Object of class \code{"environment"}. An environment for internal use.  }
#' 	\item{\code{path}:}{Object of class \code{"character"}. The path to the file. }
#'   \item{\code{doc}:}{Object of class \code{"XMLInternalDocument"}. The XML document object. }
#'   \item{\code{options}:}{Object of class \code{"integer"}. The XML parsing options passed to \code{\link{xmlTreeParse}}. }
#'   }
#' 
#' @seealso 
#'   \code{\linkS4class{GatingSet}} 
#'   \code{\linkS4class{GatingHierarchy}}
#' 
#' @examples
#'   require(flowWorkspaceData)
#'   d<-system.file("extdata",package="flowWorkspaceData")
#'   wsfile<-list.files(d,pattern="A2004Analysis.xml",full=TRUE)
#'   ws <- openWorkspace(wsfile);
#'   summary(ws)
#'   getSamples(ws)
#' 
#' @name flowJoWorkspace-class
#' @rdname flowJoWorkspace-class
#' @exportClass flowJoWorkspace
#' @aliases 
#' show,flowJoWorkspace-method
setClass("flowJoWorkspace"
          ,representation(version="character"
                          , file="character"
                          , .cache="environment"
                          , path="character"
                          , doc="XMLInternalDocument"
                          , options="integer")
                        )
                        
.uuid_gen<-function(){
#  system("uuidgen",intern = TRUE)
  flowCore:::guid()
}    

#' Class \code{"GatingSet"}
#' 
#' GatingSet holds a set of \code{GatingHierarchy} objects, representing a set of samples and the gating scheme associated with each.
#' 
#' @details 
#' Objects stores a collection of GatingHierarchies and represent a group in a flowJo workspace.
#' A GatingSet can have two ``states''. After a call to parseWorkspace(...,execute=FALSE)
#' , the workspace is imported but the data is not. Setting \code{execute} to \code{TRUE} is needed in order to load, 
#' transform, compensate, and gate the associated data. Whether or not a GatingHierarchy has been applied to data is encoded in the \code{flag} slot. Some methods will warn the user, or may not function correctly if the GatingHierarchy has not been executed.
#' This mechanism is in place, largely for the purpose of speed when working with larger workspaces. 
#' It allows the use to load a workspace and subset desired samples before proceeding to load the data. 
#' 
#' @section Slots:
#' 
#' \describe{
#'     \item{\code{FCSPath}:}{Object of class \code{"character"}. A path to the fcs files associated with this GatingSet } 
#'     \item{\code{data}:}{Object of class \code{"flowSet"}. flow data associated with this GatingSet }
#'     \item{\code{flag}:}{Object of class \code{"logical"}. A flag indicating whether the gates, transformations, and compensation matrices have been applied to data, or simply imported.}
#'     \item{\code{pointer}:}{Object of class \code{"externalptr"}. points to the gating hierarchy stored in C data structure.}
#'     \item{\code{guid}:}{Object of class \code{"character"}. the unique identifier for GatingSet object.}
#'   }
#' 
#' @seealso
#'   \code{\linkS4class{GatingHierarchy}}
#'   \code{\linkS4class{flowJoWorkspace}}
#'   \code{\link{parseWorkspace}}
#'  
#' @examples
#'   require(flowWorkspaceData)
#'   d<-system.file("extdata",package="flowWorkspaceData")
#'   wsfile<-list.files(d,pattern="A2004Analysis.xml",full=TRUE)
#'   ws <- openWorkspace(wsfile);
#'   G<-try(parseWorkspace(ws,execute=TRUE,path=d,name=1));
#'   plotPopCV(G);
#' 
#' @name GatingSet-class
#' @rdname GatingSet-class
#' @exportClass GatingSet
#' @aliases 
#' GatingSet-class
#' rbind2,GatingSet,GatingSet-method
#' GatingSet,flowSet-method
#' show,GatingSet-method
setClass("GatingSet"
          ,representation(pointer = "externalptr"
                          ,FCSPath = "character"
                          ,data = "flowSet"
                          ,flag = "logical"
                          ,axis = "list"
                          ,guid = "character"
                          )
          ,prototype(FCSPath =""
                      ,data = NULL
                      ,flag = FALSE
                      ,axis = list()
                      ,guid = ""
                  )                                       
          )

#' Class GatingHierarchy
#' 
#' GatingHierarchy is a class for representing the gating hierarchy,which can be either imported from a flowJo workspace or constructed in R.
#'  
#' @details 
#' There is a one-to-one correspondence between GatingHierarchy objects and FCS files in the flowJo workspace. 
#' Each sample (FCS file) is associated with it's own GatingHierarchy. It is also more space efficient by storing gating results as logical/bit vector instead of copying the raw data.
#' 
#' Given a GatingHierarchy, one can extract the data associated with any subpopulation, extract gates, plot gates, and extract population proportions. This facilitates the comparison of manual gating methods with automated gating algorithms.
#'   
#' @seealso
#' \code{\linkS4class{GatingSet}}
#' 
#' @examples
#' 	require(flowWorkspaceData)
#' 	d<-system.file("extdata",package="flowWorkspaceData")
#' 	wsfile<-list.files(d,pattern="A2004Analysis.xml",full=TRUE)
#' 	ws <- openWorkspace(wsfile);
#' 	G<-try(parseWorkspace(ws,path=d,name=1));
#'  gh <- G[[1]]
#' 	getPopStats(gh);
#' 	plotPopCV(gh)
#'  nodes <- getNodes(gh)
#'  thisNode <- nodes[4]
#' 	plotGate(gh,thisNode);
#' 	getGate(gh,thisNode);
#' 	getData(gh,thisNode)
#' 
#' @name GatingHierarchy-class
#' @rdname GatingHierarchy-class
#' @exportClass GatingHierarchy
#' @aliases 
#' show,GatingHierarchy-method
setClass("GatingHierarchy"
          , contains = "GatingSet"
#          , representation(name = "character")
#          , prototype(name = "")
        )


#' constructors for GatingSet
#' 
#' construct object from xml workspace file and a list of sampleIDs
#' @rdname GatingSet-methods
#' @aliases 
#' GatingSet,character,character-method
setMethod("GatingSet",c("character","character"),function(x,y,includeGates=FALSE, sampNloc="keyword",xmlParserOption, wsType, ...){
      
      xmlFileName<-x
      sampleIDs<-y
#			browser()
      sampNloc<-match(sampNloc,c("keyword","sampleNode"))
      if(is.na(sampNloc))
        sampNloc<-0
      stopifnot(!missing(xmlFileName))
      
      wsType <- match(wsType, c("win", "macII", "vX", "macIII"))
      if(is.na(wsType))
        stop("unrecognized workspace type: ", wsType)
      
      if(!file.exists(xmlFileName))
        stop(xmlFileName," not found!")
      Object<-new("GatingSet")
      Object@pointer<-.Call("R_parseWorkspace",xmlFileName,sampleIDs,includeGates,as.integer(sampNloc),as.integer(xmlParserOption),as.integer(wsType))
      Object@guid <- .uuid_gen()
      Object@flag <- FALSE

      return(Object)
    })


#' constructors for GatingSet
#' 
#' construct a gatingset with empty trees (just root node)
#' 
#' @rdname GatingSet-methods
#' @aliases 
#' GatingSet,flowSet,ANY-method 
setMethod("GatingSet",c("flowSet"),function(x, ...){
      
      fs_clone<-flowCore:::copyFlowSet(x)
      samples<-sampleNames(fs_clone)
      G<-new("GatingSet")
      G@pointer<-.Call("R_NewGatingSet_rootOnly",samples)
      G@guid <- .uuid_gen()
      G@flag <- TRUE
          
      flowData(G) <- fs_clone
        
      recompute(G)
      G
      
    })

#' Class \code{"GatingSetList"}
#' 
#'   A list of of \code{GatingSet} objects. This class exists for method dispatching.
#' 
#' @details 
#'   Objects store a collection of GatingSets,which usually has the same gating trees and markers.
#'   Most GatingSets methods can be applied to GatingSetList.
#' 
#' @seealso
#'   \code{\linkS4class{GatingSet}}
#'   \code{\linkS4class{GatingHierarchy}}
#' 
#' @examples
#'   \dontrun{
#'     #load several GatingSets from disk
#'    gs_list<-lapply(list.files("../gs_toMerge",full=T) ,function(this_folder){
#'                      load_gs(this_folder)
#'                      })
#'     
#'    #gs_list is a list
#'     gs_groups <- merge(gs_list)
#'     #returns a list of GatingSetList objects
#'     gslist2 <- gs_groups[[2]]
#'     #gslist2 is a GatingSetList that contains multiple GatingSets and they share the same gating and data structure
#'     gslist2
#'     class(gslist2)
#'     sampleNames(gslist2)
#'     
#'     #reference a GatingSet by numeric index
#'     gslist2[[1]]
#'     #reference a GatingSet by character index
#'     gslist2[["30104.fcs"]]
#'     
#'     #loop through all GatingSets within GatingSetList
#'     lapply(gslist2,sampleNames)
#'     
#'     #subset a GatingSetList by [
#'     sampleNames(gslist2[c(4,1)])
#'     sampleNames(gslist2[c(1,4)])
#'     gslist2[c("30104.fcs")]
#'     
#'     #get flow data from it
#'     getData(gslist2)
#'     #get gated flow data from a particular popoulation (by numeric or character index)
#'     getData(gslist2,4)
#'     
#'     #extract the gates associated with one popoulation
#'     getGate(gslist2,"3+")
#'     getGate(gslist2,5)
#'     
#'     #extract the pheno data
#'     pData(gslist2[3:1])
#'     #modify the pheno data
#'     pd <- pData(gslist2)
#'     pd$id <- 1:nrow(pd)
#'     pData(gslist2) <- pd
#'     pData(gslist2[3:2])
#' 
#'     #plot the gate
#'     plotGate(gslist2[1:2],5,smooth=T)
#'     plotGate_labkey(gslist2[3:4],4,x="<APC Cy7-A>",y="<PE Tx RD-A>",smooth=T)
#'     
#'     #remove cerntain gates by loop through GatingSets
#'     getNodes(gslist2[[1]])
#'     lapply(gslist2,function(gs)Rm("Excl",gs))
#'     
#'     #extract the stats
#'     getPopStats(gslist2)
#'     #extract statistics by using getQAStats defined in QUALIFIER package
#'     res<-getQAStats(gslist2[c(4,2)],isMFI=F,isSpike=F,nslaves=1)
#'     
#'     #archive the GatingSetList
#'     save_gslist(gslist2, path ="~/rglab/workspace/flowIncubator/output/gslist",overwrite=T)
#'     gslist2 <- load_gslist(path ="~/rglab/workspace/flowIncubator/output/gslist")
#'     
#'     #convert GatingSetList into one GatingSet by rbind2
#'     gs_merged2 <- rbind2(gslist2,ncdfFile=path.expand(tempfile(tmpdir="~/rglab/workspace/flowIncubator/output/",fileext=".nc")))
#'     gs_merged2
#'   }
#' 
#' @name GatingSetList-class
#' @rdname GatingSetList-class
#' @exportClass GatingSetList
#' @aliases 
#' GatingSetList-class
#' GatingSetList
#' show,GatingSetList-method
#' getSamples,GatingSetList-method 
#' sampleNames,GatingSetList-method
#' rbind2,GatingSetList,missing-method
#' [[,GatingSetList,numeric-method
#' [[,GatingSetList,logical-method
#' [[,GatingSetList,character-method
#' [,GatingSetList,numeric-method
#' [,GatingSetList,logical-method
#' [,GatingSetList,character-method
#' getGate,GatingSetList,numeric-method
#' getGate,GatingSetList,character-method
#' getQAStats,GatingSetList-method
#' getPopStats,GatingSetList-method
setClass("GatingSetList", contains = "ncdfFlowList")

validGatingSetListObject <- function(object){
  
  gs_list <- object@data
  #check overlapping samples
  gs_samples <- unlist(lapply(gs_list, sampleNames))
  if(any(duplicated(gs_samples))){
    return ("There are overlapping samples across GatingSets!")
  }
  
  
  gs1 <- gs_list[[1]]
  
  #compare GatingSets
  
  res <- sapply(gs_list[-1],function(this_gs){
        
        .compareGatingSet(this_gs,gs1)
      })
  
  
  is_error <- sapply(res,function(this_res){
        is.na(as.logical(this_res))
      })
  if(any(is_error)){
    this_error_ind <- which(is_error)[1]
    return (paste("GatingSet 1 and",this_error_ind+1,":",res[this_error_ind]))
  }
  
  #check sample vector
  if(!ncdfFlow:::.isValidSamples(object@samples,object)){
    return ("'samples' slot is not consisitent with sample names from GatingSets!")
  }          
  return (TRUE)
}

setValidity("GatingSetList", validGatingSetListObject)     


.flattenedGatingHiearchy<-function(gh){
  this_nodes <- getNodes(gh, showHidden = TRUE)
  paste(this_nodes,collapse = "")
}        
#TODO:gating tree comparison needs to be improved        
.compareGatingHierarchy<-function(gh1,gh2){
  if(identical(.flattenedGatingHiearchy(gh1),.flattenedGatingHiearchy(gh2))){
    return (TRUE)
  }else{
    return (paste("gating structure doesn't match:",getSample(gh1),getSample(gh2)))
  }
}
.compareFlowData<-function(fs1,fs2){
  #it is strange that colnames doesn't dispatch properly without namespace prefix
  col1 <- flowCore::colnames(fs1)
  col2 <- flowCore::colnames(fs2)
  if(!identical(col1,col2)){
    msg <- paste("colnames of flowSets don't match!")
    return (msg)
  }
  if(!identical(colnames(pData(fs1)),colnames(pData(fs2)))){
    return ("pData of flow data doesn't match!")
  }
  return  (TRUE)
  
}
.compareGatingSet<-function(gs1,gs2){
  gh1 <- gs1[[1]]
  gh2 <- gs2[[1]]
  res <- .compareGatingHierarchy(gh1,gh2)
  if(class(res) == "character"){
    return (res)
  }
  fs1 <- getData(gs1)
  fs2 <- getData(gs2)
  .compareFlowData(fs1,fs2)
}

#' @description use \code{GatingSetList} constructor to create a GatingSetList from a list of GatingSet
#' 
#' @param x a \code{list} of \code{GatingSet}
#' @param samples \code{character} vector specifying the sample names. if NULL, the sample names are extracted from GatingSets
#'
#' @rdname GatingSetList-class 
#' @export 
GatingSetList <- function(x,samples = NULL)
{
  names(x)<-NULL#strip names from the list because rbind2 doesn't like it
  flowCore:::checkClass(x, "list")
  if(is.null(samples)){
    samples <- unlist(lapply(x,sampleNames))
  }
  x <- new("ncdfFlowList", data = x, samples = samples)

  x<- as(x, "GatingSetList")
  if(validObject(x))
    x
}


#' A class describing logical operation (& or |) of the reference populations
#' 
#' \code{booleanFilter} class inherits class \code{\link{expressionFilter}} and exists for the purpose of methods dispatching.
#' 
#' @seealso \code{\link{add}} \code{\linkS4class{GatingHierarchy}}
#' @name booleanFilter-class
#' @rdname booleanFilter-class
#' @exportClass booleanFilter
#' @importClassesFrom flowCore filter concreteFilter expressionFilter
#' @aliases 
#' show,booleanFilter-method
setClass("booleanFilter"
		,contains=c("expressionFilter")
)

#' \code{booleanFilter} is a constructor from an expression
#' @param expr \code{expression} or \code{character}
#' @param ... further arguments to the expression
#' @param filterId \code{character} identifier
#' @rdname booleanFilter-class
#' @export 
booleanFilter <- function(expr, ..., filterId="defaultBooleanFilter")
{
	subs <- substitute(expr)
	if(missing(filterId)){
		filterId <- deparse(subs)
		if(length(filterId)>1)
			filterId <- paste(gsub("^ *", "", filterId[2]), "...", sep="")
	}else flowCore:::checkClass(filterId, "character", 1)
	new("booleanFilter", filterId=filterId, expr=as.expression(subs),
			args=list(...), deparse=deparse(subs))
}

#' \code{char2booleanFilter} is a constructor from a character string
#' @rdname booleanFilter-class 
#' @export 
char2booleanFilter <- function(expr, ..., filterId="defaultBooleanFilter") {
  flowCore:::checkClass(expr, "character", 1)
  subs <- parse(text=expr)
  if (missing(filterId)) {
    filterId <- expr
  }
  else {
    flowCore:::checkClass(filterId, "character", 1)
  }
  new("booleanFilter", filterId = filterId, expr = subs, args = list(...),
      deparse = expr)
}

#' @rdname booleanFilter-class
#' @export 
#' @importMethodsFrom flowCore identifier
setMethod("show",signature("booleanFilter"),function(object){
			
			msg <- paste("booleanFilter filter '", identifier(object),
					"' evaluating the expression:\n",
					paste(object@deparse, collapse="\n"), sep="")
			cat(msg)
			cat("\n")
			invisible(msg)
		})
