class tree implements Comparable<tree> {
  float[] angles = { PI, -PI/5, -3*PI/10, -2*PI/5, PI/2, 2*PI/5, 3*PI/10, PI/5, 0 }; //values for working out how rotated a stem will be
  float stemLen, leafScore; 
  int fitness, leafTotal = 0, leafIndex = 0, branchCount = 0;
  leaf[] leaves;
  String dna = "";
  int compareTo(tree compareTrees){ //comparison logic from processing forum, cant find the link I adapted it from :/
    int compareFitness = ((tree) compareTrees).fitness;
    return compareFitness - this.fitness;
  }

  tree(){ //generates random DNA between 50 and 100 characters
    for (int i = 0; i < random(50, 100); i++){
      float seed = random(20);
      if (seed <= 8) { //4 in 10 chance of stem
        dna = dna + nf(int(random(0, 99)), 2);
      } else if (seed > 8 && seed <= 14){ //3 in 10 chance of starting a branch
        dna = dna + "b";
      } else if (seed > 14 && seed <= 19){ //2.5 in 10 chance of placing a leaf and ending the branch
        dna = dna + "le";
      } else if (seed > 19) { //0.5 in 10 chance of ending a branch without a leaf
        dna = dna + "e";
      }
    }
  }
  
  void drawTree(){
    float stroke = 5;
    strokeWeight(stroke);
    leafTotal = 0;
    for (int i = 0; i < dna.length(); i++){ //works out total leaves in the tree
      if (dna.charAt(i) == 'l'){
        leafTotal++; 
      }
    }
    leaves = new leaf[leafTotal];
    for (int i = 0; i < leaves.length; i++){
      leaves[i] = new leaf(); //creates leafs as objects
    }
    float[] xyPos = {0, 0}; //sets origin
    int[] pushCount = {0}; //used for recording starts of branches
    int stemCount = 0;
    stemLen = 0;
    leafIndex = 0;
    fitness = 0;
    branchCount = 0;
    int value = 0, len = 0, angle = 0;
    for (int i = 0; i < dna.length(); i++){
      value = int(dna.charAt(i)-48); //48 is removed from the char in the for loop below as decimals 1-9 are 49-57 after char-int conversion, likewise: b = 98, e = 101, l = 108
      if (value < 10){ //0-9 are less than 10!
        if (len == 0){ //first pass takes leftmost digit of 'XX'
          len = int(size*value);
        } else if (len > 0){ //second pass (len has been allocated as >0) takes the rightmost digit of 'XX' 
          int rotateBy = value-1;
          if (rotateBy < 0){
             rotateBy = 4;
          }
          if (angles[rotateBy] >= 0){ //if radian value is positive
            xyPos = append(xyPos, xyPos[stemCount]+cos(angles[rotateBy])*len); //x value after rotation is cos(theta)*hypotenuse
            xyPos = append(xyPos, xyPos[stemCount+1]+sin(angles[rotateBy])*-len); //y value after rotation is sin(theta)*hypotenuse
          } else { //if radian value is negative
            xyPos = append(xyPos, xyPos[stemCount]+cos(angles[rotateBy])*-len);
            xyPos = append(xyPos, xyPos[stemCount+1]+sin(angles[rotateBy])*len);
          }
          stroke(100, 45, 10);
          strokeWeight(stroke*size/10);
          line(xyPos[stemCount], xyPos[stemCount+1], xyPos[stemCount+2], xyPos[stemCount+3]); //xyPos array has vales {x1, y1, x2, y2, x3, y3...} so the line is drawn calling the 4 values
          stemCount+=2; //moves the counter along to the next x value
          if (stroke > 1) {
            stroke = stroke - 0.1; //aesthetic
          }
          angle = 0;
          len = 0;
        }
      } else if (value == 50){ //if char = b push transformation to create branch
        pushCount = append(pushCount, stemCount); //adds current stemcount value to an array of the start points of branches (inspired by stacks)
        branchCount++;
      } else if (value == 53){ //if char = e pop transformation to end branch
        try{
        if (pushCount[1] >= 0){
          xyPos = append(xyPos, xyPos[pushCount[pushCount.length-1]]); //sets current values of xyPos to the xy of the last branch set
          xyPos = append(xyPos, xyPos[pushCount[pushCount.length-1]+1]); 
          stemCount+=2;
          pushCount = shorten(pushCount); //removes last added value to stack
          }
        } catch (ArrayIndexOutOfBoundsException exception) {}
      } else if (value == 60){ //if char = l then leaf
        leaves[leafIndex].leafX = xyPos[stemCount]; //sets x and y of current selected leaf to current xyPos values
        leaves[leafIndex].leafY = xyPos[stemCount+1];
        leafIndex++;
      }
    }
    score();
    drawLeaves();
    fitnessCalc(stemCount, leafIndex, branchCount);
  }
  
  void drawLeaves(){
    for (int i = 0; i < leaves.length; i++){
       leaves[i].drawLeaf(); //loops through leaf array to place them all
    }
  }
  
