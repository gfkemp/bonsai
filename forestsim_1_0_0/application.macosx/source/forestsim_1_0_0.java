import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Collections; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class forestsim_1_0_0 extends PApplet {


tree[] trees;
String[] genExport;
ArrayList<tree> treeRank = new ArrayList<tree>();
int cullSize = 1;
int cullGen = 0;
int nextCull = cullGen;
int mutationChance = 10; // (1/mutationChance)
int size = 1;
boolean isPaused = false;
int generation = 0;
int r = 64;

public void setup(){
  strokeJoin(BEVEL);
  rectMode(CORNERS);
  frameRate(r);
   
  trees = new tree[3];
  genExport = new String[trees.length];
  for (int i=0; i<trees.length; i = i+1){
    trees[i] = new tree();
    treeRank.add(trees[i]);
  }
}

public void draw(){
  frameRate(r);
  int totalGen = generation + frameCount;
  background(200);
  line(0, 5*height/6, width, 5*height/6);
  fill(0);
  textAlign(LEFT);
  text("Generations: " + totalGen + ", until cull: " + nextCull, 3, 20);
  text("FPS: " + nf(frameRate, 0, 1) + "/" + r, 3, 35);
  
  drawGen();
  treeRank();
  treeCull();
  checkPaused();
}

public void drawGen(){
  for (int i=0; i<trees.length; i = i+1)
  {
    pushMatrix();
    pushStyle();
    translate((i+1) * width/(trees.length+1), 5*height/6);
    pushStyle();
    noStroke();
    if (i == trees.length/2){
      fill(250, 100);
      rect(-100, -450, 100, 0); 
    }
    popStyle();
    textAlign(CENTER);
    if (treeRank.indexOf(trees[i]) == 0){
      fill(255);
    } else {
      fill(0);
    }
    text(trees[i].fitness + ":" + treeRank.indexOf(trees[i]), 0, -600);
    trees[i].drawTree(); 
    popMatrix();
    popStyle();
  }
}

public void treeRank(){
  
  java.util.Collections.sort(treeRank);
}

public void treeCull(){
  if (nextCull == 0){
    for (int g = trees.length-cullSize; g < trees.length; g++){
      treeRank.get(g).cull(treeRank.get(PApplet.parseInt(random(cullSize-1))).dna);
    }
    nextCull = cullGen;
  } else {
    nextCull--; 
  }
  for (int i = 0; i < trees.length; i++){
    trees[i].mutate();
  }
}

public void checkPaused(){
  if (isPaused == true){
    fill(255);
    pushMatrix();
    translate(width/2, height/2);
    rect(0-75, 0-100, 150, 200);
    fill(0);
    translate(0, -50);
    textAlign(CENTER, CENTER);
    text("Pause menu", 0, -10);
    text("(S)AVE", 0, 10);
    text("(L)OAD", 0, 25);
    text(" FPS+ (>)", 0, 40);
    text(" FPS- (<)", 0, 55);
    popMatrix();
    noLoop();
  } else {
    loop();
  }
}

public void keyPressed(){
  if (key == ' '){
    if (isPaused == true){
      isPaused = false;
      loop();
    } else {
      isPaused = true;
    }
  }
  if (key == ',' || key == '<'){
    if (r > 1){
      r = r/2;
    }
    } else if (key == '.' || key == '>'){
      if (r < 500){
        r = r*2;
      }
    }
  if (key == '-' || key == '_'){
    if (size > 1){
      size = size/2;
    }
    } else if (key == '+' || key == '='){
      if (size < 20){
        size = size*2;
      }
    }
  if (key == 's' || key == 'S'){
    for (int i = 0; i < trees.length; i++){
      genExport[i] = trees[i].dna;
    }
    genExport = append(genExport, str(frameCount));
    saveStrings("currentGen.txt", genExport);
    println("SAVED");
  }
  if (key == 'l' || key == 'L'){
    String[] genImport = loadStrings("currentGen.txt");
    generation = PApplet.parseInt(genImport[genImport.length-1]);
    genImport = shorten(genImport);
    trees = new tree[genImport.length];
    treeRank.clear();
    genExport = new String[trees.length];
    for (int i=0; i<trees.length; i = i+1){
      trees[i] = new tree();
      trees[i].dna = genImport[i];
      treeRank.add(trees[i]);
    }
    println("LOADED");
  }
}
class leaf{
  float leafX, leafY, leafScore;
  boolean isWilted = false;
  int rotten = color(100, 45, 10, 150);
  leaf(){
  }
  
  public void drawLeaf(){
    leafScore = 0;
    if (leafX < -100 || leafX > 100 || leafY >= 0 || leafY < -450){
      leafScore = -1000; 
    } else {
      leafScore = 100;
    }
    pushStyle();
    noStroke();
    fill(0, constrain(PApplet.parseInt(-leafY), 0, 255), 0);
    if (isWilted == true){
      leafScore = -100;
      fill(rotten);
    }
    ellipse(leafX, leafY, size*2, size*2);
    popStyle();
  }
}
class tree implements Comparable<tree> {
  float[] angles = { -0, -PI/5, -3*PI/10, -2*PI/5, PI/2, 2*PI/5, 3*PI/10, PI/5, 0 };
  float stemLen, leafScore; 
  int fitness, leafTotal = 0, leafIndex = 0, branchCount = 0;
  leaf[] leaves;
  String dna = "";
  public int compareTo(tree compareTrees){
    int compareFitness = ((tree) compareTrees).fitness;
    return compareFitness - this.fitness;
  }

  tree(){
    for (int i = 0; i < 50; i++){
      float seed = random(20);
      if (seed <= 8) {
        dna = dna + nf(PApplet.parseInt(random(0, 99)), 2);
      } else if (seed > 6 && seed <= 14){
        dna = dna + "b";
      } else if (seed > 14 && seed <= 19){
        dna = dna + "le";
      } else if (seed > 19) {
        dna = dna + "e";
      }
    }
  }
  
  public void drawTree(){
    float stroke = 5;
    strokeWeight(stroke);
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
      value = PApplet.parseInt(dna.charAt(i)-48); //48 is removed from the char in the for loop below as decimals 1-9 are 49-57 after char-int conversion, likewise: b = 98, e = 101, l = 108
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
          stroke(100, 45, 10);
          line(xyPos[stemCount], xyPos[stemCount+1], xyPos[stemCount+2], xyPos[stemCount+3]);
          stemCount+=2;
          if (stroke > 1) {
            stroke = stroke - 0.1f;
          }
          strokeWeight(stroke);
          angle = 0;
          len = 0;
        }
      } else if (value == 50){ //if char = b push transformation to create branch
        pushCount = append(pushCount, stemCount);
        branchCount++;
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
  
  public void drawLeaves(){
    for (int i = 0; i < leaves.length; i++){
       leaves[i].drawLeaf(); 
    }
  }
  
  public void sunshine(){
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
  
  public void fitnessCalc(float stems, float leaf, float branches){
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
      fitness = fitness + PApplet.parseInt(leaves[i].leafScore);
    }
    fitness = fitness-PApplet.parseInt(0.1f*stems+1/branches+1);
    //fitness = int((stemLen + leafTotal)*100/dna.length());
  }
  
  public void cull(String newDna){
    dna = newDna;
    float chance = random(1.05f); //creates completely random trees [[[remove on prod]]]
    if (chance > 1){
      dna = "";
      for (int i = 0; i < 50; i++){
        float seed = random(20);
        if (seed <= 8) {
          dna = dna + nf(PApplet.parseInt(random(0, 99)), 2);
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
  
  public void mutate(){
    float coinFlip = random(mutationChance);
      if (coinFlip <= 1){
        int compNum = 0;
        String[] dnaComponents = new String[dna.length()];
        
        for (int i = 0; i < dna.length();){
          int value = PApplet.parseInt(dna.charAt(i)-48);
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
          coinFlip = random(3.2f);
          if (coinFlip <= 1){ //deletion
            dnaComponents[PApplet.parseInt(random(compNum))] = "";
            //println("deletion");
          } else if(coinFlip > 1 && coinFlip <= 2){ //addition
            int start = PApplet.parseInt(random(compNum));
            float seed = random(20);
            if (seed <= 8) {
              dnaComponents = splice(dnaComponents, nf(PApplet.parseInt(random(0, 99)), 2), start); 
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
            dnaComponents[PApplet.parseInt(random(compNum))] = nf(PApplet.parseInt(random(0, 99)), 2);
            //println("translation");
          } else if(coinFlip > 3 && coinFlip <= 3.1f){ //chunk replication
            int start = PApplet.parseInt(random(compNum));
            int end = PApplet.parseInt(random(start, compNum));
            String[] repArray = new String[end - start];
            arrayCopy(dnaComponents, start, repArray, 0, end - start);
            dnaComponents = splice(dnaComponents, repArray, start);
            compNum = compNum + (end-start);
            //println("chunk replication " + (end-start));
          } else if(coinFlip > 3.1f && coinFlip <= 3.2f){ //chunk deletion
            int start = PApplet.parseInt(random(compNum));
            int end = PApplet.parseInt(random(start, compNum));
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
  public void settings() {  size(1400, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "forestsim_1_0_0" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
