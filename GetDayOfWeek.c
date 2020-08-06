// http://ja.wikipedia.org/wiki/%E3%83%84%E3%82%A7%E3%83%A9%E3%83%BC%E3%81%AE%E5%85%AC%E5%BC%8F
//// http://ufcpp.net/study/algorithm/o_days.html

#include <stdlib.h>
#include <stdio.h>

//—j“ú “ú Œ ‰Î … –Ø ‹à “y 
//h     1  2  3  4  5  6  0 
static int GetDayOfWeek(int y, int m, int d)
{
  int c = y / 100;
  y %= 100;
  int h = d + 26 * (m + 1) / 10 + y + y / 4  + c / 4 + 5 * c;
  h %= 7;
  return h;
}

int main()
{
  int dow = GetDayOfWeek(2015, 3, 2);
  printf("%d\n", dow);
  return 0;
}
