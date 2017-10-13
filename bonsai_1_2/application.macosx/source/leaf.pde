class leaf{
  float leafX, leafY, leafScore;
  boolean isWilted = false;
  color rotten = color(100, 45, 10, 150);
  leaf(){
  }
  
  void drawLeaf(){ //decides whether to award tree points and then draws leaf
    leafScore = 0;
    if (leafX < -100 || leafX > 100 || leafY >= 0 || leafY < -450){
      leafScore = -1000; //very low score to dissuade plants from growing outside the boxes
    } else {
      leafScore = 100;
    }
    pushStyle();
    noStroke();
    fill(0, constrain(int(-leafY), 0, 255), 0); //changes greenness based on y value (aesthetic only ;_;)
    if (isWilted == true){ //checks whether leaf is overlapping another and docks score if so
      leafScore = 0;
      fill(rotten);
    }
    ellipse(leafX, leafY, size*2, size*2);
    popStyle();
  }
}