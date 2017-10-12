import java.util.Collections;
tree[] trees;
String[] genExport;
ArrayList<tree> treeRank = new ArrayList<tree>();
int cullSize = 1;
int cullGen = 0;
int nextCull = cullGen;
int mutationChance = 10; // (1/mutationChance)
float size = 3;
boolean isPaused = false;
int generation = 0;
int r = 64;

void setup(){
  textSize(14);
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
  frameRate(r);
  int totalGen = generation + frameCount;
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
  text("Generations: " + totalGen + ", size: " + nf(size, 0, 2), 10, height-10);
  text("FPS: " + nf(frameRate, 0, 1) + "/" + r, 3, 20);
  
  drawGen();
  treeRank();
  treeCull();
  checkPaused();
  noFill();
}

void drawGen(){
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
      textSize(20);
    } else {
      textSize(14);
    }
    text(trees[i].fitness + ":" + treeRank.indexOf(trees[i]), 0, -600);
    text(trees[i].dna.length(), 0, -550);
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
      treeRank.get(g).cull(treeRank.get(int(random(cullSize-1))).dna);
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
    fill(255);
    pushMatrix();
    translate(width/2, height/2);
    rect(-50, -20, 50, 20);
    fill(0);
    textAlign(CENTER, CENTER);
    text("Paused", 0, 0);
    popMatrix();
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
  trees = new tree[3];
  genExport = new String[trees.length];
  for (int i=0; i<trees.length; i = i+1){
    trees[i] = new tree();
    treeRank.add(trees[i]);
  }
}

void toolBar(){
  float x1 = width/18;
  line(0, 8*height/9, width/3, 8*height/9);
  line(0, 17*height/18, width/3, 17*height/18);
  
  line(2*x1, 5*height/6, 2*x1, 17*height/18);
  line(4*x1, 5*height/6, 4*x1, 17*height/18);
  line(5*width/18, 5*height/6, 5*width/18, 17*height/18);
  line(width/3, 5*height/6, width/3, 17*height/18);
  
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
}