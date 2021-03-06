modelInfo <- list(label = "Generalized Additive Model using Splines",
                  library = "mgcv",
                  loop = NULL,
                  type = c('Regression', 'Classification'),
                  parameters = data.frame(parameter = c('select', 'method'),
                                          class = c('logical', 'character'),
                                          label = c('Feature Selection', 'Method')),
                  grid = function(x, y, len = NULL) 
                    expand.grid(select = c(TRUE, FALSE), method = "GCV.Cp"),
                  fit = function(x, y, wts, param, lev, last, classProbs, ...) { 
                    dat <- if(is.data.frame(x)) x else as.data.frame(x)
                    modForm <- caret:::smootherFormula(x)
                    if(is.factor(y)) {
                      dat$.outcome <- ifelse(y == lev[1], 0, 1)
                      dist <- binomial()
                    } else {
                      dat$.outcome <- y
                      dist <- gaussian()
                    }
                    modelArgs <- list(formula = modForm,
                                      data = dat,
                                      select = param$select, 
                                      method = as.character(param$method))
                    ## Intercept family if passed in
                    theDots <- list(...)
                    if(!any(names(theDots) == "family")) modelArgs$family <- dist
                    modelArgs <- c(modelArgs, theDots)
                    
                    out <- do.call(getFromNamespace("gam", "mgcv"), modelArgs)
                    out
                    
                  },
                  predict = function(modelFit, newdata, submodels = NULL) {
                    if(!is.data.frame(newdata)) newdata <- as.data.frame(newdata)
                    if(modelFit$problemType == "Classification") {
                      probs <-  predict(modelFit, newdata, type = "response")
                      out <- ifelse(probs < .5,
                                    modelFit$obsLevel[1],
                                    modelFit$obsLevel[2])
                    } else {
                      out <- predict(modelFit, newdata, type = "response")
                    }
                    out
                  },
                  prob = function(modelFit, newdata, submodels = NULL){
                    if(!is.data.frame(newdata)) newdata <- as.data.frame(newdata)
                    out <- predict(modelFit, newdata, type = "response")
                    out <- cbind(1-out, out)
                    ## glm models the second factor level, we treat the first as the
                    ## event of interest. See Details in ?glm
                    colnames(out) <-  modelFit$obsLevels
                    out
                  },
                  predictors = function(x, ...) {
                    predictors(x$terms)
                  },
                  levels = function(x) x$obsLevels,
                  varImp = function(object, ...) {
                    smoothed <- summary(object)$s.table[, "p-value", drop = FALSE]
                    linear <- summary(object)$p.table
                    linear <- linear[, grepl("^Pr", colnames(linear)), drop = FALSE] 
                    gams <- rbind(smoothed, linear)
                    gams <- gams[rownames(gams) != "(Intercept)",,drop = FALSE]
                    rownames(gams) <- gsub("^s\\(", "", rownames(gams))
                    rownames(gams) <- gsub("\\)$", "", rownames(gams))
                    colnames(gams)[1] <- "Overall"
                    gams <- as.data.frame(gams)
                    gams$Overall <- -log10(gams$Overall)
                    allPreds <- colnames(attr(object$terms,"factors"))
                    extras <- allPreds[!(allPreds %in% rownames(gams))]
                    if(any(extras)) {
                      tmp <- data.frame(Overall = rep(NA, length(extras)))
                      rownames(tmp) <- extras
                      gams <- rbind(gams, tmp)
                    }
                    gams
                  },
                  tags = c("Generalized Linear Model", "Generalized Additive Model"),
                  sort = function(x) x)
