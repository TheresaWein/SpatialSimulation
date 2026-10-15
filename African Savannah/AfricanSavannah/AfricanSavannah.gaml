/**
* Name: AfricanSavannah
* Based on the internal empty template. 
* Author: Theresa Wein
* Tags: 
*/

//Global Section: valid for the whole simulation
model AfricanSavannah

global {
	int my_variable <- 1;
	float my_speed <- 3.0;

	init { //initialisation, executed once in the beginning
		create lions number: 20 { //creates agent (lions) 
			speed <- 3.0;
		}

		create zebras number: 20 { //creates agent (zebras)
			speed <- 3.0;
		}

	}

}

//Agents Section: definitions of the agents behaiviour
species lions skills: [moving] { //defines skills for the lions (move)
	reflex move { //reflex (function)=rules for the behaiviour
		do wander; //wander randomly
	}

	reflex kill_zebras { //reflex (function) -> remove zebras
		ask zebras at_distance 3 {
			do die;
		}

	}

	aspect default { //defines the look of the species
		draw circle(3) color: #orange;
	}

}

species zebras skills: [moving] { //defines skills for the zebras (move)
	reflex move {
		do wander;
	}

	aspect default {
		draw triangle(2) color: #grey;
	}

}


//CA: Celluar Automaton Section
grid grassland { //creates a grid
	float biomass <- rnd(10.0); //random number between 0 and 10 -> "Start Raster" with different values
	reflex grow {
		biomass <- biomass + 0.1; //grass grows with each execution
		
	}

	aspect default { //color of the grass
		draw shape color: rgb(0, 50 + int(biomass * 20), 0); //translates values into a color (RGB)-> only the green value is changing
	}

}

//Simulation
experiment main_experiment type: gui {//defines the experiment/simulation with graphical user interface (gui)
	parameter "my Variable" var: my_variable; //changeable Paramters in the gui (not used so far)
	parameter "my speed" var: my_speed;
	output {
		display map {//creates a map
			species grassland aspect: default;
			species lions aspect: default;
			species zebras aspect: default;
		}

	}

}

