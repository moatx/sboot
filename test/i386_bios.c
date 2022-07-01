/*-
 * This is free and unencumbered software released into the public domain.
 *
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 *
 * In jurisdictions that recognize copyright laws, the author or authors
 * of this software dedicate any and all copyright interest in the
 * software to the public domain. We make this dedication for the benefit
 * of the public at large and to the detriment of our heirs and
 * successors. We intend this dedication to be an overt act of
 * relinquishment in perpetuity of all present and future rights to this
 * software under copyright law.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * For more information, please refer to <http://unlicense.org/>
 */

void kmain(void);
void bro(void);
static void cls(void);
static void test_print(char* str);
static unsigned int char_loc = 0;

#define cons_buf (volatile char*)0xB8000
#define black 0x07


/* this test code will be booted by sboot for i386 legacy bios */

void
bro(void)
{
	test_print("bro");
}

void
kmain(void)
{
	cls(); /* clear the screen */
	test_print("Hello from kernel space\n");
	test_print("we have been loaded by sboot :)");
}

static void
cls(void)
{
	int j = 0;
	volatile char *txt = cons_buf;

	while (j < 80 * 25 * 2) {
		txt[j] = ' ';
		txt[j + 1] = black;
		j = j + 2;
	}
}

static void
test_print(char* str)
{
	unsigned int l = 0;
	volatile char *txt = cons_buf;
	while (str[l] != '\0') {
		if (str[l] == '\n') {
			char_loc = char_loc + (160 - (char_loc % 160));
		} else if (str[l] >= ' ') {
			txt[char_loc++] = str[l];
			txt[char_loc++] = black;
		}
		++l;
	}
}
