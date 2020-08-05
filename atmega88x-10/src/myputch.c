
int myputch(int c)
{
  int ret;
  unsigned char buf;
  buf = c;
  ret = write(1, &buf, 1);
  if (ret != 1) {
    return -1;
  }
  return c;
}
