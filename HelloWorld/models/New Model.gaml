/**
* Name: NewModel
* Based on the internal empty template. 
* Author: weint
* Tags: 
*/


//Global Section
model mymodel

global{ 
int my_variable <-1;
float my_speed <- 3.0;
init{
create my_agents number:5 {
	speed <-3.0 ;
}
}
}

//Agents Section
species my_agents skills:[moving]{
reflex move{
do wander;
}
aspect default{
draw triangle(5) color: #blue ;
}
}


//Simulation
experiment main_experiment type:gui{
parameter "my Variable" var: my_variable;
parameter "my speed" var: my_speed;
output {
display map {
species my_agents aspect:default;
}
}
}

/* Insert your model definition here */

