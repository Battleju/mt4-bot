//+------------------------------------------------------------------+
//|                                              beste -> EMABot.mq4 |
//|                                       Copyright 2024, Kurwa Ltd. |
//|                                              https://www.kwa.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

// Inputs
input int magic = 1;

input int short_ma_period = 8;
input int long_ma_period = 20;

input double tp_point = 5000;
input double sl_point = 1000;

input double lot = 0.1;

// Global variables
int current_ticket = 0;
int stop_level = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   stop_level = (int)MarketInfo(Symbol(), MODE_STOPLEVEL);
   return(INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){}


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){

   // Check for open positions -> if yes skip checking for opening new positions 
   int count_open_positions = 0;
   for (int i = 0; i < OrdersTotal(); i++) {
       if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
           if (OrderType() <= OP_SELL) {
               count_open_positions++;
           }
       }
   }
   if (count_open_positions <= 0){
      current_ticket = 0;
   }
   
   Print(current_ticket);

   if (current_ticket != 0){
      Print("POSITION ALREADY OPEN");
      return;
   }
  
   double current_short_ma = iMA(NULL, PERIOD_CURRENT, short_ma_period, 0, MODE_SMA, PRICE_CLOSE, 0);
   double current_long_ma = iMA(NULL, PERIOD_CURRENT, long_ma_period, 0, MODE_SMA, PRICE_CLOSE, 0);
   
   double last_short_ma = iMA(NULL, PERIOD_CURRENT, short_ma_period, 0, MODE_SMA, PRICE_CLOSE, 2);
   double last_long_ma = iMA(NULL, PERIOD_CURRENT, long_ma_period, 0, MODE_SMA, PRICE_CLOSE, 2);
   
   double difference = current_short_ma - current_long_ma;
   double last_difference = last_short_ma - last_long_ma;
   
   Print("Current difference: ", difference);
   Print("Last difference: ", last_difference);
   
   if (difference > 0 && last_difference < 0){
      execLong();
   }else if (difference < 0 && last_difference > 0){
      execShort();
   }
}

void execShort(){
   Print("StopLevel = ", (int)MarketInfo(Symbol(), MODE_STOPLEVEL));
   int ticket = OrderSend(NULL, OP_SELL, lot, Bid, 1000, Bid + sl_point*Point, Bid - tp_point*Point, "Sell by bot", magic, 0, clrRed);
   current_ticket = ticket;
   if (ticket < 0){
      Print("Short is failed! #", GetLastError());
      current_ticket = 0;
   }
   Print("WENT SHORT");
}

void execLong(){
   Print("StopLevel = ", (int)MarketInfo(Symbol(), MODE_STOPLEVEL));
   int ticket = OrderSend(NULL, OP_BUY, lot, Ask, 1000, Ask - sl_point*Point, Ask + tp_point*Point, "Buy by bot", magic, 0, clrGreen);
   current_ticket = ticket;
   if (ticket < 0){
      Print("Long is failed! #", GetLastError());
      current_ticket = 0;
   }
   Print("WENT LONG");
}
