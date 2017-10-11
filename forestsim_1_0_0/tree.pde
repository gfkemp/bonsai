class tree implements Comparable<tree> {
  float[] angles = { -0, -PI/5, -3*PI/10, -2*PI/5, PI/2, 2*PI/5, 3*PI/10, PI/5, 0 };
  float stemLen, leafScore; 
  int fitness, leafTotal = 0, leafIndex = 0, branchCount = 0;
  leaf[] leaves;
  String dna = "";
  int compareTo(tree compareTrees){
    int compareFitness = ((tree) compareTrees).fitness;
    return compareFitness - this.fitness;
  }

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
  }
  
  void drawTree(){
    leafTotal = 0;
    for (int i = 0; i < dna.length(); i++){
      if (dna.charAt(i) == 'l'){
        leafTotal++; 
      }
    }
    leaves = new leaf[leafTotal];
    for (int i = 0; i < leaves.length; i++){
      leaves[i] = new leaf();
    }
    float[] xyPos = {0, 0};
    int[] pushCount = {0};
    int stemCount = 0;
    stemLen = 0;
    leafIndex = 0;
    fitness = 0;
    branchCount = 0;
    int value = 0, len = 0, angle = 0;
    for (int i = 0; i < dna.length(); i++){
      value = int(dna.charAt(i)-48); //48 is removed from the char in the for loop below as decimals 1-9 are 49-57 after char-int conversion, likewise: b = 98, e = 101, l = 108
      if (value < 10){
        if (len == 0){
          len = size*value;
        } else if (len > 0){
          angle = value;
          //drawLine(len, angle, stemCount);
          int rotateBy = angle-1;
          if (rotateBy < 0){
             rotateBy = 5;
          }
          if (angles[rotateBy] >= 0){
            xyPos = append(xyPos, xyPos[stemCount]+cos(angles[rotateBy])*len);
            xyPos = append(xyPos, xyPos[stemCount+1]+sin(angles[rotateBy])*-len); 
          } else {
            xyPos = append(xyPos, xyPos[stemCount]+cos(angles[rotateBy])*-len);
            xyPos = append(xyPos, xyPos[stemCount+1]+sin(angles[rotateBy])*len);
          }
          line(xyPos[stemCount], xyPos[stemCount+1], xyPos[stemCount+2], xyPos[stemCount+3]);
          stemCount+=2;
          angle = 0;
          len = 0;
        }
      } else if (value == 50){ //if char = b push transformation to create branch
        pushCount = append(pushCount, stemCount);
      } else if (value == 53){ //if char = e pop transformation to end branch
        try{
        if (pushCount[1] >= 0){
          xyPos = append(xyPos, xyPos[pushCount[pushCount.length-1]]);
          xyPos = append(xyPos, xyPos[pushCount[pushCount.length-1]+1]);
          stemCount+=2;
          pushCount = shorten(pushCount);
          }
        } catch (ArrayIndexOutOfBoundsException exception) {}
      } else if (value == 60){
        leaves[leafIndex].leafX = xyPos[stemCount];
        leaves[leafIndex].leafY = xyPos[stemCount+1];
        leafIndex++;
      }
    }
    sunshine();
    drawLeaves();
    fitnessCalc(stemCount, leafIndex, branchCount);
  }
  
  void drawLeaves(){
    for (int i = 0; i < leaves.length; i++){
       leaves[i].drawLeaf(); 
    }
  }
  
  void sunshine(){
    for (int g = 0; g < leaves.length; g++){
      for (int i = 0; i < leaves.length; i++){
        if (dist(leaves[g].leafX, leaves[g].leafY, leaves[i].leafX, leaves[i].leafY) <= size*2 && i != g){
          leaves[g].isWilted = true;
        }
      }
    }
    
    /*resetMatrix();
    for (float i = 0; i < width; i+=2){
      for (float f = 0; f < height; i+=2){
        for (int g = 0; g < leaves.length; g++){
          if (dist(i, f, leaves[g].leafX, leaves[g].leafY) <= size*2){
           f = height;
           leaves[g].leafScore++;
          }
        }
      }
    }*/
  }
  
  void fitnessCalc(float stems, float leaf, float branches){
    /*int sGreaterThanBandI = 1;
    if (stems >= leaves) {
      sGreaterThanBandI = 2;
    }
    if (dna.length() <= 10){
      fitness = -10;
    } else if (dna.length() <= 2){
      fitness = -100;
    } else {
      fitness = int((leaves*sGreaterThanBandI)-(dna.length()/10));
    } */
    for (int i = 0; i < leaves.length; i++){
      fitness = fitness + int(leaves[i].leafScore);
    }
    //fitness = int((stemLen + leafTotal)*100/dna.length());
  }
  
  void cull(String newDna){
    dna = newDna;
    float chance = random(1.05); //creates completely random trees [[[remove on prod]]]
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
    //leaves = new leaf[leafTotal];
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