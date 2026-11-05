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

// A brown cow, drawn as a square, that moves with a correlated random walk
species cow skills: [moving] {
	// Speed of the cow, in m/s (2 m per step with GAMA's default step of 1 s)
	float speed <- 2.0;
	// Total range of the cow's change of direction per step, in degrees (up to 45 to each side)
	float turning_amplitude <- 90.0;
	// Side length of the cow's square
	float size <- 3.0;
	// Colour used to draw the cow (an earthy brown, because GAMA's #brown looks red)
	rgb color <- rgb(139, 90, 43);

	// Each step, the cow moves forward and picks a new direction close to its current one
	reflex walk {
		do wander amplitude: turning_amplitude;
	}

	// Draws the cow as a brown square with a thin black outline
	aspect default {
		draw square(size) color: color border: #black;
	}
}

// A black sheep, drawn as a circle, that walks straight south
species sheep skills: [moving] {
	// Speed of the sheep, in m/s (1 m per step with GAMA's default step of 1 s)
	float speed <- 1.0;
	// Direction of the sheep's walk, in degrees (0 = east, 90 = south)
	float south_heading <- 90.0;
	// Diameter of the sheep's circle
	float size <- 3.0;
	// Colour used to draw the sheep
	rgb color <- #black;

	// Each step, the sheep moves one step south; it stays at the south border once it gets there
	reflex walk {
		do move heading: south_heading;
	}

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
