#property copyright "Copyright @ 2015 KarsonFX"
#property link      "email: karol.kornecki@gmail.com" 

#property indicator_chart_window

extern int    Digits_To_Show_In_Spread        = 2;
extern color  Spread_Color                    = C'80,80,80';
extern color  Range_Color                     = C'80,80,80'; 
extern color  Swaps_Color                     = C'80,80,80'; 
extern color  Candle_Time_Color               = C'80,80,80';  
extern bool   Use_For_Forex                   = true;
extern color  Symbol_And_TF_Color             = Black;
extern int    Candle_In_Range                 = 1;
extern color  Panel_Background_Color          = C'238,238,242';
extern bool   __Use_Full_Size_Fractional_Pip  = false;   

//------- variable for session indication ---
extern int    NumberOfDays = 99;             
extern string AsiaBegin    = "01:00";        
extern string AsiaEnd      = "10:00";        
extern color  AsiaColor    = C'0,32,0';     
extern string EurBegin     = "08:00";        
extern string EurEnd       = "18:00";        
extern color  EurColor     = C'48,0,0';      
extern string USABegin     = "14:00";        
extern string USAEnd       = "23:00";        
extern color  USAColor     = C'0,0,56';      
extern bool   ShowPrice    = False;          
extern color  clFont       = Blue;           
extern int    SizeFont     = 8;              
extern int    OffSet       = 10;             
extern bool   isDrawSessionBoundary = false;
//-------------------------------------------

color      Static_Price_Color, Static_Bid_Color, Bid_Dot_Color, Static_Bid_Dot_Color;

double point;
string space = "     ";
double Old_Price;
double Price;
color Color;
int LP;
string tab,tab1;

extern color  Bid_UP_Color                    = ForestGreen;
extern color  Bid_DN_Color                    = Crimson;
extern color  Bid_Forex_5th_Digit_Large       = Red; 
extern color  Bid_Forex_5th_Digit_Small       = Black; 
extern color  Bid_Dot_Up_Color                = C'0,244,62';   
extern color  Bid_Dot_Dn_Color                = C'255,43,48'; 

extern string H4_D1_ema_signal = "";
extern string D1_macd_signal = "";
extern string H4_macd_signal = "";
extern string my_bias = ""; 

int fontSize = 8;
int bigFontSize = 14;
string     box                                = "z[KRS Text]  Box 1";
string     box2                               = "z[KRS Text]  Box 2";
string     box3                               = "z[KRS Text]  Box 3";      
string     symbol_label                       = "z[KRS Text] Symbol";
string     spread_label                       = "z[KRS Text] Spread"; 
string     dialy_range_label                  = "z[KRS Text] D Range";
string     h4_range_label                     = "z[KRS Text] H4 Range";
string     h1_range_label                     = "z[KRS Text] H1 Range";
string     m30_range_label                    = "z[KRS Text] M30 Range";
string     m15_range_label                    = "z[KRS Text] M15 Range";
string     m5_range_label                     = "z[KRS Text] M5 Range"; 
string     swaps_label                        = "z[KRS Text] Swaps"; 
string     time_label                         = "z[KRS Text] Time"; 
string     price_label                        = "z[KRS Text] Price";
string     price2_label                       = "z[KRS Text] Price2";
string     H1_M15_EMA_signal                  = "z[KRS Signal] H1_M15";
string     M5_EMA_signal                      = "z[KRS Signal] M5"; 
    
int init() {
   checkIsForex();
   calculatePoint();
   createLabels();
   if(isDrawSessionBoundary){
      deleteSessionObjects();
   }
   return(0);
}

int deinit(){   
   deleteAllObjects();
   if(isDrawSessionBoundary){
     DeleteObjects();
   }
   return(0);
 }

      
int start(){
   displayBackGroundBox();
   displaySymbolAndTimeFrame();
   displaySwapPoints();
   calculateAndDisplaySpread();
   calculateAndDisplayCandleTimeLeft(); 
   /*calculateAndDisplayDialyRange();
   calculateAndDisplayH4Range();
   calculateAndDisplayH1Range();
   calculateAndDisplayM30Range();
   calculateAndDisplayM15Range();
   calculateAndDisplayM5Range();*/
   calculateAndDisplayPrice();
   if(isDrawSessionBoundary){
      drawSessionBoundary();
   }
   drawSignals();
   return(0);
}

void drawSignals(){
   drawSignal();
}

