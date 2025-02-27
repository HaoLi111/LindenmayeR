##' Draw a 2D L-System Using Turtle Graphics
##'
##' This function takes input strings, previously created with \code{\link{Lsys}},
##' translates them into 2D turtle graphics instructions, and then plots the results.
##'
##' @param string A character vector giving the strings containing the turtle graphics
##' instructions.  Created by \code{\link{Lsys}}.  The "language" and character set
##' of this string is arbitary.  Compare the examples below for the modified Koch
##' curve and the Sierpinski triangle.
##'
##' @param drules A data frame containing columns "symbols" and "action".  These contain the input
##' symbols and the corresponding drawing action.  The symbol column is in the
##' character set used by \code{\link{Lsys}} and is arbitary.  The action column
##' entries must be from the set \code{c("F", "f", "+", "-", "[", "]")}.  These are
##' the final drawing instructions and are interpreted as follows:
##' \describe{
##'   \item{"F"}{Move forward drawing as you go.}
##'   \item{"f"}{Move forward w/o drawing.}
##'   \item{"+"}{Turn by positive \code{ang}.}
##'   \item{"-"}{Turn by negative \code{ang}.}
##'   \item{"["}{Save current position and heading.}
##'   \item{"]"}{Restore saved position and heading (allows one to go back).}
##' }
##' See the examples.  Note that the "action" entry always uses these symbols,
##' though not all of them need be used.
##'
##' @param st A numeric vector of length 3 giving the screen coordinates where
##' the start of the curve should be placed.  The screen is 100 x 100 with the
##' lower left corner as 0,0.  The third element is the initial drawing angle
##' in degrees.
##'
##' @param stepSize Numeric.  The length of the drawing step.
##'
##' @param ang Numeric.  The angle in degrees when a change in direction is requested.
##'
##' @param which Integer.  The entries in \code{string} which should be drawn.  Defaults
##' to the last (most complex) entry.  If \code{length(which) > 1} each plot is drawn in
##' its own window.
##'
##' @param shrinkFactor A numeric vector of the same length as \code{string}.  As each
##' plot is made, \code{stepSize} will be divided by the corresponding value in \code{shrinkFactor}.
##' This allows one to scale down the increasingly large/complex plots to make them
##' occupy a space similar to the less complex plots.
##'
##' @param ...  Additional parameters to be passed to the \code{grid} drawing routines.
##' Most likely, something of the form \code{gp = gpar(...)}.  See \code{\link{gpar}}
##' and the last example.
##'
##' @section Warning: Remember that if \code{retAll = TRUE}, \code{\link{Lsys}} returns
##' the initial string plus the results of all iterations.  In this case, if you want
##' the 5th iteration, you should specify \code{which = 6} since
##' the initial string is in \code{string[1]}.
##'
##' @return none, side effect is a plot, UNLESS record is set to be TURE then a data frame, containing coordinate data and segment types
##'   s for start of a segment d for segment endpoints to be drawn, r for reverse points, see \code{\link{recLsys}}
##'
##' @name drawLsys
##' @rdname drawLsys
##' @export
##' @keywords plot
##'
##' @examples
##' require('grid')
##'
##' # Modified Koch curve
##' rkoch1 <- data.frame(inp = c("F"), out = c("F+F-F-F+F"), stringsAsFactors = FALSE)
##' k1 <- Lsys(init = "F", rules = rkoch1, n = 3)
##' dkoch <- data.frame(symbol = c("F", "f", "+", "-", "[", "]"),
##' action = c("F", "f", "+", "-", "[", "]"), stringsAsFactors = FALSE)
##' drawLsys(string = k1, stepSize = 3, st = c(10, 50, 0), drules = dkoch)
##' grid.text("Modified Koch Curve (n = 3)", 0.5, 0.25)
##'
##' # Classic Koch snowflake
##' rkoch2 <- data.frame(inp = c("F"), out = c("F-F++F-F"), stringsAsFactors = FALSE)
##' k2 <- Lsys(init = "F++F++F", rules = rkoch2, n = 4)
##' drawLsys(string = k2, stepSize = 1, ang = 60, st = c(10, 25, 0), drules = dkoch)
##' grid.text("Classic Koch Snowflake (n = 4)", 0.5, 0.5)
##'
##' # Sierpinski Triangle
##' rSierp <- data.frame(inp = c("A", "B"), out = c("B-A-B", "A+B+A"), stringsAsFactors = FALSE)
##' s <- Lsys(init = "A", rules = rSierp, n = 6)
##' dSierp <- data.frame(symbol = c("A", "B", "+", "-", "[", "]"),
##' action = c("F", "F", "+", "-", "[", "]"), stringsAsFactors = FALSE)
##' drawLsys(string = s, stepSize = 1, ang = 60, st = c(20, 25, 0), drules = dSierp)
##' grid.text("Sierpinski Triangle (n = 6)", 0.5, 0.1)
##'
##' # Islands & Lakes
##' islands_rules <- data.frame(inp = c("F", "f"), out = c("F+f-FF+F+FF+Ff+FF-f+FF-F-FF-Ff-FFF",
##' "ffffff"), stringsAsFactors = FALSE)
##' islands <- Lsys(init = "F+F+F+F", rules = islands_rules, n = 2)
##' draw_islands <- data.frame(symbol = c("F", "f", "+", "-", "[", "]"),
##' action = c("F", "f", "+", "-", "[", "]"), stringsAsFactors = FALSE)
##' drawLsys(string = islands, step = 1, ang = 90, st = c(70, 35, 90),
##' drules = draw_islands,  gp = gpar(col = "red", fill = "gray"))
##'
##' # A primitive tree (aka Pythagoras Tree)
##' prim_rules <- data.frame(inp = c("0", "1"),
##' out = c("1[+0]-0", "11"), stringsAsFactors = FALSE)
##' primitive_plant <- Lsys(init = "0", rules = prim_rules, n = 7)
##' draw_prim <- data.frame(symbol = c("0", "1", "+", "-", "[", "]"),
##' action = c("F", "F", "+", "-", "[", "]"), stringsAsFactors = FALSE)
##' drawLsys(string = primitive_plant, stepSize = 1, ang = 45, st = c(50, 5, 90),
##' drules = draw_prim, which = 7)
##' grid.text("Primitive Tree (n = 6)", 0.5, 0.75)
##'
##' # A more realistic botanical structure
##' # Some call this a fractal tree, I think it is more like seaweed
##' # Try drawing the last iteration (too slow for here, but looks great)
##' fractal_tree_rules <- data.frame(inp = c("X", "F"),
##' out = c("F-[[X]+X]+F[+FX]-X", "FF"), stringsAsFactors = FALSE)
##' fractal_tree <- Lsys(init = "X", rules = fractal_tree_rules, n = 7)
##' draw_ft <- data.frame(symbol = c("X", "F", "+", "-", "[", "]"),
##' action = c("f", "F", "+", "-", "[", "]"), stringsAsFactors = FALSE)
##' drawLsys(string = fractal_tree, stepSize = 2, ang = 25, st = c(50, 5, 90),
##' drules = draw_ft, which = 5, gp = gpar(col = "chocolate4", fill = "honeydew"))
##' grid.text("Fractal Seaweed (n = 4)", 0.25, 0.25)
##'
##' # Calculation/rendering separation
##'
##' d = drawLsys(fractal_tree, stepSize = 2, ang = 25, st = c(50, 5, 90),drules = draw_ft, which = 5,record=TRUE)
##' ggLsys(d)
##'
##'

