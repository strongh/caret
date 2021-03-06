modelInfo <- list(label = "ROC-Based Classifier",
                  library = "rocc",
                  loop = NULL,
                  type = c('Classification'),
                  parameters = data.frame(parameter = c('xgenes'),
                                          class = c('numeric'),
                                          label = c('#Variables Retained')),
                  grid = function(x, y, len = NULL) {
                    data.frame(xgenes = caret::var_seq(p = ncol(x), 
                                                classification = is.factor(y), 
                                                len = len))
                  },
                  fit = function(x, y, wts, param, lev, last, classProbs, ...) { 
                    newY <- factor(ifelse(y == levels(y)[1], 1, 0), levels = c("0", "1"))
                    tr.rocc(g = t(as.matrix(x)), out = newY, xgenes = param$xgenes)
                    },
                  predict = function(modelFit, newdata, submodels = NULL) {
                    tmp <- p.rocc(modelFit, t(as.matrix(newdata)))
                    factor(ifelse(tmp == "1",  modelFit$obsLevels[1],  modelFit$obsLevels[2]),
                           levels =  modelFit$obsLevels)
                  },
                  levels = function(x) x$obsLevels,
                  prob = NULL,
                  predictors = function(x, ...) x$genes,
                  tags = "ROC Curves",
                  sort = function(x) x[order(x$xgenes),])