void drawSignal(){
   
   createLabel("z[KRS Signal] H4_D1_EMA", 240,10);
   ObjectSetText("z[KRS Signal] H4_D1_EMA", "D1-EMA: "+H4_D1_ema_signal, 8, "Arial Bold", Black);
    
   createLabel("z[KRS Signal] H4_MACD", 240,30);
   ObjectSetText("z[KRS Signal] H4_MACD", "H4-MACD: "+H4_macd_signal, 8, "Arial Bold", Black); 
   
   createLabel("z[KRS Signal] D1_MACD", 240,50);
   ObjectSetText("z[KRS Signal] D1_MACD", "D1-EMA: "+D1_macd_signal, 8, "Arial Bold", Black);
    
   createLabel("z[KRS Signal] MY_BIAS", 240,70);
   ObjectSetText("z[KRS Signal] MY_BIAS", "D1 BIAS: "+my_bias, 8, "Arial Bold", Black); 
   
   if(Period() == PERIOD_M5){
      createLabel(H1_M15_EMA_signal, 240,90);
      createLabel(M5_EMA_signal, 240,110);
   
      double EMA_34_HIGH = iMA(NULL,0,34,0,MODE_EMA,PRICE_HIGH,1);
      double EMA_34_LOW = iMA(NULL,0,34,0,MODE_EMA,PRICE_LOW,1);
      double EMA_170_CLOSE = iMA(NULL,0,170,0,MODE_EMA,PRICE_CLOSE,1);
      double EMA_600_CLOSE = iMA(NULL,0,600,0,MODE_EMA,PRICE_LOW,1);
      
      if(EMA_34_HIGH < EMA_170_CLOSE){
         ObjectSetText(M5_EMA_signal, "M5:    SHORT", 8, "Arial Bold", Red); 
      } else if (EMA_34_LOW > EMA_170_CLOSE){
         ObjectSetText(M5_EMA_signal, "M5:    LONG", 8, "Arial Bold", Green); 
      } else {
         ObjectSetText(M5_EMA_signal, "M5:    NEUTRAL", 8, "Arial Bold", Black); 
      }
      
      if(EMA_170_CLOSE < EMA_600_CLOSE){
         ObjectSetText(H1_M15_EMA_signal, "M15:  SHORT", 8, "Arial Bold", Red); 
      } else if (EMA_170_CLOSE > EMA_600_CLOSE){
         ObjectSetText(H1_M15_EMA_signal, "M15:  LONG", 8, "Arial Bold", Green); 
      } else {
         ObjectSetText(H1_M15_EMA_signal, "M15:  NEUTRAL", 8, "Arial Bold", Black);
      }
      
   }
}


void calculateAndDisplayPrice(){
   double newPrice;
   if(Use_For_Forex){
       newPrice = MathFloor(Bid/point)*point;  
    } else {
       newPrice = Bid;
    }
     Price=DoubleToStr(NormalizeDouble(Bid, 5));                     
     if(newPrice > Old_Price) {
       Color = Bid_UP_Color;
       Static_Price_Color = Bid_UP_Color;      
     } else if (newPrice < Old_Price) {      
       Color = Bid_DN_Color; 
       Static_Price_Color = Bid_DN_Color;  
     } else {
       Color = Static_Price_Color;       
     }
     Old_Price = newPrice;
      
  LP = StringLen(Price); 
      
  if(Use_For_Forex){
      if (LP == 6){
            ObjectSetText(price_label, Price,16, "Arial Bold",Color);  
            ObjectSetText(price2_label, "0", 16, "Arial Bold",Bid_Forex_5th_Digit_Large); 
      } 
      else if (LP == 5){
            ObjectSetText(price_label, Price+"0",16, "Arial Bold",Color);  
            ObjectSetText(price2_label, "0", 16, "Arial Bold",Bid_Forex_5th_Digit_Large); 
      } 
      else if (LP == 4){
            ObjectSetText(price_label, Price+"00",16, "Arial Bold",Color);  
            ObjectSetText(price2_label, "0", 16, "Arial Bold",Bid_Forex_5th_Digit_Large); 
      }
      else {
            ObjectSetText(price_label, StringSubstr(Price,0,LP-1),16, "Arial Bold",Color);  
            ObjectSetText(price2_label, StringSubstr(Price,LP-1,LP), 16, "Arial Bold",Bid_Forex_5th_Digit_Large); 
      }      
  } else { 
      ObjectSetText(price_label, tab+Price, 14, "Arial Bold",Color);
  }         
}