drawLsys <- function(string = NULL, drules = NULL,
	st = c(5, 50, 0), stepSize = 1.0, ang = 90.0,
	which = length(string), shrinkFactor = NULL,
	record = FALSE,
	...) {

	# check drules to make sure only allowed characters were given
	OK <- c("F", "f", "+", "-", "[", "]")
	test <- drules$action
	if (!all(test %in% OK)) {
		msg1 <- paste("Only the following actions are recognized:",
			paste(OK, collapse = " "), sep = " ")
		message(msg1)
		good <- test %in% OK
		bad <- test[!good]
		msg2 <- paste("I can't use these:",
			paste(bad, collapse = " "), sep = " ")
		stop(msg2)
		}

	for (n in 1:length(which)) {

		# set up the viewport
		grid.newpage()
		vp <- viewport(x = 0.5, y = 0.5,
			width = 1.0, height = 1.0,
			xscale = c(0, 100), yscale = c(0, 100),
			name = "VP0")
		pushViewport(vp)
		grid.rect(...) # needed if a colored bkgnd is desired

		# convert the initial string into drawing instructions
		# F = move forward; f = move w/o drawing
		# +, - turn by angle; [ save cp, ch; ] restore saved cp, ch

		string <- unlist(strsplit(string[which[n]], ""))

		for (i in 1:nrow(drules)) { # translate to drawing commands
			for (j in 1:length(string)) {
					if (string[j] == drules$symbol[i]) string[j] <- drules$action[i]
					}
			}

		# execute the drawing instructions

		grid.move.to(st[1], st[2], default.units = "native")
		cp <- st # cp = current point
		ch <- st[3] # ch = current heading, 0 = East in degrees
		if (!is.null(shrinkFactor)) stepSize <- stepSize/shrinkFactor
		fifo <- vector("list") # store info to restore later
		ns <- 0L # stack counter



		if(isTRUE(record)){
		  recLsys(string = string, drules =drules,
		                     st =st, stepSize =stepSize, ang =ang,
		                     which = which, shrinkFactor =shrinkFactor)
		}else{
		  for (j in 1:length(string))	{
		    #cat("Processing character", j, "\n")
		    if (string[j] == "F") {
		      x <- cp[1] + stepSize*cos(ch*pi/180)
		      y <- cp[2] + stepSize*sin(ch*pi/180)
		      grid.line.to(x, y, default.units = "native", ...)
		      cp <- c(x, y)
		    }else	if(string[j] == "f") {
		      x <- cp[1] + stepSize*cos(ch*pi/180)
		      y <- cp[2] + stepSize*sin(ch*pi/180)
		      grid.move.to(x, y, default.units = "native")
		      cp <- c(x, y)
		    }else if(string[j] == "[") {
		      #cat("Found a [ \n")
		      #cat("ns is:", ns, "\n")
		      ns <- ns + 1 # save the current settings
		      fifo[[ns]] <- c(cp, ch)
		      #print(fifo)
		    }else if(string[j] == "]") {
		      #cat("Found a ] \n")
		      #cat("ns is:", ns, "\n")
		      cp <- fifo[[ns]][1:2]
		      ch <- fifo[[ns]][3]
		      grid.move.to(cp[1], cp[2], default.units = "native")
		      ns <- ns - 1
		      #print(fifo)
		    }else	if(string[j] == "-"){
		      ch = ch - ang
		    }else{
		      if (string[j] == "+") ch = ch + ang
		    }
		  }
		} # end of looping over which
		}


	}
