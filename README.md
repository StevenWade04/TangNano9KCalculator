A simple calculator implemented as a finite state machine on a Tang Nano 9K.

Repo contains both parts, PCB design and Verilog code.

PCB:

Simple design in KICAD for through-hole soldering. A parts.txt file describes the correct components to be used for assembly.
The PCB is simple, and has several flaws. 

The through-holes for the headers are smaller than commonly available retail parts. 
The board has aesthetic issues.
The use of pull up resistors is likely not necessary with the Tang Nano 9k, and is simply a holdover from early work on the project.

Ideally these issues would be revised in a later iteration, potentially also making the board smaller, thus cheaper to print.

VERILOG:

Written with the intention of building and programming using LushayLabs IDE. In that enviroment the verilog code successfully is built and uploaded to the tang nano board It has not been tested directly using with Yosys's OSS Cad Suite, which the LushayLabs IDE directly uses.