void displayBackGroundBox(){
  ObjectSet(box, OBJPROP_BACK, false); 
  ObjectSetText(box, "gg", 60, "Webdings", Panel_Background_Color);  
  ObjectSet(box2, OBJPROP_BACK, false); 
  ObjectSetText(box2, "gg", 60, "Webdings", Panel_Background_Color);
  /*ObjectSet(box3, OBJPROP_BACK, false); 
  ObjectSetText(box3, "gg", 60, "Webdings", Panel_Background_Color);  */
}


void calculateAndDisplayCandleTimeLeft(){
  string timeLeft = "";
  if(Period()>1440) {
      timeLeft = "(OFF)";
  } else {
      timeLeft =TimeToStr(Time[0]+Period()*60-TimeCurrent(),TIME_MINUTES|TIME_SECONDS);
  }                  
  ObjectSetText(time_label, "Candle   " + timeLeft, fontSize, "Arial", Candle_Time_Color);  
}

void displaySwapPoints(){
  ObjectSetText(swaps_label, "Swaps    "
  +DoubleToStr(MarketInfo(Symbol(),MODE_SWAPLONG),2)+", "
  +DoubleToStr(MarketInfo(Symbol(),MODE_SWAPSHORT),2)+"",fontSize, "Arial", Swaps_Color);    
}

void calculateAndDisplayDialyRange(){             
  double sumOfDialyCandlesRange = 0.0;
  for(int i=1; i<=Candle_In_Range; i++){
    if (isNotSunday(i)) {
         sumOfDialyCandlesRange += (iHigh(NULL,PERIOD_D1,i)- iLow(NULL,PERIOD_D1,i));
    } //else {
       // Alert("There are some Sunday candles.");
   // }
  }
  
  double avg = ((sumOfDialyCandlesRange/Candle_In_Range)/Point)/getFactor();
  
  double todayHigh = iHigh(NULL,PERIOD_D1,0);
  double todayLow	 = iLow (NULL,PERIOD_D1,0);	
  double todayRange = ((todayHigh - todayLow)/Point)/getFactor();
  ObjectSetText(dialy_range_label, "D1    Range   "+DoubleToStr(avg,0) +" ("+DoubleToStr(todayRange,0)+")", fontSize, "Arial", Range_Color);                     
}

void calculateAndDisplayRange(int periodCode, string labelId, string labelText){
  double rangeSum = 0.0;
  for(int i=1; i<=Candle_In_Range; i++){
     rangeSum += (iHigh(NULL,periodCode,i)- iLow(NULL,periodCode,i)); 
  }
  double avg = ((rangeSum/Candle_In_Range)/Point)/getFactor();
  double currentCandleHigh  = iHigh(NULL,periodCode,0);
  double currentCandleLow	 = iLow (NULL,periodCode,0);
 // double currentCandleRange = ((currentCandleHigh - currentCandleLow)/Point)/getFactor();
  double currentCandleRange = iATR(NULL, periodCode, 15, 0);
  ObjectSetText(labelId, labelText + "   "+DoubleToStr(avg,0) +" ("+DoubleToStr(currentCandleRange,0)+")", fontSize, "Arial", Range_Color); 	
}
void calculateAndDisplayH4Range(){
  calculateAndDisplayRange(PERIOD_H4, h4_range_label, "H4    Range");	
}
void calculateAndDisplayH1Range(){
  calculateAndDisplayRange(PERIOD_H1, h1_range_label, "H1    Range");	
}
void calculateAndDisplayM30Range(){
  calculateAndDisplayRange(PERIOD_M30, m30_range_label, "M30 Range");	
}
void calculateAndDisplayM15Range(){
  calculateAndDisplayRange(PERIOD_M15, m15_range_label, "M15 Range");	
}
void calculateAndDisplayM5Range(){
  calculateAndDisplayRange(PERIOD_M5, m5_range_label, "M5   Range");	
}

bool isNotSunday(int i){
   return (TimeDayOfWeek(iTime(NULL,PERIOD_D1,i))!=0);
}

