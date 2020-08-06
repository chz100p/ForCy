// http://ja.wikipedia.org/wiki/%E3%83%84%E3%82%A7%E3%83%A9%E3%83%BC%E3%81%AE%E5%85%AC%E5%BC%8F
//// http://ufcpp.net/study/algorithm/o_days.html

#include <stdlib.h>
#include <stdio.h>

/// <summary>
/// �O���S���E�X��1�N1��1������̌o�ߓ��������߂�B
/// �i�O���S���E�X��{�s�O�̓��t���A
///   �`���I�ɃO���S���E�X��Ɠ������[���Ōv�Z�B�j
/// </summary>
/// <param name="y">�N</param>
/// <param name="m">��</param>
/// <param name="d">��</param>
/// <returns>1�N1��1������̌o�ߓ���</returns>
static int GetDays(int y, int m, int d)
{
  // 1�E2�� �� �O�N��13�E14��
  if (m <= 2)
  {
    --y;
    m += 12;
  }
  int dy = 365 * (y - 1); // �o�ߔN���~365��
  int c = y / 100;
  int dl = (y >> 2) - c + (c >> 2); // ���邤�N��
  int dm = (m * 979 - 1033) >> 5; // 1��1������ m ��1���܂ł̓���
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
