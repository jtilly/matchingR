#  matchingR -- Matching Algorithms in R and C++
#
#  Copyright (C) 2015  Jan Tilly <jtilly@econ.upenn.edu>
#                      Nick Janetos <njanetos@econ.upenn.edu>
#
#  This file is part of matchingR.
#
#  matchingR is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 2 of the License, or
#  (at your option) any later version.
#
#  matchingR is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

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

