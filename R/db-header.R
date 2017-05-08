dbHeader <- dashboardHeader()
dbHeader$children[[2]]$children <-  tags$a(h1 = "M50 Test dashboard",
                                           tags$img(src = 'logo.png', height = '40'))