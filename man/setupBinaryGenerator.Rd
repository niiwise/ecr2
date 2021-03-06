% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/operator.generator.random.binary.R
\name{setupBinaryGenerator}
\alias{setupBinaryGenerator}
\title{Generates a generator object for the initial population.}
\usage{
setupBinaryGenerator(len)
}
\arguments{
\item{len}{[\code{integer(1)}]\cr
Length of genotype.}
}
\value{
[\code{ecr_generator}]
}
\description{
The generated operator samples uniformally distributed points in the design
space of the target function taking care not to violate box constraints.
}

