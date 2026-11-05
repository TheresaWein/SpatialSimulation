/**
 * Farm: a simulation model of a farm with cows, sheep and goats.
 */
model Assignment_4

global {
	// Shape of the world: a square of 25 m x 25 m, small enough to show the action neighbourhoods at true scale
	geometry shape <- square(25);
	// Half the thickness of the arrow lines of the action neighbourhoods, in m (display only)
	float arrow_half_width <- 0.04;
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
	float size <- 0.5;
	// Colour used to draw the cow (an earthy brown, because GAMA's #brown looks red)
	rgb color <- rgb(139, 90, 43);

	// Each step, the cow moves forward and picks a new direction close to its current one
	reflex walk {
		do wander amplitude: turning_amplitude;
	}

	// Draws the cow's action neighbourhood and the cow as a brown square with a thin black outline
	aspect default {
		// Distance the cow covers in the next step, in m (true scale)
		float reach <- speed * step;
		// Action neighbourhood: the transparent cone the cow can reach in the next step, cut off at the map edge
		geometry neighbourhood <- (cone(heading - turning_amplitude / 2, heading + turning_amplitude / 2) intersection circle(reach)) intersection world.shape;
		draw neighbourhood color: rgb(color, 0.4);
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
	float size <- 0.5;
	// Colour used to draw the sheep
	rgb color <- #black;

	// Each step, the sheep moves south; the last step is shortened so it ends exactly on the south border and stays there
	reflex walk {
		do move heading: south_heading speed: min(speed, (world.shape.height - location.y) / step);
	}

	// Draws the sheep's action neighbourhood and the sheep as a black circle with a thin black outline (circle() takes a radius, so half the diameter)
	aspect default {
		// Distance the sheep covers in the next step, in m (true scale; never past the south border)
		float reach <- min(speed * step, world.shape.height - location.y);
		// Action neighbourhood: a transparent arrow south; no arrow once the sheep is on the border
		if (reach > 0) {
			// End of the arrow, where the sheep will be after the next step
			point tip <- location + {reach * cos(south_heading), reach * sin(south_heading)};
			draw line([location, tip]) + arrow_half_width color: rgb(color, 0.75);
			draw line([location, tip]) color: rgb(color, 0.75) end_arrow: reach / 3;
		}
		draw circle(size / 2) color: color border: #black;
	}
}

// A yellow goat, drawn as a triangle, that walks slowly towards the origin
species goat skills: [moving] {
	// Speed of the goat, in m/s (0.5 m per step with GAMA's default step of 1 s)
	float speed <- 0.5;
	// Location the goat walks to (the origin of the world)
	point target_location <- {0, 0};
	// Side length of the goat's triangle
	float size <- 0.5;
	// Colour used to draw the goat
	rgb color <- #yellow;

	// Each step, the goat moves straight towards its target; it stays there once it arrives
	reflex walk {
		do goto target: target_location;
	}

	// Draws the goat's action neighbourhood and the goat as a yellow triangle with a thin black outline
	aspect default {
		// Action neighbourhood: a transparent arrow towards the target (true scale); no arrow once the goat has arrived
		if (location != target_location) {
			// Distance the goat covers in the next step, in m (never past the target)
			float reach <- min(speed * step, location distance_to target_location);
			// Direction from the goat to its target, in degrees
			float direction <- location towards target_location;
			// End of the arrow, where the goat will be after the next step
			point tip <- location + {reach * cos(direction), reach * sin(direction)};
			draw line([location, tip]) + arrow_half_width color: rgb(color, 0.75);
			draw line([location, tip]) color: rgb(color, 0.75) end_arrow: reach / 3;
		}
		draw triangle(size) color: color border: #black;
	}
}

// GUI experiment that shows the farm animals on a map
experiment farm type: gui {
	output {
		// Map display of the farm on a soft green background (dark enough for the yellow goat arrows to stand out)
		display farm_map background: rgb(180, 210, 160) {
			species cow aspect: default;
			species sheep aspect: default;
			species goat aspect: default;
		}
	}
}
