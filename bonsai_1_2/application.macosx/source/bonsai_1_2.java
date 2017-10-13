import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Collections; 
import org.gicentre.utils.stat.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class bonsai_1_2 extends PApplet {



XYChart fitnessChart, fpsChart, dnaChart;
float[] generationXaxis = {0}, fitnessYaxis = {0}, fpsYaxis = {0}, dnaYaxis = {0};
tree[] trees;
String[] genExport;
ArrayList<tree> treeRank = new ArrayList<tree>();
int cullSize = 1, cullGen = 0, nextCull = cullGen, generation = 0, extraframes = 0, r = 64, totalGen = 0;
int mutationChance = 10; // 1/mutationChance is the actual chance
float size = 3;
boolean isPaused = false, dnaPressed = false;
PFont roboto;
String displayedDNA;
String graphMode = "Fitness";

public void setup(){
  fitnessChart = new XYChart(this);
  fitnessChart.setData(generationXaxis, fpsYaxis);
  fitnessChart.showXAxis(true); 
  fitnessChart.showYAxis(true); 
  fitnessChart.setMinY(0);
  fitnessChart.setAxisColour(color(0));
  fitnessChart.setPointColour(color(255, 255, 255, 1));
  fitnessChart.setPointSize(0.1f);
  fitnessChart.setLineWidth(1);
  
  fpsChart = new XYChart(this);
  fpsChart.setData(generationXaxis, fitnessYaxis);
  fpsChart.showXAxis(true); 
  fpsChart.showYAxis(true); 
  fpsChart.setMinY(0);
  fpsChart.setAxisColour(color(0));
  fpsChart.setPointColour(color(255, 255, 255, 1));
  fpsChart.setPointSize(0.1f);
  fpsChart.setLineWidth(1);
  
  dnaChart = new XYChart(this);
  dnaChart.setData(generationXaxis, dnaYaxis);
  dnaChart.showXAxis(true); 
  dnaChart.showYAxis(true); 
  dnaChart.setMinY(0);
  dnaChart.setAxisColour(color(0));
  dnaChart.setPointColour(color(255, 255, 255, 1));
  dnaChart.setPointSize(0.1f);
  dnaChart.setLineWidth(1);
  
  textSize(14);
  roboto = createFont("Roboto-Light", 14);
  textFont(roboto);
  strokeJoin(BEVEL);
  rectMode(CORNERS);
  frameRate(r);
   
  trees = new tree[3]; //more trees are possible (and make the population larger and simulation better...) but drastically affect framerate; this version supports up to 5 before the UI breaks down but can handle more if you remove // on line 100
  genExport = new String[trees.length];
  for (int i=0; i<trees.length; i = i+1){
    trees[i] = new tree();
    treeRank.add(trees[i]);
  }
}

public void draw(){
  textSize(14);
  frameRate(r);
  
  int frames = frameCount - extraframes; //work out how many frames since beginning/reset
  totalGen = generation + frames;
  
  background(200);
  
  line(0, 5*height/6, width, 5*height/6);
  
  pushStyle();
  noStroke();
  fill(200, 233, 245);
  rect(0, 5*height/6, width, 0);
  popStyle();
  
  toolBar();
  
  fill(0);
  textAlign(LEFT);
  text("Generations: " + totalGen + ", Size: " + nf(size, 0, 2), 10, height-15);
  text("FPS: " + nf(frameRate, 0, 1) + "/" + r, 3, 20);
  
  drawGen();
  treeRank();
  treeCull();
  checkPaused();
  drawGraph();
}

public void drawGen(){ //cycles through trees[] object array and draws them to screen + displays stats
  for (int i=0; i<trees.length; i = i+1)
  {
    pushMatrix();
    pushStyle();
    translate((i+1) * width/(trees.length+1), 5*height/6); //centers the tree to its specific origin point
    
    ///* REMOVE FIRST 2 // if attempting simulation with more than 6 trees
    pushStyle();
    noStroke();
    fill(250, 100);
    rect(-100, -450, 100, 0);
    popStyle();
    
    rectMode(CENTER);
    fill(250);   
    rect(0, -562, 230, 110);
    textAlign(RIGHT, CENTER);
    fill(0);
    textSize(20);
    text("Fitness: \nRank: \nDNA length: ", 25, -565);
    textAlign(LEFT, CENTER);
    text(" " + trees[i].fitness + "\n " + (treeRank.indexOf(trees[i])+1) + "\n " + trees[i].dna.length(), 25, -565);
    //*/
    trees[i].drawTree(); 
    popMatrix();
    popStyle();
  }
}

public void treeRank(){
  java.util.Collections.sort(treeRank); //necessary to facilitate culling by weakest fitness
}

public void treeCull(){ 
  if (nextCull == 0){
    for (int g = trees.length-cullSize; g < trees.length; g++){
      treeRank.get(g).reproduce(treeRank.get(PApplet.parseInt(random(cullSize-1))).dna); //gets the weakest x (cullSize) number of trees and replaces them with the dna of one the top x (cullSize-1) randomly
    }
    nextCull = cullGen; //this was put in place to allow delaying culling to once every few generations but was not put into the UI for simplicity (and bc it's a waste of FPS)
  } else {
    nextCull--; 
  }
  for (int i = 0; i < trees.length; i++){
    trees[i].mutate(); //after culling, allow new trees a chance to mutate
  }
}

public void checkPaused(){
  if (isPaused == true){ //pauses draw through noLoop()
    pushStyle();
    fill(255);
    pushMatrix();
    translate(width/2, height/2);
    rect(-50, -20, 50, 20);
    fill(0);
    textAlign(CENTER, CENTER);
    text("Paused", 0, 0);
    popMatrix();
    popStyle();
    if(dnaPressed == true){ //displayDNA also functions as a pause button
      displayDNA();
    } 
    noLoop();
  } else {
    loop();
  }
}

public void keyPressed(){ //hotkeys left in from earlier version
  if (key == ' '){
    pause();
  }
  if (key == ',' || key == '<'){
    fpsDown();
  } else if (key == '.' || key == '>'){
    fpsUp();
  }
  if (key == '-' || key == '_'){
    sizeDown();
  } else if (key == '+' || key == '='){
    sizeUp();
  }
  if (key == 's' || key == 'S'){
    savetxt();
  }
  if (key == 'l' || key == 'L'){
    load();
  }
}

public void pause(){
  if (isPaused == true){
    isPaused = false;
    loop();
  } else {
    isPaused = true;
  }
}

public void fpsDown(){
  if (r > 1){
    r = r/2;
  }
}

public void fpsUp(){
  if (r < 500){
    r = r*2;
  }
}

public void sizeDown(){
  if (size > 1){
    size = size - 0.5f;
  }
}

public void sizeUp(){
  if (size < 20){
     size = size + 0.5f;
  }
}

public void savetxt(){ //saves all trees dna + generation number to "currentGen.txt" ((should look into making a variable filename?))
  for (int i = 0; i < trees.length; i++){
      genExport[i] = trees[i].dna;
    }
  genExport = append(genExport, str(size));
  genExport = append(genExport, str(frameCount));
  saveStrings("currentGen.txt", genExport);
  println("SAVED");
}

public void load(){ //loads currentGen.txt
  String[] genImport = loadStrings("currentGen.txt"); 
  generation = PApplet.parseInt(genImport[genImport.length-1]);
  
  varReset(generation);
  
  genImport = shorten(genImport); //removes the int for generation length from string array
  
  size = PApplet.parseInt(genImport[genImport.length-1]);
  genImport = shorten(genImport); //removes the int for size from string array
  
  trees = new tree[genImport.length]; //creates new trees by length of array and populates them with the dna
  treeRank.clear();
  genExport = new String[trees.length];
  for (int i=0; i<trees.length; i = i+1){
    trees[i] = new tree();
    trees[i].dna = genImport[i];
    treeRank.add(trees[i]);
  }
  println("LOADED");
}

public void newFile(){ //kills trees and sets generation to 0
  for (int i=0; i<trees.length; i = i+1){
    trees[i].cull();
  }
  varReset(0);
}

public void toolBar(){ //very ugly code for a very ugly UI
  float x1 = width/18;
  line(0, 8*height/9, 4*width/9, 8*height/9);
  line(0, 17*height/18, 4*width/9, 17*height/18);
  
  line(2*x1, 5*height/6, 2*x1, 17*height/18);
  line(4*x1, 5*height/6, 4*x1, 17*height/18);
  line(5*width/18, 5*height/6, 5*width/18, 17*height/18);
  line(width/3, 5*height/6, width/3, 17*height/18);
  line(4*width/9, 5*height/6, 4*width/9, 17*height/18);
  
  textAlign(CENTER, CENTER);
  if (mouseX <= 2*x1 && mouseX >= 0 && mouseY <= 8*height/9 && mouseY >= 5*height/6){
    fill(255);
  } else {
    fill(0);
  }
  text("PAUSE", width/18, 31*height/36);
  if (mouseX <= 2*x1 && mouseX >= 0 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    fill(255);
  } else {
    fill(0);
  }
  text("NEW", width/18, 33*height/36);
  if (mouseX <= 4*x1 && mouseX >= 2*x1 && mouseY <= 8*height/9 && mouseY >= 5*height/6){
    fill(255);
  } else {
    fill(0);
  }
  text("SAVE", 3*width/18, 31*height/36);
  if (mouseX <= 4*x1 && mouseX >= 2*x1 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    fill(255);
  } else {
    fill(0);
  }
  text("LOAD SAMPLE", 3*width/18, 33*height/36);
  if (mouseX <= 5*x1 && mouseX >= 4*x1 && mouseY <= 8*height/9 && mouseY >= 5*height/6){
    fill(255);
  } else {
    fill(0);
  }
  text("FPS+", 4.5f*width/18, 31*height/36);
  if (mouseX <= 5*x1 && mouseX >= 4*x1 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    fill(255);
  } else {
    fill(0);
  }
  text("SIZE+", 4.5f*width/18, 33*height/36);
  if (mouseX <= 6*x1 && mouseX >= 5*x1 && mouseY <= 8*height/9 && mouseY >= 5*height/6){
    fill(255);
  } else {
    fill(0);
  }
  text("FPS-", 5.5f*width/18, 31*height/36);
  if (mouseX <= 6*x1 && mouseX >= 5*x1 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    fill(255);
  } else {
    fill(0);
  }
  text("SIZE-", 5.5f*width/18, 33*height/36);
  if (mouseX <= 8*x1 && mouseX >= 6*x1 && mouseY <= 8*height/9 && mouseY >= 5*height/6){
    fill(255);
  } else if(dnaPressed == true){
    fill(255);
  } else {
    fill(0);
  }
  text("Display DNA", 7*x1, 31*height/36);
  if (mouseX <= 8*x1 && mouseX >= 6*x1 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    fill(255);
  } else {
    fill(0);
  }
  text("Graph: " + graphMode, 7*x1, 33*height/36);
}

public void mousePressed(){
  float x1 = width/18;
  if (mouseX <= 2*x1 && mouseX >= 0 && mouseY <= 8*height/9 && mouseY >= 5*height/6){
    pause();
  }
  if (mouseX <= 2*x1 && mouseX >= 0 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    newFile();
  } 
  if (mouseX <= 4*x1 && mouseX >= 2*x1 && mouseY <= 8*height/9 && mouseY >= 5*height/6){
    savetxt();
  }
  if (mouseX <= 4*x1 && mouseX >= 2*x1 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    load();
  }
  if (mouseX <= 5*x1 && mouseX >= 4*x1 && mouseY <= 8*height/9 && mouseY >= 5*height/6){
    fpsUp();
  }
  if (mouseX <= 5*x1 && mouseX >= 4*x1 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    sizeUp();
  }
  if (mouseX <= 6*x1 && mouseX >= 5*x1 && mouseY <= 8*height/9 && mouseY >= 5*height/6){
    fpsDown();
  }
  if (mouseX <= 6*x1 && mouseX >= 5*x1 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    sizeDown();
  }
  if (mouseX <= 8*x1 && mouseX >= 6*x1 && mouseY <= 8*height/9 && mouseY >= 5*height/6){
    if (dnaPressed == false){
      dnaPressed = true;
      displayedDNA = trees[0].dna;
      pause();
    } else {
      dnaPressed = false;
      pause();
    }
  }
  if (mouseX <= 8*x1 && mouseX >= 6*x1 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    if (graphMode == "Fitness"){ //allows cycling through graph options
      graphMode = "FPS";
    } else if (graphMode == "FPS"){
      graphMode = "DNA";
    } else if (graphMode == "DNA"){
      graphMode = "OFF";
    } else if (graphMode == "OFF"){
      graphMode = "Fitness";
    }
  }
}

public void displayDNA(){ //shows the dna of the leftmost tree on screen
  pushStyle();
  fill(230);
  rect(3*width/8, 10, width - 10, (5*height/6)-10); 
  fill(0);
  textSize(20);
  textLeading(20);
  text(displayedDNA, 3*width/8+3, 10, width - 13, (5*height/6)-10);
  popStyle();
}

public void drawGraph(){
  fill(255);
  rect((4*width/9),5*height/6,width,height);
  if (totalGen%50 == 0){ //only records a value every 50 ticks to save fps
    generationXaxis = append(generationXaxis, totalGen);
    fitnessYaxis = append(fitnessYaxis, treeRank.get(0).fitness);
    fpsYaxis = append(fpsYaxis, frameRate);
    dnaYaxis = append(dnaYaxis, treeRank.get(0).dna.length());
  }
  fill(0);
  textSize(9);
  
  if (graphMode == "Fitness"){
    fitnessChart.setData(generationXaxis, fitnessYaxis);
    fitnessChart.draw((4*width/9)+10,5*height/6,5*width/9-10,(height/6));
  } else if (graphMode == "FPS"){
    fpsChart.setData(generationXaxis, fpsYaxis);
    fpsChart.draw((4*width/9)+10,5*height/6,5*width/9-10,(height/6));
  } else if (graphMode == "DNA"){
    dnaChart.setData(generationXaxis, dnaYaxis);
    dnaChart.draw((4*width/9)+10,5*height/6,5*width/9-10,(height/6));
  }
}

public void varReset(int startGen){ //reset for the generation count and x axes
  generation = startGen;
  extraframes = frameCount; //variable that helps work out extra frames since reset
  generationXaxis = new float[]{startGen}; //clears X axis values
  fitnessYaxis = new float[]{0}; //clears all Y axes values
  fpsYaxis = new float[]{0};
  dnaYaxis = new float[]{0};
  fitnessChart.setMinX(startGen); //sets minimum x value to 0 or generations from a loaded file 
  fpsChart.setMinX(startGen);
  dnaChart.setMinX(startGen);
}
class leaf{
  float leafX, leafY, leafScore;
  boolean isWilted = false;
  int rotten = color(100, 45, 10, 150);
  leaf(){
  }
  
  public void drawLeaf(){ //decides whether to award tree points and then draws leaf
    leafScore = 0;
    if (leafX < -100 || leafX > 100 || leafY >= 0 || leafY < -450){
      leafScore = -1000; //very low score to dissuade plants from growing outside the boxes
    } else {
      leafScore = 100;
    }
    pushStyle();
    noStroke();
    fill(0, constrain(PApplet.parseInt(-leafY), 0, 255), 0); //changes greenness based on y value (aesthetic only ;_;)
    if (isWilted == true){ //checks whether leaf is overlapping another and docks score if so
      leafScore = 0;
      fill(rotten);
    }
    ellipse(leafX, leafY, size*2, size*2);
    popStyle();
  }
}
class tree implements Comparable<tree> {
  float[] angles = { PI, -PI/5, -3*PI/10, -2*PI/5, PI/2, 2*PI/5, 3*PI/10, PI/5, 0 }; //values for working out how rotated a stem will be
  float stemLen, leafScore; 
  int fitness, leafTotal = 0, leafIndex = 0, branchCount = 0;
  leaf[] leaves;
  String dna = "";
  public int compareTo(tree compareTrees){ //comparison logic from processing forum, cant find the link I adapted it from :/
    int compareFitness = ((tree) compareTrees).fitness;
    return compareFitness - this.fitness;
  }

  tree(){ //generates random DNA between 50 and 100 characters
    for (int i = 0; i < random(50, 100); i++){
      float seed = random(20);
      if (seed <= 8) { //4 in 10 chance of stem
        dna = dna + nf(PApplet.parseInt(random(0, 99)), 2);
      } else if (seed > 8 && seed <= 14){ //3 in 10 chance of starting a branch
        dna = dna + "b";
      } else if (seed > 14 && seed <= 19){ //2.5 in 10 chance of placing a leaf and ending the branch
        dna = dna + "le";
      } else if (seed > 19) { //0.5 in 10 chance of ending a branch without a leaf
        dna = dna + "e";
      }
    }
  }
  
  public void drawTree(){
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
      value = PApplet.parseInt(dna.charAt(i)-48); //48 is removed from the char in the for loop below as decimals 1-9 are 49-57 after char-int conversion, likewise: b = 98, e = 101, l = 108
      if (value < 10){ //0-9 are less than 10!
        if (len == 0){ //first pass takes leftmost digit of 'XX'
          len = PApplet.parseInt(size*value);
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
            stroke = stroke - 0.1f; //aesthetic
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
  
  public void drawLeaves(){
    for (int i = 0; i < leaves.length; i++){
       leaves[i].drawLeaf(); //loops through leaf array to place them all
    }
  }
  
  public void score(){
    for (int g = 0; g < leaves.length; g++){
      for (int i = 0; i < leaves.length; i++){
        if (dist(leaves[g].leafX, leaves[g].leafY, leaves[i].leafX, leaves[i].leafY) <= size*2 && i != g){
          leaves[g].isWilted = true; //loops through leaves to check if they are intersecting and makes them wilt
        }
      }
    }
  }
  
  public void fitnessCalc(float stems, float leaf, float branches){
    for (int i = 0; i < leaves.length; i++){
      fitness = fitness + PApplet.parseInt(leaves[i].leafScore); //totals leafScore
    }
    fitness = fitness-PApplet.parseInt(0.1f*stems+1/branches+1); //attempts to prevent stem length from become extreme by taking away a calculation of stems/branches (not sure this achieves anything but i like to think it does
  }
  
  public void reproduce(String newDna){
    dna = newDna;
    float chance = random(1.05f); 
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
  
  public void cull(){ //wipes a trees dna and starts from scratch 
    dna = "";
    for (int i = 0; i < 50; i++){
      float seed = random(20);
      if (seed <= 8) {
        dna = dna + nf(PApplet.parseInt(random(0, 99)), 2);
      } else if (seed > 8 && seed <= 14){
        dna = dna + "b";
      } else if (seed > 14 && seed <= 19){
        dna = dna + "le";
      } else if (seed > 19) {
        dna = dna + "e";
      }
    }
  }
  
  public void mutate(){ //mutates trees dna (attempt to emulate biological mutation)
    float coinFlip = random(mutationChance);
      if (coinFlip <= 1){
        int compNum = 0;
        String[] dnaComponents = new String[dna.length()];
        
        for (int i = 0; i < dna.length();){ //converts dna into an array of components 
          int value = PApplet.parseInt(dna.charAt(i)-48);
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
          coinFlip = random(3.2f); //mutations occur on a 10:10:10:1:1 ratio with the simplest (1 component) mutations occuring the most and chunk mutations being less common
          if (coinFlip <= 1){ //deletion
            dnaComponents[PApplet.parseInt(random(compNum))] = ""; //takes a random component and replaces it with an empty string
            //println("deletion");
          } else if(coinFlip > 1 && coinFlip <= 2){ //addition
            int start = PApplet.parseInt(random(compNum));
            float seed = random(20);
            if (seed <= 8) {
              dnaComponents = splice(dnaComponents, nf(PApplet.parseInt(random(0, 99)), 2), start); //adds a random component at a random point
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
            dnaComponents[PApplet.parseInt(random(compNum))] = nf(PApplet.parseInt(random(0, 99)), 2); //converts a random component into a random 'xx'
            //println("translation");
          } else if(coinFlip > 3 && coinFlip <= 3.1f){ //chunk replication
            int start = PApplet.parseInt(random(compNum)); //assigns beginning and end of chunk at random
            int end = PApplet.parseInt(random(start, compNum)); 
            String[] repArray = new String[end - start];
            arrayCopy(dnaComponents, start, repArray, 0, end - start); //assigns the values from start to end to a new array
            dnaComponents = splice(dnaComponents, repArray, PApplet.parseInt(random(compNum))); //places that new array somewhere in the old one
            compNum = compNum + (end-start);
            //println("chunk replication " + (end-start));
          } else if(coinFlip > 3.1f && coinFlip <= 3.2f){ //chunk deletion
            int start = PApplet.parseInt(random(compNum));
            int end = PApplet.parseInt(random(start, compNum)); //assigns beginning and end of chunk at random
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
  public void settings() {  size(1400, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "bonsai_1_2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
