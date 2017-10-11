class leaf{
  float leafX, leafY, leafScore;
  boolean isWilted = false;
  color rotten = color(100, 45, 10, 150);
  leaf(){
  }
  
  void drawLeaf(){
    leafScore = 0;
    if (leafX < -100 || leafX > 100 || leafY >= 0 || leafY < -450){
      leafScore = -1000; 
    } else {
      leafScore = 100;
    }
    pushStyle();
    noStroke();
    fill(0, constrain(int(-leafY), 0, 255), 0);
    if (isWilted == true){
      leafScore = -100;
      fill(rotten);
    }
    ellipse(leafX, leafY, size*2, size*2);
    popStyle();
  }
}