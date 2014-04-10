
import processing.pdf.*;

import twitter4j.conf.*;
import twitter4j.internal.async.*;
import twitter4j.internal.org.json.*;
import twitter4j.internal.logging.*;
import twitter4j.json.*;
import twitter4j.internal.util.*;
import twitter4j.management.*;
import twitter4j.auth.*;
import twitter4j.api.*;
import twitter4j.util.*;
import twitter4j.internal.http.*;
import twitter4j.*;
import twitter4j.internal.json.*;
import java.util.List;
import java.util.Map;
import java.util.*;


// Adapte la mise en page à la longueur du texte


int h = height;
int l = 600;

int pdfH = 1145;
int pdfW = 797;


PFont font;

int interligne = 0;
int position = 0;

// Variable Logos
PImage[] myImageArray = new PImage[150];
int logoW = (l/3)*2;
int logoH = (logoW/4)*3;

float pdfLogoW = (pdfW/3)*2.3;
float pdfLogoH = (pdfLogoW/4)*3;

///////////////////////////// Config your setup here! ////////////////////////////

// This is where you enter your Oauth info
static String OAuthConsumerKey = "buVBno2C6yuploePV3WsoQ";
static String OAuthConsumerSecret = "7gjoIUZF7fSOyGE96CLcFlKCQ8mvbEwxIUusONlA";
// This is where you enter your Access Token info
static String AccessToken = "1235342744-GO5FXQ06yXbT8qnQrJgpZssYMztMPHSIdUPKNWO";
static String AccessTokenSecret = "Lzt9cuUxVtdmBYL5NJTO4uJdwfnjlPfBjUSnj02J4";

static ArrayList urls = new ArrayList();
static Integer i = 0;
static Integer s = 140;

int test = 0;

// if you enter keywords here it will filter, otherwise it will sample
String keywords[] = { 
  "parti pirate", "partipirate", "pirate party", "pirateparty", "PPAlsace", "ppposter"
    //, "parti", "pirate"
};

///////////////////////////// End Variable Config ////////////////////////////

TwitterStream twitter = new TwitterStreamFactory().getInstance();

void setup() {
  size(600, 849);
  background(0, 255, 0);
  font = createFont("TerminalGrotesque_a", 5);  

  connectTwitter();
  twitter.addListener(listener);
  if (keywords.length==0) twitter.sample();
  else twitter.filter(new FilterQuery().track(keywords));

  // charger les logos
  for (int i=1; i<myImageArray.length; i++) {
    myImageArray[i] = loadImage( "logos/logo_" + i + ".png");
  }
}


void draw() {
}


// Initial connection
void connectTwitter() {
  twitter.setOAuthConsumer(OAuthConsumerKey, OAuthConsumerSecret);
  AccessToken accessToken = loadAccessToken();
  twitter.setOAuthAccessToken(accessToken);
}


// Loading up the access token
private static AccessToken loadAccessToken() {
  return new AccessToken(AccessToken, AccessTokenSecret);
}


// This listens for new tweet
StatusListener listener = new StatusListener() {

  public void onStallWarning(StallWarning warning) {
    System.out.println("Got stall warning:" + warning);
  }

  public void onStatus(Status status) {
    println("-"+" @" + status.getUser().getScreenName() + " - " + status.getText());
    displayTw(status);
    delay(5000);
  }

  public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
  }

  public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
  }

  public void onScrubGeo(long userId, long upToStatusId) {
  }

  public void onException(Exception ex) {
    ex.printStackTrace();
  }
};



