// http://ja.wikipedia.org/wiki/%E3%83%84%E3%82%A7%E3%83%A9%E3%83%BC%E3%81%AE%E5%85%AC%E5%BC%8F
//// http://ufcpp.net/study/algorithm/o_days.html

#include <stdlib.h>
#include <stdio.h>

/// <summary>
/// グレゴリウス暦1年1月1日からの経過日数を求める。
/// （グレゴリウス暦施行前の日付も、
///   形式的にグレゴリウス暦と同じルールで計算。）
/// </summary>
/// <param name="y">年</param>
/// <param name="m">月</param>
/// <param name="d">日</param>
/// <returns>1年1月1日からの経過日数</returns>
static int GetDays(int y, int m, int d)
{
  // 1・2月 → 前年の13・14月
  if (m <= 2)
  {
    --y;
    m += 12;
  }
  int dy = 365 * (y - 1); // 経過年数×365日
  int c = y / 100;
  int dl = (y >> 2) - c + (c >> 2); // うるう年分
  int dm = (m * 979 - 1033) >> 5; // 1月1日から m 月1日までの日数
  return dy + dl + dm + d - 1;
}

int main()
{
{
  int ds = GetDays(2015, 1, 1);
  printf("%08x\n", ds);
}
{
  int ds = GetDays(2015, 3, 12);
  printf("%08x\n", ds);
}
{
  int ds = GetDays(2015, 12, 31);
  printf("%08x\n", ds);
}
  return 0;
}
