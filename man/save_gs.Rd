\name{save_gs}
\alias{load_gs}
\alias{load_gslist}
\alias{save_gs}
\alias{save_gslist}
\title{save/load a GatingSet/GatingSetList to/from disk.}
\usage{
  save_gs(G, path, overwrite = FALSE,
    cdf = c("copy", "move", "skip", "symlink", "link"),
    type = c("binary", "text", "xml"), ...)

  load_gs(path)

  save_gslist(gslist, path, ...)

  load_gslist(path)
}
\arguments{
  \item{G}{A \code{GatingSet}}

  \item{gslist}{A \code{GatingSetList}}

  \item{path}{A character scalar giving the path to
  save/load the GatingSet to/from.}

  \item{overwrite}{A logical scalar specifying whether to
  overwrite the existing folder.}

  \item{cdf}{a character scalar. The valid options are
  :"copy","move","skip","symlink","link" specifying what to
  do with the cdf data file.  Sometime it is more efficient
  to move or create a link of the existing cdf file to the
  archived folder.  It is useful to "skip" archiving cdf
  file if raw data has not been changed.}

  \item{type}{a character scalar. The valid options are
  :"binary","text","xml" specifying format to store tree
  structure.  default is "binary", which is smaller and
  faster but machine-dependent.  use "text" or "xml" for
  cross-platform data interchange (experimental at this
  stage, may or maynot work).}

  \item{...}{other arguments: not used.}
}
\value{
  \code{load_gs} returns a GatingSet object
  \code{load_gslist} returns a GatingSetList object
}
\description{
  Save/load a GatingSet/GatingSetList which is the gated
  flow data including gates and populations to/from the
  disk. The \code{GatingSet} object The internal C data
  structure (gating tree),\code{ncdfFlowSet} object(if
  applicable)
}
\examples{
\dontrun{
	#G is a GatingSet
	save_gs(G,path="tempFolder")
	G1<-load_gs(path="tempFolder")

	#G is a GatingSet

	save_gslist(gslist1,path="tempFolder")
	gslist2<-load_gslist(path="tempFolder")
}
}
\seealso{
  \code{\link{GatingSet-class}},\code{\link{GatingSetList-class}}
}

