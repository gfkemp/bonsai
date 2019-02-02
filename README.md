# DNA bonsai simulation
My goal with this project was to create a simulation of growth using genetic algorithms. I was inspired by seeing 'evolution simulation' [videos](https://www.youtube.com/watch?v=GOFws_hhZs8 "Carykh's popular series") [on](https://www.youtube.com/watch?v=z9ptOeByLA4 "Evolving AI Lab's soft robots") [youtube](https://www.youtube.com/watch?v=ZpW_ojpmTWk "Zongyi Yang's Tree Evolving Simulation") and set out to replicate this for 2 dimensional trees.
## Finished Project
![img broken](https://github.com/gfkemp/bonsai/blob/master/finalscreen.png "finished project")
## Process
>A typical genetic algorithm requires:
> 1. a genetic representation of the solution domain,
> 2. a fitness function to evaluate the solution domain.

[-wikipedia](https://en.wikipedia.org/wiki/Genetic_algorithm#Methodology)
### DNA
Each tree's DNA is stored as a string. The construction rules are as follows:

*S → "00-99"S*

*S → "b"S*

*S → "le"S*

an example section:
>b056394le

The leading "b" indicates the start of the branch, the current location is stored until the branch ends. Three pairs of numbers represent 3 stems, "05", "63", "94", the first number is the stem length and the second number is the angle it grows (the number representing being an index in the following array `{ PI, -PI/5, -3*PI/10, -2*PI/5, PI/2, 2*PI/5, 3*PI/10, PI/5, 0 }`). The "le" tells the program where to draw a leaf - this also indicates the end of the branch.

The DNA mutates through deletion, addition, translation, chunk replication and chunk deletion.

**Deletion** A single codon is removed.

**Addition** A single codon is added.

**Translation** A single codon is replaced by another random codon.

**Chunk replication** A sequence of codons are duplicated.

**Chunk delection** A sequence of codons are removed.

If any mutation makes the tree impossible to construct it is replaced by a newly generated tree.

### Fitness Function
After many prototypes the fitness function that the finished project uses scores only the leaves which remain inside the light blue box and do not intersect one another. 'Wilted' leaves gain the tree a large penalty and are displayed as brown and transparent.

The first function I designed awarded more points the higher the leaves got - while this did produce attractive trees the chunk replication mutation would quickly cause them to explode even further upwards. It took a long time experimenting to realise that I was continually designing these functions that would highly value complex and massive trees - not something that was too friendly for the fps. 

This was when I came upon the idea of limiting the space the trees were encouraged to grow - and arriving on the name of bonsai simulator. My hope is that given enough time this system would be able to find the most efficient way to pack leaves into the box, but my experience tells me that it would need the ability to handle a much larger population size.
