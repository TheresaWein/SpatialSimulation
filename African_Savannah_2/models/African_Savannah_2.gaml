/**
 * African Savannah: a first spatial model with lions moving at random.
 */
model African_Savannah_2

global {
	// Number of lions created at the start of the simulation
	int nb_lions <- 20;

	// Create the lions when the simulation starts
	init {
		create lion number: nb_lions;
	}
}

// A lion that walks around the savannah at random
species lion skills: [moving] {
	// Diameter of the lion's circle
	float size <- 3.0;
	// Colour used to draw the lion
	rgb color <- #orange;
	// Maximum change of direction per step, in degrees (smaller = smoother path)
	float wander_amplitude <- 25.0;

	// Each step, the lion moves forward, turning slightly at random
	reflex wander {
		do wander amplitude: wander_amplitude;
	}

	// Draws the lion as an orange circle (circle() takes a radius, so half the diameter)
	aspect default {
		draw circle(size / 2) color: color;
	}
}

// GUI experiment that shows the lions on a map
experiment savannah type: gui {
	// Lets you change the number of lions before you run the model
	parameter "Number of lions" var: nb_lions min: 1 max: 200;

	output {
		// Map display of the savannah
		display savannah_map {
			species lion aspect: default;
		}
	}
}
