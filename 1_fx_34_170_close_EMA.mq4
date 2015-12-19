//+------------------------------------------------------------------+
//|                                                   1_fx_scalp.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property  indicator_buffers 13

//EMA first set
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green
#property indicator_color4 Blue
#property indicator_color5 Black
#property indicator_color6 Blue
#property indicator_color7 Black
#property indicator_color8 Black
#property indicator_color9 Green
#property indicator_color10 Red
#property indicator_color11 Blue
#property indicator_color12 Blue
#property indicator_color13 Black

//MA buffers
double EMA_BUFFER_34_LOW[]; //M5
double EMA_BUFFER_34_CLOSE[]; //M5
double EMA_BUFFER_34_HIGH[]; //M5
double EMA_BUFFER_170[]; //M5
double EMA_BUFFER_57[]; // EMA 170 z M5 na M15
double EMA_BUFFER_600[]; //EMA 50 z H1 na M5
double EMA_BUFFER_200[]; //EMA 50 z H1 na M15
double EMA_BUFFER_50[]; // EMA 50 z H1
double EMA_BUFFER_14[]; // EMA 170 z M5 na H1
double EMA_BUFFER_28[]; // EMA 170 z M5 na M30
double EMA_BUFFER_100[]; // EMA 50 z H1 na M30

//strzalki
double ENTER_LONG_BUFFER[];
double ENTER_SHORT_BUFFER[];

bool s = false;;

extern bool EMA_FLAG_34_LOW = true;
extern bool EMA_FLAG_34_CLOSE = true;
extern bool EMA_FLAG_34_HIGH = true;
extern bool EMA_FLAG_170 = true;
extern bool EMA_FLAG_57 = true; 
extern bool EMA_FLAG_600 = false;
extern bool EMA_FLAG_50 = true;
extern bool EMA_FLAG_200 = true;
extern bool EMA_FLAG_14 = true;
extern bool EMA_FLAG_28 = true;
extern bool EMA_FLAG_100 = true;

extern int SL = 15; // Stop loss point size.
extern int TP = 25; // take profit point size.
extern bool isSLForBuy = false; // is enabled
extern bool isSLForSell = false;
extern bool isTPForBuy = false;
extern bool isTPForSell = false;
extern bool allTF = false;

extern int shortEntry  = 234;
extern int longEntry  = 233;
extern bool showSignal = false;

 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(10);
   
   //EMA setup  
   SetIndexBuffer(0,EMA_BUFFER_34_LOW);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   
   SetIndexBuffer(1,EMA_BUFFER_34_CLOSE);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);
   SetIndexBuffer(2,EMA_BUFFER_34_HIGH);
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1);
   
   SetIndexBuffer(3,EMA_BUFFER_170);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2);
   
   SetIndexBuffer(4,EMA_BUFFER_600);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,1);

   SetIndexBuffer(5,EMA_BUFFER_57);
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,1);
   
   SetIndexBuffer(6,EMA_BUFFER_50);
   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,1);
   
   SetIndexBuffer(7,EMA_BUFFER_200);
   SetIndexStyle(7,DRAW_LINE,STYLE_SOLID,1);
   
   //enter setup
   SetIndexStyle(8,DRAW_ARROW,0,1); 
   SetIndexArrow(8,longEntry); 
   SetIndexBuffer(8,ENTER_LONG_BUFFER); 
   SetIndexEmptyValue(8,0.0);
   
   SetIndexStyle(9,DRAW_ARROW,0,1); 
   SetIndexArrow(9,shortEntry); 
   SetIndexBuffer(9,ENTER_SHORT_BUFFER); 
   SetIndexEmptyValue(9,0.0);
   
   SetIndexBuffer(10,EMA_BUFFER_14);
   SetIndexStyle(10,DRAW_LINE,STYLE_SOLID,1);
   
   SetIndexBuffer(11,EMA_BUFFER_28);
   SetIndexStyle(11,DRAW_LINE,STYLE_SOLID,1);
   
   SetIndexBuffer(12,EMA_BUFFER_100);
   SetIndexStyle(12,DRAW_LINE,STYLE_SOLID,1);
   
   return(0);
  }

int deinit()
  {
   return(0);
  }
