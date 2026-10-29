/**
 * African Savannah: a spatial model with lions hunting zebras on a growing grassland.
 */
model Assignment_3

global {
	// Number of lions created at the start of the simulation
	int nb_lions <- 20;
	// Number of zebras created at the start of the simulation
	int nb_zebras <- 20;
	// Energy each lion has at the start of the simulation (adjustable with a slider)
	float lion_start_energy <- 50.0;
	// List of the ages of all living lions, in time steps (filled later)
	list<int> lion_ages <- [];

	// Create the lions and zebras when the simulation starts
	init {
		create lion number: nb_lions;
		create zebra number: nb_zebras;
		// Add the age of every lion to the list
		loop l over: lion {
			add l.age to: lion_ages;
		}
	}

	// Each step, remove the previous age values and add the current age of every living lion.
	// The global reflex runs before the lions' reflexes, so the list shows the ages at the start
	// of the step (one step behind the lions' age, and lions that starve in this step are still in it)
	reflex update_lion_ages {
		remove all: lion_ages from: lion_ages;
		loop l over: lion {
			add l.age to: lion_ages;
		}

		// Report the number of values in the list and their minimum, mean (rounded to 1 decimal) and maximum
		// in the console; all values are 0 when the list is empty (no lions left)
		int nb_ages <- length(lion_ages);
		int age_min <- empty(lion_ages) ? 0 : min(lion_ages);
		float age_mean <- empty(lion_ages) ? 0.0 : mean(lion_ages) with_precision 1;
		int age_max <- empty(lion_ages) ? 0 : max(lion_ages);
		write "Step " + cycle + ": " + nb_ages + " lions, age min " + age_min + ", mean " + age_mean + ", max " + age_max;
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
	// Current energy of the lion
	float energy <- lion_start_energy;
	// Energy gained from eating one zebra
	float energy_per_zebra <- 5.0;
	// Energy lost per step when moving
	float energy_loss <- 0.1;
	// Age of the lion, in time steps (random start age between 0 and 60)
	int age <- rnd(0, 60);

	// Each step, the lion gets one time step older
	reflex grow_older {
		age <- age + 1;
	}

	// Each step, the lion moves forward, turning slightly at random, and loses energy
	reflex wander {
		do wander amplitude: wander_amplitude;
		energy <- energy - energy_loss;
	}

	// Each step, the lion kills one zebra it touches (circles around both animals overlap)
	// and gains energy from eating it
	reflex hunt {
		zebra prey <- (zebra where (each distance_to self <= (size + each.size) / 2)) closest_to self; //list of all zebra agents, checks the distance between zebra and lion (self); size = size of lion; each.size = size of the zebra -> they overlap or touch
		if (prey != nil) {// if there is a zebra (prey) it can be hunt
			ask prey {//prey= closest zebra to hunt; defined l. 45
				do die;
			}
			energy <- energy + energy_per_zebra;
		}
	}

	// The lion dies when it has no energy left (checked after hunting, so a last catch can save it)
	reflex starve when: energy <= 0 {
		do die;
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
	// Grass eaten per step, in kg
	float consumption <- 2.0;

	// Each step, the zebra moves forward, turning slightly at random
	reflex wander {
		do wander amplitude: wander_amplitude;
	}

	// Each step, the zebra eats grass from the cell it is standing on (never more than is there)
	reflex eat {
		grass_cell my_cell <- grass_cell(location); //finds the cell the zebra is standing on -> local variable
		float eaten <- min(consumption, my_cell.biomass); //comparison of min values -> the zebra can not eat more than the cell contains -> biomass can not get negative
		my_cell.biomass <- my_cell.biomass - eaten; //biomass in the cell - 2kg per timestep (or less)
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
	// Maximum grass biomass a cell can hold, in kg
	float max_biomass <- 10.0;
	// Cell colour, from dry brown (0 kg) to dark green (10 kg or more)
	rgb color <- biomass_color();

	// Each step, the grass grows by a fixed amount up to the maximum and the cell colour is updated
	reflex grow {
		biomass <- min(biomass + growth_rate, max_biomass);//biomass can not grow above the max_biomass (10kg)
		color <- biomass_color();//color change
	}

	// Returns the colour for the current biomass, using pale tones so the animals stay visible:
	// light sand-brown -> pale yellow -> very light green -> sage green
	rgb biomass_color {
		list<rgb> scale <- [rgb(205, 185, 150), rgb(240, 230, 170), rgb(200, 230, 180), rgb(140, 185, 120)];
		// Position of the biomass on the colour scale (0 to 3)
		float pos <- min(biomass, 10.0) / 10.0 * (length(scale) - 1);//everthing above 10 get represented with the same color
		// Lower colour of the two colours to blend between
		int i <- min(int(pos), length(scale) - 2);
		// Share of the upper colour (0 to 1)
		float t <- pos - i;
		rgb c1 <- scale[i];
		rgb c2 <- scale[i + 1];
		return rgb(int(c1.red + (c2.red - c1.red) * t), int(c1.green + (c2.green - c1.green) * t), int(c1.blue + (c2.blue - c1.blue) * t));
	}
}

// GUI experiment that shows the grassland, lions and zebras on a map, with zebra and lion counters and the lions' average energy
experiment savannah type: gui {
	// Slider to choose the lions' start energy before the simulation starts
	parameter "Lion start energy" var: lion_start_energy min: 5.0 max: 60.0 step: 1.0 category: "Lions";

	output {
		// Shows how many zebras are still alive
		monitor "Number of zebras" value: length(zebra);
		// Shows how many lions are still alive
		monitor "Number of lions" value: length(lion);
		// Shows the average energy of the living lions (0 when no lion is left)
		monitor "Average lion energy" value: empty(lion) ? 0.0 : mean(lion collect each.energy);
		// Shows how many values the list of lion ages contains
		monitor "Number of ages" value: length(lion_ages);
		// Shows the lowest age in the list (0 when the list is empty)
		monitor "Min age" value: empty(lion_ages) ? 0 : min(lion_ages);
		// Shows the mean age in the list, rounded to 1 decimal (0 when the list is empty)
		monitor "Mean age" value: empty(lion_ages) ? 0.0 : mean(lion_ages) with_precision 1;
		// Shows the highest age in the list (0 when the list is empty)
		monitor "Max age" value: empty(lion_ages) ? 0 : max(lion_ages);

		// Map display of the savannah
		display savannah_map {
			// Grassland drawn first so the animals appear on top
			grid grass_cell;
			species zebra aspect: default;
			species lion aspect: default;
		}
	}
}
