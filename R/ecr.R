#' @title
#' Interface to \pkg{ecr} similar to the \code{\link[stats]{optim}} function.
#'
#' @description
#' The most flexible way to setup evolutionary algorithms with \pkg{ecr} is by
#' explicitely generating a task and a control object and passing both to
#' \code{\link{doTheEvolution}}. Although this approach is highly flexible
#' and very readable it requires quite a lot of code. However, in everyday
#' life R users frequently need to optimize a single-objective R function.
#' The \code{ecr} function thus provides a more R like interface for single
#' objective optimization similar to the interface of the \code{\link[stats]{optim}}
#' function.
#'
#' @note
#' This helper function is applicable for single-objective optimization based
#' on default encodings, i.e., binary, float and permutation, only.
#' If your function at hand has multiple objectives or you need special
#' encodings and operators you need to work with \code{\link{doTheEvolution}}
#' directly.
#'
#' @keywords optimize
#'
#' @seealso \code{\link{initECRControl}} for building the control object,
#' \code{\link{makeOptimizationTask}} to define an optimization task.
#'
#' @template arg_fitness_fun
#' @template arg_minimize
#' @template arg_n_objectives
#' @template arg_n_dim
#' @template arg_lower
#' @template arg_upper
#' @template arg_n_bits
#' @template arg_representation
#' @template arg_mu
#' @template arg_lambda
#' @template arg_perm
#' @template arg_p_recomb
#' @template arg_p_mut
#' @template arg_survival_strategy
#' @template arg_n_elite
#' @template arg_custom_constants
#' @template arg_logger
#' @template arg_monitor
#' @template arg_max_iter
#' @template arg_max_evals
#' @template arg_max_time
#' @template arg_more_args
#' @template arg_initial_solutions
#' @template arg_parent_selector
#' @template arg_survival_selector
#' @template arg_generator
#' @template arg_mutator
#' @template arg_recombinator
#' @return [\code{\link{ecr_result}}]
#' @examples
#' fn = function(x) {
#'    sum(x^2)
#'  }
#'
#' res = ecr(fn, n.dim = 2L, n.objectives = 1L, lower = c(-5, -5), upper = c(5, 5),
#'  representation = "float", mu = 20L, lambda = 10L, max.iter = 30L)
#' @export
ecr = function(
  fitness.fun, minimize = rep(TRUE, n.objectives), n.objectives,
  n.dim, lower = NULL, upper = NULL, n.bits,
  representation, mu, lambda, perm = NULL,
  p.recomb = 0.7, p.mut = 0.3,
  survival.strategy = "plus", n.elite = 0L,
  custom.constants = list(), logger = NULL, monitor = setupConsoleMonitor(),
  max.iter = 100L, max.evals = Inf, max.time = Inf,
  more.args = list(), initial.solutions = NULL,
  parent.selector = NULL,
  survival.selector = NULL,
  generator = NULL,
  mutator = NULL,
  recombinator = NULL) {

  n.objectives = asInt(n.objectives, lower = 1L)
  assertChoice(representation, c("binary", "float", "permutation", "custom"))
  assertChoice(survival.strategy, c("comma", "plus"))
  assertNumber(p.recomb, lower = 0, upper = 1)
  assertNumber(p.mut, lower = 0, upper = 1)
  mu = asInt(mu, lower = 5L)
  lambda.lower = if (survival.strategy == "plus") 1L else mu
  lambda = asInt(lambda, lower = lambda.lower)

  control = if (representation == "binary") {
    initECRControlBinary(fitness.fun, n.bits = n.bits, n.objectives = n.objectives, minimize = minimize)
  } else if (representation == "float") {
    initECRControlFloat(fitness.fun, lower = lower, upper = upper, n.dim = n.dim,
      n.objectives = n.objectives, minimize = minimize)
  } else if (representation == "permutation") {
    initECRControlPermutation(fitness.fun, perm = perm,
      n.objectives = n.objectives, minimize = minimize)
  }

  control = initDefaultOperators(control, representation, n.objectives)

  control = registerRecombinator(control, recombinator)
  control = registerGenerator(control, operator.fun = generator)
  control = registerSurvivalSelector(control, operator.fun = survival.selector)
  control = registerMatingSelector(control, operator.fun = parent.selector)
  control = registerLogger(control, logger = setupECRDefaultLogger(
    log.stats = list("min", "max", "mean"),#, "hv" = list(fun = computeDominatedHypervolume, pars = list(ref.point = rep(11, 2L)))),
    log.pop = TRUE, init.size = 10000L)
  )

  # simply pass stuff down to control object constructor
  population = initPopulation(mu = mu, control = control, init.solutions = initial.solutions)
  fitness = evaluateFitness(population, control)

  # init logger
  control$logger$before()

  st = Sys.time()
  time.passed = Sys.time() - st
  n.evals = mu
  n.iter = 1L

  repeat {
    catf("Iteration %i of %i.", n.iter, max.iter)
    if (n.iter >= max.iter) {
      break
    }
    if (time.passed >= max.time) {
      break
    }
    if (n.evals >= max.evals) {
      break
    }

    # generate offspring
    offspring = generateOffspring(control, population, fitness, lambda = lambda, p.recomb = p.recomb, p.mut = p.mut)
    fitness.offspring = evaluateFitness(offspring, control)
    n.evals = n.evals + lambda

    sel = if (survival.strategy == "plus") {
      replaceMuPlusLambda(control, population, offspring, fitness, fitness.offspring)
    } else {
      replaceMuCommaLambda(control, population, offspring, fitness, fitness.offspring, n.elite = n.elite)
    }

    population = sel$population
    fitness = sel$fitness

    # do some logging
    control$logger$step(control$logger, population, fitness, n.iter)
    time.passed = Sys.time() - st
    n.iter = n.iter + 1L
  }
  return(list(population = population, fitness = fitness))
}