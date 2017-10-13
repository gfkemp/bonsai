import java.util.Collections;
import org.gicentre.utils.stat.*;
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

void setup(){
  fitnessChart = new XYChart(this);
  fitnessChart.setData(generationXaxis, fpsYaxis);
  fitnessChart.showXAxis(true); 
  fitnessChart.showYAxis(true); 
  fitnessChart.setMinY(0);
  fitnessChart.setAxisColour(color(0));
  fitnessChart.setPointColour(color(255, 255, 255, 1));
  fitnessChart.setPointSize(0.1);
  fitnessChart.setLineWidth(1);
  
  fpsChart = new XYChart(this);
  fpsChart.setData(generationXaxis, fitnessYaxis);
  fpsChart.showXAxis(true); 
  fpsChart.showYAxis(true); 
  fpsChart.setMinY(0);
  fpsChart.setAxisColour(color(0));
  fpsChart.setPointColour(color(255, 255, 255, 1));
  fpsChart.setPointSize(0.1);
  fpsChart.setLineWidth(1);
  
  dnaChart = new XYChart(this);
  dnaChart.setData(generationXaxis, dnaYaxis);
  dnaChart.showXAxis(true); 
  dnaChart.showYAxis(true); 
  dnaChart.setMinY(0);
  dnaChart.setAxisColour(color(0));
  dnaChart.setPointColour(color(255, 255, 255, 1));
  dnaChart.setPointSize(0.1);
  dnaChart.setLineWidth(1);
  
  textSize(14);
  roboto = createFont("Roboto-Light", 14);
  textFont(roboto);
  strokeJoin(BEVEL);
  rectMode(CORNERS);
  frameRate(r);
  size(1400, 800); 
  trees = new tree[3]; //more trees are possible (and make the population larger and simulation better...) but drastically affect framerate; this version supports up to 5 before the UI breaks down but can handle more if you remove // on line 100
  genExport = new String[trees.length];
  for (int i=0; i<trees.length; i = i+1){
    trees[i] = new tree();
    treeRank.add(trees[i]);
  }
}

void draw(){
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

void drawGen(){ //cycles through trees[] object array and draws them to screen + displays stats
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

void treeRank(){
  java.util.Collections.sort(treeRank); //necessary to facilitate culling by weakest fitness
}

void treeCull(){ 
  if (nextCull == 0){
    for (int g = trees.length-cullSize; g < trees.length; g++){
      treeRank.get(g).reproduce(treeRank.get(int(random(cullSize-1))).dna); //gets the weakest x (cullSize) number of trees and replaces them with the dna of one the top x (cullSize-1) randomly
    }
    nextCull = cullGen; //this was put in place to allow delaying culling to once every few generations but was not put into the UI for simplicity (and bc it's a waste of FPS)
  } else {
    nextCull--; 
  }
  for (int i = 0; i < trees.length; i++){
    trees[i].mutate(); //after culling, allow new trees a chance to mutate
  }
}

void checkPaused(){
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

void keyPressed(){ //hotkeys left in from earlier version
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

void pause(){
  if (isPaused == true){
    isPaused = false;
    loop();
  } else {
    isPaused = true;
  }
}

void fpsDown(){
  if (r > 1){
    r = r/2;
  }
}

void fpsUp(){
  if (r < 500){
    r = r*2;
  }
}

void sizeDown(){
  if (size > 1){
    size = size - 0.5;
  }
}

void sizeUp(){
  if (size < 20){
     size = size + 0.5;
  }
}

void savetxt(){ //saves all trees dna + generation number to "currentGen.txt" ((should look into making a variable filename?))
  for (int i = 0; i < trees.length; i++){
      genExport[i] = trees[i].dna;
    }
  genExport = append(genExport, str(size));
  genExport = append(genExport, str(frameCount));
  saveStrings("currentGen.txt", genExport);
  println("SAVED");
}

void load(){ //loads currentGen.txt
  String[] genImport = loadStrings("currentGen.txt"); 
  generation = int(genImport[genImport.length-1]);
  
  varReset(generation);
  
  genImport = shorten(genImport); //removes the int for generation length from string array
  
  size = int(genImport[genImport.length-1]);
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

void newFile(){ //kills trees and sets generation to 0
  for (int i=0; i<trees.length; i = i+1){
    trees[i].cull();
  }
  varReset(0);
}

void toolBar(){ //very ugly code for a very ugly UI
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
  text("FPS+", 4.5*width/18, 31*height/36);
  if (mouseX <= 5*x1 && mouseX >= 4*x1 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    fill(255);
  } else {
    fill(0);
  }
  text("SIZE+", 4.5*width/18, 33*height/36);
  if (mouseX <= 6*x1 && mouseX >= 5*x1 && mouseY <= 8*height/9 && mouseY >= 5*height/6){
    fill(255);
  } else {
    fill(0);
  }
  text("FPS-", 5.5*width/18, 31*height/36);
  if (mouseX <= 6*x1 && mouseX >= 5*x1 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    fill(255);
  } else {
    fill(0);
  }
  text("SIZE-", 5.5*width/18, 33*height/36);
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

void mousePressed(){
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

void displayDNA(){ //shows the dna of the leftmost tree on screen
  pushStyle();
  fill(230);
  rect(3*width/8, 10, width - 10, (5*height/6)-10); 
  fill(0);
  textSize(20);
  textLeading(20);
  text(displayedDNA, 3*width/8+3, 10, width - 13, (5*height/6)-10);
  popStyle();
}

void drawGraph(){
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

void varReset(int startGen){ //reset for the generation count and x axes
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