void createLabels(){
   createLabel(box, 0,0);
   createLabel(box2, 0,120);
  // createLabel(box3, 0,200);
   createLabel(symbol_label, 0,5);                      
   createLabel(spread_label, 10,40);
   createLabel(swaps_label, 10,65);
   createLabel(time_label, 10, 90);
   /*createLabel(dialy_range_label, 10, 115);
   createLabel(h4_range_label, 10, 140);
   createLabel(h1_range_label, 10, 165);
   createLabel(m30_range_label, 10, 190);
   createLabel(m15_range_label, 10, 215);
   createLabel(m5_range_label, 10, 240); */
   createLabel(price_label, 40, 140);
   createLabel(price2_label, 140, 140);
}

void checkIsForex(){
  if(Digits == 2) {
      Use_For_Forex = false;
  }
}

int getFactor(){           
  if(Digits == 5 || Digits == 3) {
      return 10;
  }
   return 1;
}

void calculateAndDisplaySpread(){
  double spread = MarketInfo(Symbol(), MODE_SPREAD);
  spread /= getFactor();                                        
  ObjectSetText(spread_label, "Spread   "+ DoubleToStr(spread,Digits_To_Show_In_Spread), fontSize, "Arial", Spread_Color);
}

void displaySymbolAndTimeFrame(){
  string symbol = StringSubstr(Symbol(), 0, 6);        	 	         
  if (Period()== 1){
      ObjectSetText(symbol_label, space+symbol+"   M1", bigFontSize, "Arial Bold", Symbol_And_TF_Color); 
  } else if (Period()== 5){
      ObjectSetText(symbol_label, space+symbol+"   M5", bigFontSize, "Arial Bold", Symbol_And_TF_Color); 
  } else if (Period()== 15) {
      ObjectSetText(symbol_label, space+symbol+"   M15", bigFontSize, "Arial Bold", Symbol_And_TF_Color); 
  } else if (Period() == 30){
     ObjectSetText(symbol_label, space+symbol+"   M30", bigFontSize, "Arial Bold", Symbol_And_TF_Color);  
  } else if (Period()== 60){
     ObjectSetText(symbol_label, space+symbol+"   H1", bigFontSize, "Arial Bold", Symbol_And_TF_Color); 
  } else if (Period()== 240){
     ObjectSetText(symbol_label, space+symbol+"   H4", bigFontSize, "Arial Bold", Symbol_And_TF_Color); 
  } else if (Period()== 1440){
     ObjectSetText(symbol_label, space+symbol+"   Day", bigFontSize, "Arial Bold", Symbol_And_TF_Color); 
  } else if (Period()== 10080){
     ObjectSetText(symbol_label, space+symbol+"   Week", bigFontSize, "Arial Bold", Symbol_And_TF_Color); 
  } else if (Period()== 43200){
     ObjectSetText(symbol_label, space+symbol+"   Month", bigFontSize, "Arial Bold", Symbol_And_TF_Color); 
  }
}

void deleteAllObjects(){
  int total= ObjectsTotal();  
  for(int i = total; i>=0; i--){
    string name= ObjectName(i);
    if (StringSubstr(name,0,4)=="[KRS"){
      ObjectDelete(name);
    }
    if (StringSubstr(name,0,5)=="z[KRS"){
      ObjectDelete(name);
    }
  }
}

void calculatePoint(){
  if (Point == 0.00001) {
      point = 0.0001;
  }     
  else if (Point == 0.001){ 
      point = 0.01;
  }
  else {
      point = Point;
  }    
  if (StringSubstr(Symbol(),0,6) == "XAUUSD") {
      point = 1;
  }   
  else if (StringSubstr(Symbol(),0,6) == "USDMXN") {
      point = 0.001;
  }
  else if (StringSubstr(Symbol(),0,6) == "USDCZK") {
      point = 0.001;
  }  
}

void createLabel( string n, int xoff, int yoff ){
  if(ObjectFind(n) != 0) {    
    ObjectCreate( n, OBJ_LABEL, 0, 0, 0 );
    ObjectSet( n, OBJPROP_CORNER, 0 );
    ObjectSet( n, OBJPROP_XDISTANCE, xoff );
    ObjectSet( n, OBJPROP_YDISTANCE, yoff );
    ObjectSet( n, OBJPROP_BACK, false ); 
  } else {
   ObjectMove(n, 0, xoff, yoff);
  }       
} 

//----- session rectangle methods

void deleteSessionObjects(){
  DeleteObjects();
  for (int i=0; i<NumberOfDays; i++) {
    CreateObjects("AS"+i, AsiaColor);
    CreateObjects("EU"+i, EurColor);
    CreateObjects("US"+i, USAColor);
  }
}

