# utils.R

#' Repeat each column of a matrix n times
#'
#' This function repeats each column of a matrix n times
#' 
#' @param x is the input matrix
#' @param n is the number of repetitions
#' @return matrix with repeated columns
rep.col<-function(x,n){
    s = NCOL(x)
    x[,rep(1:s, each=n)]
}

#' Repeat each row of a matrix n times
#'
#' This function repeats each row of a matrix n times
#' 
#' @param x is the input matrix
#' @param n is the number of repetitions
#' @return matrix with repeated rows
rep.row<-function(x,n){
    s = NROW(x)
    x[rep(1:s, each=n),]
}