int start()
  {
   drawM5();
   drawM15();
   drawM30();
   drawH1();
   drawStopLossLevelForBuy();
   drawStopLossLevelForSell();
   drawTakeProfitLevelForBuy();
   drawTakeProfitLevelForSell(); 
   return(0);
  }

void drawM5(){
  if( Period() == PERIOD_M5 || allTF){ 
      double value34L, value34C, value34H, value170, value600;
      double mainSTOCH;
      double signalSTOCH;
      
      int limit;
      int counted_bars = IndicatorCounted();
      if (counted_bars<0) {
         return;
      }
      if (counted_bars>0){
         counted_bars--;
      }
      limit = Bars - counted_bars;
   
      for(int i=limit; i>=0; i--)
      {  
          value34L = iMA(NULL,0,34,0,MODE_EMA,PRICE_LOW,i);
          value34C = iMA(NULL,0,34,0,MODE_EMA,PRICE_CLOSE,i);
          value34H = iMA(NULL,0,34,0,MODE_EMA,PRICE_HIGH,i);
          value170 = iMA(NULL,0,170,0,MODE_EMA,PRICE_CLOSE,i);
          value600 = iMA(NULL,0,600,0,MODE_EMA,PRICE_CLOSE,i);
          mainSTOCH = iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,i);
          signalSTOCH = iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,i);
           
          if(EMA_FLAG_34_LOW){
              EMA_BUFFER_34_LOW[i] = value34L;
          }
          if(EMA_FLAG_34_CLOSE){
              EMA_BUFFER_34_CLOSE[i] = value34C; 
          }
          if(EMA_FLAG_34_HIGH){
              EMA_BUFFER_34_HIGH[i] = value34H; 
          }
          if(EMA_FLAG_170){
             EMA_BUFFER_170[i] = value170; 
          }
          if(EMA_FLAG_600){
             EMA_BUFFER_600[i] = value600;
          }//&& TimeHour(Time[i]) >= 9 && TimeHour(Time[i]) <=21
          if(showSignal){
              if(i != 0){ // nie beirzemy ostatniej swieczki bo jest nieskonczona
                //shorty
                //if(value170 > value34H && Open[i] > Close[i] && Close[i] < value34L && High[i] > value34L ){ //value600 > value170 && //wyjscie od srednich
                if(value170 > value34H &&  Open[i] > Close[i] && Close[i] < value34L && High[i] > value34L){
                  ENTER_SHORT_BUFFER[i] = value34H;
                }
                //longi
                //if( value170 < value34L && Open[i] < Close[i] && Close[i] > value34H && Low[i] < value34H ){ //value600 < value170  ////wyjscie od srednich
                if( value170 < value34L && Open[i] < Close[i] && Close[i] > value34H && Low[i] < value34H ){ 
                  ENTER_LONG_BUFFER[i] = value34L;
                }
             }
          }

      }
   }
}

void drawM15(){
  if( Period() == PERIOD_M15 ){ 
      double value57, value200;
      int limit;
      int counted_bars = IndicatorCounted();
      if (counted_bars<0) {
         return;
      }
      if (counted_bars>0){
         counted_bars--;
      }
      limit = Bars - counted_bars;
   
      for(int i=limit; i>=0; i--)
      {  
          value57 = iMA(NULL,0,57,0,MODE_EMA,PRICE_CLOSE,i);
          value200 = iMA(NULL,0,200,0,MODE_EMA,PRICE_CLOSE,i);
   
          if(EMA_FLAG_57){
             EMA_BUFFER_57[i] = value57;
          }
          if(EMA_FLAG_200){
             EMA_BUFFER_200[i] = value200;
          }          
   
      }
   }
}

void drawM30(){
  if( Period() == PERIOD_M30 ){ 
      double value28, value100;
      int limit;
      int counted_bars = IndicatorCounted();
      if (counted_bars<0) {
         return;
      }
      if (counted_bars>0){
         counted_bars--;
      }
      limit = Bars - counted_bars;
   
      for(int i=limit; i>=0; i--)
      {  
          value28 = iMA(NULL,0,28,0,MODE_EMA,PRICE_CLOSE,i);
          value100 = iMA(NULL,0,100,0,MODE_EMA,PRICE_CLOSE,i);
   
          if(EMA_FLAG_28){
             EMA_BUFFER_28[i] = value28;
          }
          if(EMA_FLAG_100){
             EMA_BUFFER_100[i] = value100;
          }          
   
      }
   }
}


