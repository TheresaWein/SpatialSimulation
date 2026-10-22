/**
 * African Savannah: a spatial model with lions hunting zebras on a growing grassland.
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

	// Each step, the lion kills one zebra it touches (circles around both animals overlap)
	reflex hunt {
		zebra prey <- (zebra where (each distance_to self <= (size + each.size) / 2)) closest_to self;
		if (prey != nil) {
			ask prey {
				do die;
			}
		}
	}

	// Draws the lion as an orange circle with a thin black outline (circle() takes a radius, so half the diameter)
	aspect default {
		draw circle(size / 2) color: color border: #black;
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

	// Draws the zebra as a grey triangle pointing up with a thin black outline; triangle() takes
	// the side length, and an equilateral triangle in a circle of diameter d has side d / 2 * sqrt(3)
	aspect default {
		draw triangle(size / 2 * sqrt(3)) color: color border: #black;
	}
}

// Grassland of the savannah, modelled as a cellular automaton (1 m x 1 m cells)
grid grass_cell width: 100 height: 100 {
	// Grass biomass in the cell, in kg (random start value between 0 and 10)
	float biomass <- rnd(10.0);
	// Grass added to the cell each time step, in kg (linear growth)
	float growth_rate <- 0.1;
	// Cell colour, from dry brown (0 kg) to dark green (10 kg or more)
	rgb color <- biomass_color();

	// Each step, the grass grows by a fixed amount and the cell colour is updated
	reflex grow {
		biomass <- biomass + growth_rate;
		color <- biomass_color();
	}

	// Returns the colour for the current biomass, using pale tones so the animals stay visible:
	// light sand-brown -> pale yellow -> very light green -> sage green
	rgb biomass_color {
		list<rgb> scale <- [rgb(205, 185, 150), rgb(240, 230, 170), rgb(200, 230, 180), rgb(140, 185, 120)];
		// Position of the biomass on the colour scale (0 to 3)
		float pos <- min(biomass, 10.0) / 10.0 * (length(scale) - 1);
		// Lower colour of the two colours to blend between
		int i <- min(int(pos), length(scale) - 2);
		// Share of the upper colour (0 to 1)
		float t <- pos - i;
		rgb c1 <- scale[i];
		rgb c2 <- scale[i + 1];
		return rgb(int(c1.red + (c2.red - c1.red) * t), int(c1.green + (c2.green - c1.green) * t), int(c1.blue + (c2.blue - c1.blue) * t));
	}
}

// GUI experiment that shows the grassland, lions and zebras on a map, with a zebra counter
experiment savannah type: gui {
	output {
		// Shows how many zebras are still alive
		monitor "Number of zebras" value: length(zebra);

		// Map display of the savannah
		display savannah_map {
			// Grassland drawn first so the animals appear on top
			grid grass_cell;
			species zebra aspect: default;
			species lion aspect: default;
		}
	}
}