void CreateObjects(string no, color cl) {
  ObjectCreate(no, OBJ_RECTANGLE, 0, 0,0, 0,0);
  ObjectSet(no, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSet(no, OBJPROP_COLOR, cl);
  ObjectSet(no, OBJPROP_BACK, True);
}


void DeleteObjects() {
  for (int i=0; i<NumberOfDays; i++) {
    ObjectDelete("AS"+i);
    ObjectDelete("EU"+i);
    ObjectDelete("US"+i);
  }
  ObjectDelete("ASup");
  ObjectDelete("ASdn");
  ObjectDelete("EUup");
  ObjectDelete("EUdn");
  ObjectDelete("USup");
  ObjectDelete("USdn");
}


void drawSessionBoundary(){
  datetime dt=CurTime();
  
  for (int i=0; i<NumberOfDays; i++) {
    if (ShowPrice && i==0) {
      DrawPrices(dt, "AS", AsiaBegin, AsiaEnd);
      DrawPrices(dt, "EU", EurBegin, EurEnd);
      DrawPrices(dt, "US", USABegin, USAEnd);
    }
    DrawObjects(dt, "AS"+i, AsiaBegin, AsiaEnd);
    DrawObjects(dt, "EU"+i, EurBegin, EurEnd);
    DrawObjects(dt, "US"+i, USABegin, USAEnd);
    dt=decDateTradeDay(dt);
    while (TimeDayOfWeek(dt)>5) dt=decDateTradeDay(dt);
  }
}

void DrawObjects(datetime dt, string no, string tb, string te) {
  datetime t1, t2;
  double   p1, p2;
  int      b1, b2;

  t1=StrToTime(TimeToStr(dt, TIME_DATE)+" "+tb);
  t2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+te);
  b1=iBarShift(NULL, 0, t1);
  b2=iBarShift(NULL, 0, t2);
  p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2, b2)];
  p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2, b2)];
  ObjectSet(no, OBJPROP_TIME1 , t1);
  ObjectSet(no, OBJPROP_PRICE1, p1);
  ObjectSet(no, OBJPROP_TIME2 , t2);
  ObjectSet(no, OBJPROP_PRICE2, p2);
}


void DrawPrices(datetime dt, string no, string tb, string te) {
  datetime t1, t2;
  double   p1, p2;
  int      b1, b2;

  t1=StrToTime(TimeToStr(dt, TIME_DATE)+" "+tb);
  t2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+te);
  b1=iBarShift(NULL, 0, t1);
  b2=iBarShift(NULL, 0, t2);
  p1=High[Highest(NULL, 0, MODE_HIGH, b1-b2, b2)];
  p2=Low [Lowest (NULL, 0, MODE_LOW , b1-b2, b2)];

  if (ObjectFind(no+"up")<0) ObjectCreate(no+"up", OBJ_TEXT, 0, 0,0);
  ObjectSet(no+"up", OBJPROP_TIME1   , t2);
  ObjectSet(no+"up", OBJPROP_PRICE1  , p1+OffSet*Point);
  ObjectSet(no+"up", OBJPROP_COLOR   , clFont);
  ObjectSet(no+"up", OBJPROP_FONTSIZE, SizeFont);
  ObjectSetText(no+"up", DoubleToStr(p1+Ask-Bid, Digits));

  if (ObjectFind(no+"dn")<0) ObjectCreate(no+"dn", OBJ_TEXT, 0, 0,0);
  ObjectSet(no+"dn", OBJPROP_TIME1   , t2);
  ObjectSet(no+"dn", OBJPROP_PRICE1  , p2);
  ObjectSet(no+"dn", OBJPROP_COLOR   , clFont);
  ObjectSet(no+"dn", OBJPROP_FONTSIZE, SizeFont);
  ObjectSetText(no+"dn", DoubleToStr(p2, Digits));
}


datetime decDateTradeDay (datetime dt) {
  int ty=TimeYear(dt);
  int tm=TimeMonth(dt);
  int td=TimeDay(dt);
  int th=TimeHour(dt);
  int ti=TimeMinute(dt);

  td--;
  if (td==0) {
    tm--;
    if (tm==0) {
      ty--;
      tm=12;
    }
    if (tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
    if (tm==2) if (MathMod(ty, 4)==0) td=29; else td=28;
    if (tm==4 || tm==6 || tm==9 || tm==11) td=30;
  }
  return(StrToTime(ty+"."+tm+"."+td+" "+th+":"+ti));
}
 
//------------------------------