void displayTw (Status s)
{
  String date = new java.text.SimpleDateFormat("dd:MM:yy(H'h'm'm's's')").format(new java.util.Date ());  
  PGraphics pdf = createGraphics(pdfW, pdfH, PDF, "captures/print/PPPoster2-" + date + ".pdf");
  pdf.beginDraw();

  String who = "";
  String txt = "";
  who = s.getUser().getScreenName();
  String time = new java.text.SimpleDateFormat("'le 'dd.MM.yy' à 'HH':'mm").format(new java.util.Date ());              
  txt = s.getText();

  // arrière-plan
  fill(0, 255, 0);
  noStroke();
  rect(0, 0, width, height); 


  // Afficher un logo aléatoirement
  image(myImageArray[(int)random(1, 150)], 0 -(logoW/10.75), height - (2*(height/9)), logoW, logoH);

  fill(0);
  textFont(font);
  textAlign(LEFT, TOP);

  pdf.image(myImageArray[(int)random(1, 150)], (pdfW/300) -(pdfLogoW/9), pdfH - (2*(pdfH/8)), pdfLogoW, pdfLogoH);

  pdf.fill(0);
  pdf.textFont(font);
  pdf.textAlign(LEFT, TOP);


  int index=0;
  int count=0;

  txt = txt.replaceAll("  ", " "); // double espace
  txt = txt.replaceAll(" ,", ","); // espace virgule
  txt = txt.replaceAll(" :", ":"); // espace :
  txt = txt.replaceAll(" !", "!"); // espace !

  // Compteur d'espaces
  while (txt.indexOf (" ", index)>=0)
  {
    count++;
    index=txt.indexOf(" ", index)+1; //Prochaine occurence
  } 

  println("il y a "+ count +" espaces dans ce tweet");

  // Générateur de random
  int randoMax = 0;
  if (count <= 3) {
    randoMax = 1;
  } 
  else if (count <= 6) {
    randoMax = 2;
  } 
  else if (count <= 18) {
    randoMax = 3;
  } 
  else if (count > 18) {
    randoMax = 4;
  } 

  println("PROBABILITÉ : 1/"+randoMax);

  String[] listA = split(txt, " ");
  for (int i = 0 ; i < listA.length ; i++) {
    if ( int(random(0, randoMax)) == 0) {
      listA[i] = listA[i]+"\n";
    } 
    else {
      listA[i] = listA[i]+" ";
    }
  }

  String phrase = join(listA, "");

  phrase = phrase.replaceAll("\n\n", "\n");

  String[] list = split(phrase, "\n");

  float scalar = 0.765; // Different pour chaque typo  
  float[] lineHeight = new float[list.length];
  float[] pdfLineHeight = new float[list.length];


  for (int i = 0 ; i < list.length ; i++ ) {
    textSize(1);
    for (int j = 0; j < l ; j++) {
      if ( textWidth(list[i]) < l-30) {
        textSize(j);
      }
    }
    // interlignage
    float ascent = textAscent() * scalar; 
    float descent = textDescent(); 
    lineHeight[i] = ascent;
    int posY= width/50;
    for (int k=0 ; k < i ; k++) {
      posY += lineHeight[k] + interligne ; // interligne
    }
    text(list[i], width/60, posY-descent, l+(l/6), 1200);
  }

  /////////////////////// PDF ////////////////////////

  for (int pdfi = 0 ; pdfi < list.length ; pdfi++ ) {
    pdf.textSize(1);

    for (int pdfj = 0; pdfj < pdfW ; pdfj++) {
      if ( pdf.textWidth(list[pdfi]) < pdfW-(pdfW/100)) {
        pdf.textSize(pdfj);
      }
    }

    // interlignage
    float pdfAscent = pdf.textAscent() * scalar; 
    float pdfDescent = pdf.textDescent(); 
    pdfLineHeight[pdfi] = pdfAscent;
    int pdfPosY= 0;

    for (int pdfk=0 ; pdfk < pdfi ; pdfk++) {
      pdfPosY += pdfLineHeight[pdfk] + interligne ; // interligne
    }
    pdf.text(list[pdfi], 0 , pdfPosY-pdfDescent, pdfW+(pdfW/6), pdfW*2);
  }

  /////////////////////// endPDF ////////////////////////

  String data = "@"+ who +" - "+ time;

  textFont(font, width/50);
  textAlign(LEFT);  
  float dataW = textWidth(data);
  fill(0, 255, 0);
  stroke(0);
  rect((width/45), height-(width/12), dataW+(width/30), width/36); 
  noStroke();
  fill(0);
  text(data, (width/45)+((width/60)), height-(width/12)+(width/50));


  pdf.textFont(font, (pdfW/44));
  pdf.textAlign(LEFT);
  float pdfDataW = textWidth(data);
  pdf.fill(255);
  pdf.stroke(0);
  pdf.rect((pdfW/60), pdfH-(pdfW/10.55), pdfDataW+(pdfW/30), pdfW/36); 
  pdf.noStroke();
  pdf.fill(0);
  pdf.text(data, (pdfW/60)+((pdfW/55)), pdfH-(pdfW/10.55)+(pdfW/45));

  pdf.dispose();
  pdf.endDraw();
}




