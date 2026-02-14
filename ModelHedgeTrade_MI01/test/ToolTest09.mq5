//+------------------------------------------------------------------+
//|                                                       Test09.mq5 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      "https://www.mql5.com"
#property version   "1.00"

int OnInit()
{
   
   string originalNumber = "100100012311111101";
   string formattedNumber = FormatNumber(originalNumber);

   // Print the result
   if(formattedNumber != "") {
      Print("Original: ", originalNumber);
      Print("Formatted: ", formattedNumber);
   }


   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Format Number Function                                           |
//+------------------------------------------------------------------+
string FormatNumber(string number) {
   // Ensure the number has at least 6 digits
   if(StringLen(number) < 6) {
      Print("Error: Number must have at least 6 digits.");
      return "";
   }
   
   // Insert "-" after the first 4 digits
   string part1 = StringSubstr(number, 0, 4);
   string part2 = StringSubstr(number, 4, StringLen(number) - 6);
   string part3 = StringSubstr(number, StringLen(number) - 2);

   // Combine parts with "-"
   string formatted = part1 + "-" + part2 + "-" + part3;
   return formatted;
}
