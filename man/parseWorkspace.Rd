\name{parseWorkspace}
\alias{parseWorkspace}
\alias{parseWorkspace-methods}
\alias{parseWorkspace,flowJoWorkspace-method}
\title{Parse a flowJo Workspace}
\arguments{
  \item{obj}{A \code{flowJoWorkspace} to be parsed.}

  \item{name}{\code{numeric} or \code{character}. The name
  or index of the group of samples to be imported. If
  \code{NULL}, the groups are printed to the screen and one
  can be selected interactively. Usually, multiple groups
  are defined in the flowJo workspace file.}

  \item{execute}{\code{TRUE|FALSE} a logical specifying if
  the gates, transformations, and compensation should be
  immediately calculated after the flowJo workspace have
  been imported. TRUE by default.}

  \item{isNcdf}{\code{TRUE|FALSE} logical specifying if you
  would like to use netcdf to store the data, or if you
  would like to keep all the flowFrames in memory. For a
  small data set, you can safely set this to FALSE, but for
  larger data, we suggest using netcdf. You will need the
  netcdf C library installed.}

  \item{subset}{\code{numeric} vector specifying the subset
  of samples in a group to import. Or a \code{character}
  specifying the FCS filenames to be imported.}

  \item{requiregates}{\code{logical} Should samples that
  have no gates be included?}

  \item{includeGates}{\code{logical} Should gates be
  imported, or just the data with compensation and
  transformation?}

  \item{path}{The path to the fcs files that are to be
  imported. The code will search recursively, so you can
  point it to a location above the files. This argument is
  mandatory.}

  \item{...}{\itemize{ \item sampNloc="keyword": a
  \code{character} scalar indicating where to get
  sampleName(or FCS filename) within xml workspace. It is
  either from "keyword" or "sampleNode".  \item
  compensation=NULL: a \code{matrix} that allow the
  customized compensation matrix to be used instead of the
  one specified in flowJo workspace.  \item options=0: a
  \code{integer} option passed to
  \code{\link{xmlTreeParse}} \item ignore.case a
  \code{logical} flag indicates whether the
  colnames(channel names) matching needs to be case
  sensitive (e.g. compensation, gating..)  \item extend_val
  \code{numeric} the threshold that determine wether the
  gates need to be extended. default is 0. It is triggered
  when gate coordinates are below this value.  \item
  extend_to \code{numeric} the value that gate coordinates
  are extended to. Default is -4000. Usually this value
  will be automatically detected according to the real data
  range.  But when the gates needs to be extended without
  loading the raw data (i.e. \code{execute} is set to
  FALSE), then this hard-coded value is used.  \item ...:
  Additional arguments to be passed to
  \link{read.ncdfFlowSet} or \link{read.flowSet}.  }}
}
\value{
  a \code{GatingSet}, which is a wrapper around a list of
  \code{GatingHierarchy} objects, each representing a
  single sample in the workspace. The
  \code{GatingHierarchy} objects contain \code{graphNEL}
  trees that represent the gating hierarchy of each sample.
  Each node in the \code{GatingHierarchy} has associated
  data, including the population counts from flowJo, the
  parent population counts, the \code{flowCore} gates
  generated from the flowJo workspace gate definitions.
  Data are not yet loaded or acted upon at this stage. To
  execute the gating of each data file, a call to
  \code{execute()} must be made on each
  \code{GatingHierarchy} object in the \code{GatingSet}.
  This is done automatically by default, and there is no
  more reason to set this argument to FALSE.
}
\description{
  Function to parse a flowJo Workspace, generate a
  \code{GatingHierarchy} or \code{GatingSet} object, and
  associated flowCore gates. The data are not loaded or
  acted upon until an explicit call to \code{recompute()}
  is made on the \code{GatingHierarchy} objects in the
  \code{GatingSet}.
}
\details{
  A flowJoWorkspace is generated with a call to
  \code{openWorkspace()}, passing the name of the xml
  workspace file. This returns a \code{flowJoWorkspace},
  which can be parsed using the \code{parseWorkspace()}
  method. The function can be called non-interactively by
  passing the index or name of the group of samples to be
  imported via \code{parseWorkspace(obj,name=x)}, where
  \code{x} is either the numeric index, or the name. The
  \code{subset} argument allows one to select a set of
  files from the chosen sample group. The routine will take
  the intersection of the files in the sample group, the
  files specified in \code{subset} and the files available
  on disk, and import them.
}
\examples{
\dontrun{
	 #f is a xml file name of a flowJo workspace
	ws<-openWorkspace(f)
	G<-parseWorkspace(ws,execute=TRUE,isNcdf=FALSE,path="."); #assume that the fcs files are below the current directory.
	#G is a GatingSet.
	G1<-parseWorkspace(ws)
	#G1 is a GatingSet.
}
}
\seealso{
  \code{\link{getSampleGroups}},\code{\link{GatingSet}}
}

