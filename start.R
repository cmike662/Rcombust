#!/usr/bin/env r

library(shiny)
runApp('CPT', port=7775, launch.browser = TRUE, 
host = strsplit(system('hostname -I',intern=T)," ")[[1]][1])

