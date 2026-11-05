/**
 * Farm: a simulation model of a farm with cows, sheep and goats.
 */
model Assignment_4

global {
	// Number of cows created at the start of the simulation
	int nb_cows <- 5;
	// Number of sheep created at the start of the simulation
	int nb_sheep <- 3;
	// Number of goats created at the start of the simulation
	int nb_goats <- 2;

	// Create the animals once, when the simulation starts
	init {
		create cow number: nb_cows;
		create sheep number: nb_sheep;
		create goat number: nb_goats;
	}
}

// A brown cow, drawn as a square
species cow {
	// Side length of the cow's square
	float size <- 3.0;
	// Colour used to draw the cow (an earthy brown, because GAMA's #brown looks red)
	rgb color <- rgb(139, 90, 43);

	// Draws the cow as a brown square with a thin black outline
	aspect default {
		draw square(size) color: color border: #black;
	}
}

// A black sheep, drawn as a circle
species sheep {
	// Diameter of the sheep's circle
	float size <- 3.0;
	// Colour used to draw the sheep
	rgb color <- #black;

	// Draws the sheep as a black circle with a thin black outline (circle() takes a radius, so half the diameter)
	aspect default {
		draw circle(size / 2) color: color border: #black;
	}
}

// A yellow goat, drawn as a triangle
species goat {
	// Side length of the goat's triangle
	float size <- 3.0;
	// Colour used to draw the goat
	rgb color <- #yellow;

	// Draws the goat as a yellow triangle with a thin black outline
	aspect default {
		draw triangle(size) color: color border: #black;
	}
}

// GUI experiment that shows the farm animals on a map
experiment farm type: gui {
	output {
		// Map display of the farm on a pale green background
		display farm_map background: rgb(220, 240, 200) {
			species cow aspect: default;
			species sheep aspect: default;
			species goat aspect: default;
		}
	}
}
