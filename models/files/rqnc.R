modelInfo <- list(label = "Non-Convex Penalized Quantile Regression",
                  library = "rqPen",
                  type = "Regression",
                  parameters = data.frame(parameter = c('lambda', 'penalty'),
                                          class = c("numeric", "character"),
                                          label =  c('L1 Penalty', 'Penalty Type')),
                  grid = function(x, y, len = NULL)
                    expand.grid(lambda = c(10 ^ seq(-1, -4, length = len)),
                                penalty = c("MCP", "SCAD")),
                  loop = NULL,
                  fit = function(x, y, wts, param, lev, last, classProbs, ...) {
                    rq.nc.fit(as.matrix(x), y, 
                              lambda = param$lambda, 
                              penalty = as.character(param$penalty), ...)
                    },
                  predict = function(modelFit, newdata, submodels = NULL) {
                    predict(modelFit, newx = as.matrix(newdata))[,1]
                  },
                  predictors = function(x, ...) {
                    out <- coef(x)
                    out <- out[names(out) != "intercept"]
                    names(out)[out != 0]
                  },
                  tags = c("Linear Regression", "Quantile Regression", "Implicit Feature Selection", "L1 Regularization"),
                  prob = NULL,
                  sort = function(x) x[order(-x$lambda),])
