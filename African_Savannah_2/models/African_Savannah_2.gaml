/**
 * African Savannah: a first spatial model with lions moving at random.
 */
model African_Savannah_2

global {
	// Number of lions created at the start of the simulation
	int nb_lions <- 20;
	// Number of zebras created at the start of the simulation
	int nb_zebras <- 20;

	// Create the lions and zebras when the simulation starts
	init {
		create lion number: nb_lions;
		create zebra number: nb_zebras;
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

// A zebra that walks around the savannah at random
species zebra skills: [moving] {
	// Diameter of the circle around the zebra's triangle (measured like the lions)
	float size <- 2.0;
	// Colour used to draw the zebra
	rgb color <- #grey;
	// Maximum change of direction per step, in degrees (same value as the lions)
	float wander_amplitude <- 25.0;

	// Each step, the zebra moves forward, turning slightly at random
	reflex wander {
		do wander amplitude: wander_amplitude;
	}

	// Draws the zebra as a grey triangle pointing up; triangle() takes the side length,
	// and an equilateral triangle in a circle of diameter d has side d / 2 * sqrt(3)
	aspect default {
		draw triangle(size / 2 * sqrt(3)) color: color;
	}
}

// GUI experiment that shows the lions on a map
experiment savannah type: gui {
	output {
		// Map display of the savannah
		display savannah_map {
			species zebra aspect: default;
			species lion aspect: default;
		}
	}
}
