\name{getTransformations}
\alias{getTransformations}
\alias{getTransformations-methods}
\alias{getTransformations,GatingHierarchy-method}
\title{Return a list of transformations or a transformation in a GatingHierarchy}
\arguments{
  \item{x}{A \code{GatingHierarchy} object}
}
\value{
  lists of functions, with each element of the list
  representing a transformation applied to a specific
  channel/parameter of a sample.
}
\description{
  Return a list of all the transformations or a
  transformation in a GatingHierarchy
}
\details{
  Returns a list of the transformations or a transformation
  in the flowJo workspace. The list is of length \code{L},
  where \code{L} is the number of distinct transformations
  applied to samples in the \code{flowJoWorkspace}. Each
  element of \code{L} is itself a \code{list} of length
  \code{M}, where \code{M} is the number of parameters that
  were transformed for a sample or group of samples in a
  \code{flowJoWorkspace}. For example, if a sample has 10
  parameters, and 5 are transformed during analysis, using
  two different sets of transformations, then L will be of
  length 2, and each element of L will be of length 5. The
  elements of \code{L} represent channel- or
  parameter-specific transformation functions that map from
  raw intensity values to channel-space used by flowJo.
  this method currently is used convert transformation
  funtion from c++ to R mainly for transforming range info
}
\examples{
\dontrun{
	#Assume gh is a GatingHierarchy
	getTransformations(gh);
}
}

