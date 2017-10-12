import java.util.Collections;
import org.gicentre.utils.stat.*;
XYChart fitnessChart, fpsChart, dnaChart;
float[] generationXaxis = {0}, fitnessYaxis = {0}, fpsYaxis = {0}, dnaYaxis = {0};
tree[] trees;
String[] genExport;
ArrayList<tree> treeRank = new ArrayList<tree>();
int cullSize = 1, cullGen = 0, nextCull = cullGen, generation = 0, extraframes = 0, r = 64, totalGen = 0;
int mutationChance = 10; // (1/mutationChance)
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
  fitnessChart.setPointSize(0);
  fitnessChart.setLineWidth(3);
  
  fpsChart = new XYChart(this);
  fpsChart.setData(generationXaxis, fitnessYaxis);
  fpsChart.showXAxis(true); 
  fpsChart.showYAxis(true); 
  fpsChart.setMinY(0);
  fpsChart.setAxisColour(color(0));
  fpsChart.setPointColour(color(255, 255, 255, 1));
  fpsChart.setPointSize(0);
  fpsChart.setLineWidth(3);
  
  dnaChart = new XYChart(this);
  dnaChart.setData(generationXaxis, dnaYaxis);
  dnaChart.showXAxis(true); 
  dnaChart.showYAxis(true); 
  dnaChart.setMinY(0);
  dnaChart.setAxisColour(color(0));
  dnaChart.setPointColour(color(255, 255, 255, 1));
  dnaChart.setPointSize(0);
  dnaChart.setLineWidth(3);
  
  textSize(14);
  roboto = createFont("Roboto-Light", 14);
  textFont(roboto);
  strokeJoin(BEVEL);
  rectMode(CORNERS);
  frameRate(r);
  size(1400, 800); 
  trees = new tree[3];
  genExport = new String[trees.length];
  for (int i=0; i<trees.length; i = i+1){
    trees[i] = new tree();
    treeRank.add(trees[i]);
  }
}

void draw(){
  textSize(14);
  frameRate(r);
  int frames = frameCount - extraframes;
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
  if(dnaPressed == true){
    displayDNA();
  } 
  noFill();
  drawGraph();
}

void drawGen(){
  for (int i=0; i<trees.length; i = i+1)
  {
    pushMatrix();
    pushStyle();
    translate((i+1) * width/(trees.length+1), 5*height/6);
    pushStyle();
    noStroke();
    fill(250, 100);
    rect(-100, -450, 100, 0); 
    if (mouseX >= -100 && mouseX <= 100 && mouseY >= -450){
      text("DNA LOL", 0, 0); 
    }
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
    trees[i].drawTree(); 
    popMatrix();
    popStyle();
  }
}

void treeRank(){
  java.util.Collections.sort(treeRank);
}

void treeCull(){
  if (nextCull == 0){
    for (int g = trees.length-cullSize; g < trees.length; g++){
      treeRank.get(g).reproduce(treeRank.get(int(random(cullSize-1))).dna);
    }
    nextCull = cullGen;
  } else {
    nextCull--; 
  }
  for (int i = 0; i < trees.length; i++){
    trees[i].mutate();
  }
}

void checkPaused(){
  if (isPaused == true){
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
    noLoop();
  } else {
    loop();
  }
}

void keyPressed(){
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
    size = size/1.5;
  }
}

void sizeUp(){
  if (size < 20){
     size = size + 0.5;
  }
}

void savetxt(){
  for (int i = 0; i < trees.length; i++){
      genExport[i] = trees[i].dna;
    }
  genExport = append(genExport, str(size));
  genExport = append(genExport, str(frameCount));
  saveStrings("currentGen.txt", genExport);
  println("SAVED");
}

void load(){
  String[] genImport = loadStrings("currentGen.txt");
  generation = int(genImport[genImport.length-1]);
  
  varReset();
  
  genImport = shorten(genImport);
  
  size = int(genImport[genImport.length-1]);
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

void newFile(){
  for (int i=0; i<trees.length; i = i+1){
    trees[i].cull();
  }
  varReset();
}

void toolBar(){
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
    } else {
      dnaPressed = false;
    }
  }
  if (mouseX <= 8*x1 && mouseX >= 6*x1 && mouseY <= 17*height/18 && mouseY >= 8*height/9){
    if (graphMode == "Fitness"){
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

void displayDNA(){
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
  if (totalGen%(int(2000/frameRate)) == 0){
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

void varReset(){
  extraframes = frameCount;
  generationXaxis = new float[]{generation};
  fitnessYaxis = new float[]{0};
  fpsYaxis = new float[]{0};
  dnaYaxis = new float[]{0};
  fitnessChart.setMinX(generation);
  fpsChart.setMinX(generation);
  dnaChart.setMinX(generation);
}