void drawH1(){
  if( Period() == PERIOD_H1 ){ 
   double value50;
   double value14;
      int limit;
      int counted_bars = IndicatorCounted();
      if (counted_bars<0) {
         return;
      }
      if (counted_bars>0){
         counted_bars--;
      }
      limit = Bars - counted_bars;
   
      for(int i=limit; i>=0; i--)
      {  
          value50 = iMA(NULL,0,50,0,MODE_EMA,PRICE_CLOSE,i);
          value14 = iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,i);
          if(EMA_FLAG_50){
             EMA_BUFFER_50[i] = value50;
          }
          if(EMA_FLAG_14){
             EMA_BUFFER_14[i] = value14;
          }
   
      }
   }
}
void drawStopLossLevelForBuy(){
   ObjectDelete("Stop_Loss_Buy");
   if(!isPeriodM5()){
      return ;
   }
   if(isSLForBuy){
      double price = Ask - (getPipPoint()*SL);
      ObjectCreate("Stop_Loss_Buy", OBJ_TREND, 0, Time[10], price, Time[0], price);
      ObjectSetInteger(ChartID(),"Stop_Loss_Buy",OBJPROP_COLOR,Red);
      ObjectSetInteger(ChartID(),"Stop_Loss_Buy",OBJPROP_RAY_LEFT,false);
      ObjectSetInteger(ChartID(),"Stop_Loss_Buy",OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(ChartID(),"Stop_Loss_Buy",OBJPROP_WIDTH,2);
   }     
}
void drawStopLossLevelForSell(){
   ObjectDelete("Stop_Loss_Sell");
   if(!isPeriodM5()){
      return ;
   }
   if(isSLForSell){
      double price = Bid + (getPipPoint()*SL);
      ObjectCreate("Stop_Loss_Sell", OBJ_TREND, 0, Time[10], price, Time[0], price);
      ObjectSetInteger(ChartID(),"Stop_Loss_Sell",OBJPROP_COLOR,Red);
      ObjectSetInteger(ChartID(),"Stop_Loss_Sell",OBJPROP_RAY_LEFT,false);
      ObjectSetInteger(ChartID(),"Stop_Loss_Sell",OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(ChartID(),"Stop_Loss_Sell",OBJPROP_WIDTH,2);
   }  
}
void drawTakeProfitLevelForBuy(){
   ObjectDelete("Take_Profit_Buy");
   if(!isPeriodM5()){
      return ;
   }   
   if(isTPForBuy){
      double price = Bid + (getPipPoint()*TP);
      ObjectCreate("Take_Profit_Buy", OBJ_TREND, 0, Time[10], price, Time[0], price);
      ObjectSetInteger(ChartID(),"Take_Profit_Buy",OBJPROP_COLOR,Green);
      ObjectSetInteger(ChartID(),"Take_Profit_Buy",OBJPROP_RAY_LEFT,false);
      ObjectSetInteger(ChartID(),"Take_Profit_Buy",OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(ChartID(),"Take_Profit_Buy",OBJPROP_WIDTH,2);
   }     
}
void drawTakeProfitLevelForSell(){
   ObjectDelete("Take_Profit_Sell");
   if(!isPeriodM5()){
      return ;
   }   
   if(isTPForSell){
      double price = Ask - (getPipPoint()*TP);
      ObjectCreate("Take_Profit_Sell", OBJ_TREND, 0, Time[10], price, Time[0], price);
      ObjectSetInteger(ChartID(),"Take_Profit_Sell",OBJPROP_COLOR,Green);
      ObjectSetInteger(ChartID(),"Take_Profit_Sell",OBJPROP_RAY_LEFT,false);
      ObjectSetInteger(ChartID(),"Take_Profit_Sell",OBJPROP_RAY_RIGHT,false);
      ObjectSetInteger(ChartID(),"Take_Profit_Sell",OBJPROP_WIDTH,2);
   }  
}



double getPipPoint(){
   double usePoint = 0.01;
   if (Digits == 4 || Digits == 5){
      usePoint = 0.0001;
   }
   return(usePoint);
}

bool isPeriodM5(){
   return ( Period() == PERIOD_M5 );
}
   



