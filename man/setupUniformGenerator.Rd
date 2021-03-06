% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/operator.generator.uniform.float.R
\name{setupUniformGenerator}
\alias{setupUniformGenerator}
\title{Generates the uniform generator object for the initial population.}
\usage{
setupUniformGenerator(len, lower, upper)
}
\arguments{
\item{len}{[\code{integer(1)}]\cr
Length of genotype.}

\item{lower}{[\code{numeric}]\cr
Vector of lower box constraints for each dimension.
If a single value is passed this value is taken for each dimension.}

\item{upper}{[\code{numeric}]\cr
Vector of lower box constraints for each dimension.
If a single value is passed this value is taken for each dimension.}
}
\value{
[\code{ecr_generator}]
}
\description{
The returned population contains individuals which are uniformly distributed
within the bounds specified.
}

