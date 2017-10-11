import java.util.Collections;
tree[] trees;
String[] genExport;
ArrayList<tree> treeRank = new ArrayList<tree>();
int cullSize = 1;
int cullGen = 0;
int nextCull = cullGen;
int mutationChance = 10; // (1/mutationChance)
boolean isPaused = false;
int generation = 0;
int r = 8;

void setup(){
  frameRate(r);
  size(1900, 1080); 
  trees = new tree[2];
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
  fill(0);
  textAlign(LEFT);
  text("Generations: " + totalGen + ", until cull: " + nextCull, 3, 20);
  text("FPS: " + int(frameRate) + "/" + r, 3, 35);
  
  drawGen();
  treeRank();
  treeCull();
  checkPaused();
}

void drawGen(){
  for (int i=0; i<trees.length; i = i+1)
  {
    pushMatrix();
    pushStyle();
    translate((i+1) * width/(trees.length+1), 5*height/6);
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

void keyPressed(){
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
    generation = int(genImport[genImport.length-1]);
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