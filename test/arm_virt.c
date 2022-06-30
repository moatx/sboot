/*#include <stdint.h>*/

volatile unsigned char *uart = (volatile unsigned char *)0x09000000;

static void test_print(const char *s);
void main(void);

void
main(void)
{
	test_print("Hello world!\n");
}

static void
test_print(const char *s)
{
	while (*s != '\0') {
		uart = *s;
		s++;
	}
}
