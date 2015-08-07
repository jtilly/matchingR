# utils.R

#' Repeat each column of a matrix n times
#'
#' This function repeats each column of a matrix n times
#'
#' @param x is the input matrix
#' @param n is the number of repetitions
#' @return matrix with repeated columns
repcol<-function(x,n){
    s = NCOL(x)
    matrix(x[,rep(1:s, each=n)], nrow=NROW(x), ncol=NCOL(x)*n)
}

#' Repeat each row of a matrix n times
#'
#' This function repeats each row of a matrix n times
#'
#' @param x is the input matrix
#' @param n is the number of repetitions
#' @return matrix with repeated rows
reprow<-function(x,n){
    s = NROW(x)
    matrix(x[rep(1:s, each=n),], nrow=NROW(x)*n, ncol=NCOL(x))
}

