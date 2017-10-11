class tree implements Comparable<tree> {
  float[] angles = { -PI/2, -3*PI/10, -PI/5, -PI/10, 0, PI/10, PI/5, 3*PI/10, PI/2 };
  float stemLen, leafScore; 
  int fitness, leafTotal = 0, leafIndex = 0, branchCount = 0;
  String dna = "";
  int compareTo(tree compareTrees){
    int compareFitness = ((tree) compareTrees).fitness;
    return compareFitness - this.fitness;
  }
  leaf[] leaves;

  tree(){
    for (int i = 0; i < 50; i++){
      float seed = random(20);
      if (seed <= 8) {
        dna = dna + nf(int(random(0, 99)), 2);
      } else if (seed > 6 && seed <= 14){
        dna = dna + "b";
      } else if (seed > 14 && seed <= 19){
        dna = dna + "le";
      } else if (seed > 19) {
        dna = dna + "e";
      }
    }
    for (int i = 0; i < dna.length(); i++){
      if (dna.charAt(i) == 'l'){
        leafTotal++;
      }
    }
    println(leafTotal, dna.length());
    leaves = new leaf[leafTotal];
  }
  
  void drawTree(){
    stemLen = 0;
    leafIndex = 0;
    fitness = 0;
    branchCount = 0;
    float pushPop = 0;
    float pos = 0;
    int value = 0, len = 0, angle = 0;
    for (int i = 0; i < dna.length(); i++){
      value = int(dna.charAt(i)-48); //48 is removed from the char in the for loop below as decimals 1-9 are 49-57 after char-int conversion, likewise: b = 98, e = 101, l = 108
      if (value < 10){
        if (len == 0){
          len = value;
        } else if (len > 0){
          angle = value;
          drawLine(len, angle);
          
          angle = 0;
          len = 0;
        }
      } else if (value == 50){ //if char = b push transformation to create branch
        if (pushPop < 31){
          pushMatrix();
          pushPop++;
          branchCount++;
        }
      } else if (value == 53){ //if char = e pop transformation to end branch
        if (pushPop > 0){
          popMatrix();
          pushPop--;
        }
      } else if (value == 60){
        //leaves[leafIndex] = new leaf();
        //leaves[leafIndex].drawLeaf();
        if (branchCount >= leafIndex){
          ellipse(0, 0, 2, 2);
          leafIndex++;
        }
      }
      pos = pos + 10;
    }
    for (int i = 0; i < pushPop; i++){ //pops pushMatrices that havent yet been popped
      popMatrix();
    }
    fitnessCalc(stemLen, leafIndex, branchCount);
    //println(leafIndex, leafTotal);
  }
  
  void drawLine(float len, int angle){
    if (angle > 0){
      rotate(angles[angle-1]);
    }
    line(0, 0, 0, -len);
    translate(0, -len);
    stemLen++;
  } 
  
  void fitnessCalc(float stems, float leaves, float branches){
    int sGreaterThanBandI = 1;
    if (stems >= branches + leaves) {
      sGreaterThanBandI = 2;
    }
    if (dna.length() <= 10){
      fitness = -10;
    } else if (dna.length() <= 2){
      fitness = -100;
    } else {
      fitness = int((leaves*sGreaterThanBandI)-(dna.length()/10));
    } 
    //fitness = int((stemLen + leafTotal)*100/dna.length());
  }
  
  void cull(String newDna){
    dna = newDna;
    float chance = 1; //creates completely random trees [[[remove on prod]]]
    if (chance > 1){
      dna = "";
      for (int i = 0; i < 50; i++){
        float seed = random(20);
        if (seed <= 8) {
          dna = dna + nf(int(random(0, 99)), 2);
        } else if (seed > 6 && seed <= 14){
          dna = dna + "b";
        } else if (seed > 14 && seed <= 19){
          dna = dna + "le";
        } else if (seed > 19) {
          dna = dna + "e";
        }
      }
    }
    leafTotal = 0;
    for (int i = 0; i < dna.length(); i++){
      if (dna.charAt(i) == 'l'){
        leafTotal++;
      }
    }
    //println(dna, leafTotal, dna.length());
    leaves = new leaf[leafTotal];
  }
  
  void mutate(){
    float coinFlip = random(mutationChance);
      if (coinFlip <= 1){
        int compNum = 0;
        String[] dnaComponents = new String[dna.length()];
        
        for (int i = 0; i < dna.length();){
          int value = int(dna.charAt(i)-48);
          if (value < 10){
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
        /*for (int i = 0; i < dnaComponents.length; i++){
          println(dnaComponents[i]);
        }*/
        if (compNum >= 1){
          coinFlip = random(3.2);
          if (coinFlip <= 1){ //deletion
            dnaComponents[int(random(compNum))] = "";
            //println("deletion");
          } else if(coinFlip > 1 && coinFlip <= 2){ //addition
            int start = int(random(compNum));
            float seed = random(20);
            if (seed <= 8) {
              dnaComponents = splice(dnaComponents, nf(int(random(0, 99)), 2), start); 
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
            dnaComponents[int(random(compNum))] = nf(int(random(0, 99)), 2);
            //println("translation");
          } else if(coinFlip > 3 && coinFlip <= 3.1){ //chunk replication
            int start = int(random(compNum));
            int end = int(random(start, compNum));
            String[] repArray = new String[end - start];
            arrayCopy(dnaComponents, start, repArray, 0, end - start);
            dnaComponents = splice(dnaComponents, repArray, start);
            compNum = compNum + (end-start);
            //println("chunk replication " + (end-start));
          } else if(coinFlip > 3.1 && coinFlip <= 3.2){ //chunk deletion
            int start = int(random(compNum));
            int end = int(random(start, compNum));
            for (int i = start; i < end; i++){
              dnaComponents[i] = "";
            }
            //println("chunk deletion");
          }
        }
        dna = "";
        for (int i = 0; i < compNum; i++){
          dna = dna + dnaComponents[i];
        }
    }
  }
}