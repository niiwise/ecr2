context("mutate helper")

test_that("recombinate helper works if control is passed", {
  # get test function
  fitness.fun = function(x) sum(x)
  mu = 30L
  b.bits = 20L

  # setup control
  control = initECRControlBinary(fitness.fun = fitness.fun, n.bits = b.bits, n.objectives = 1L)
  inds = replicate(mu, sample(c(0, 1), 10, replace = TRUE), simplify = FALSE)
  fitness = matrix(sapply(inds, fitness.fun), nrow = 1L)

  # now recombinate with prob 1 and pass additional arguments
  rec.inds = recombinate(control, inds, fitness, p.recomb = 1)

  # ... and check whether these arguments are passed to mutator
  expect_length(rec.inds, mu)
  rec.inds = unlist(rec.inds)
  expect_true(all(rec.inds %in% c(0, 1)))
})