  void score(){
    for (int g = 0; g < leaves.length; g++){
      for (int i = 0; i < leaves.length; i++){
        if (dist(leaves[g].leafX, leaves[g].leafY, leaves[i].leafX, leaves[i].leafY) <= size*2 && i != g){
          leaves[g].isWilted = true; //loops through leaves to check if they are intersecting and makes them wilt
        }
      }
    }
  }
  
  void fitnessCalc(float stems, float leaf, float branches){
    for (int i = 0; i < leaves.length; i++){
      fitness = fitness + int(leaves[i].leafScore); //totals leafScore
    }
    fitness = fitness-int(0.1*stems+1/branches+1); //attempts to prevent stem length from become extreme by taking away a calculation of stems/branches (not sure this achieves anything but i like to think it does
  }
  
  void reproduce(String newDna){
    dna = newDna;
    float chance = random(1.05); 
    if (chance > 1){ //1 in 21 chance to create a completely random tree (can help to kickstart weak populations)
      cull();
    }
    /*leafTotal = 0; //remove this
    for (int i = 0; i < dna.length(); i++){
      if (dna.charAt(i) == 'l'){
        leafTotal++;
      }
    }*/
    //println(dna, leafTotal, dna.length());
    //leaves = new leaf[leafTotal];
  }
  
  void cull(){ //wipes a trees dna and starts from scratch 
    dna = "";
    for (int i = 0; i < 50; i++){
      float seed = random(20);
      if (seed <= 8) {
        dna = dna + nf(int(random(0, 99)), 2);
      } else if (seed > 8 && seed <= 14){
        dna = dna + "b";
      } else if (seed > 14 && seed <= 19){
        dna = dna + "le";
      } else if (seed > 19) {
        dna = dna + "e";
      }
    }
  }
  
  void mutate(){ //mutates trees dna (attempt to emulate biological mutation)
    float coinFlip = random(mutationChance);
      if (coinFlip <= 1){
        int compNum = 0;
        String[] dnaComponents = new String[dna.length()];
        
        for (int i = 0; i < dna.length();){ //converts dna into an array of components 
          int value = int(dna.charAt(i)-48);
          if (value < 10){         //'xx'
            dnaComponents[compNum] = str(dna.charAt(i)) + str(dna.charAt(i+1));
            i = i + 2;
          } else if (value == 50){ //b
            dnaComponents[compNum] = "b";
            i++;
          } else if (value == 60){ //l
            dnaComponents[compNum] = "le";
            i = i + 2;
          } else if (value == 53){ //e
            dnaComponents[compNum] = "e";
            i++;
          }
          compNum++;
        }
        
        if (compNum >= 1){
          coinFlip = random(3.2); //mutations occur on a 10:10:10:1:1 ratio with the simplest (1 component) mutations occuring the most and chunk mutations being less common
          if (coinFlip <= 1){ //deletion
            dnaComponents[int(random(compNum))] = ""; //takes a random component and replaces it with an empty string
            //println("deletion");
          } else if(coinFlip > 1 && coinFlip <= 2){ //addition
            int start = int(random(compNum));
            float seed = random(20);
            if (seed <= 8) {
              dnaComponents = splice(dnaComponents, nf(int(random(0, 99)), 2), start); //adds a random component at a random point
            } else if (seed > 6 && seed <= 14){
              dnaComponents = splice(dnaComponents, "b", start);
            } else if (seed > 14 && seed <= 19){
              dnaComponents = splice(dnaComponents, "le", start);
            } else if (seed > 19) {
              dnaComponents = splice(dnaComponents, "e", start);
            }
            compNum++;
            //println("addition");
          } else if(coinFlip > 2 && coinFlip <= 3){ //translation
            dnaComponents[int(random(compNum))] = nf(int(random(0, 99)), 2); //converts a random component into a random 'xx'
            //println("translation");
          } else if(coinFlip > 3 && coinFlip <= 3.1){ //chunk replication
            int start = int(random(compNum)); //assigns beginning and end of chunk at random
            int end = int(random(start, compNum)); 
            String[] repArray = new String[end - start];
            arrayCopy(dnaComponents, start, repArray, 0, end - start); //assigns the values from start to end to a new array
            dnaComponents = splice(dnaComponents, repArray, int(random(compNum))); //places that new array somewhere in the old one
            compNum = compNum + (end-start);
            //println("chunk replication " + (end-start));
          } else if(coinFlip > 3.1 && coinFlip <= 3.2){ //chunk deletion
            int start = int(random(compNum));
            int end = int(random(start, compNum)); //assigns beginning and end of chunk at random
            for (int i = start; i < end; i++){ //loops through chunk and replaces components with blank strings
              dnaComponents[i] = "";
            }
            //println("chunk deletion");
          }
        }
        dna = "";
        for (int i = 0; i < compNum; i++){ //loops through dnaComponents to rebuild DNA
          dna = dna + dnaComponents[i];
        }
    }
  }
}