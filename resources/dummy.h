// -> module dummy;

#define MACRO_VAL 1 /* -> const MACRO_VAL = 1; */
#define MACRO_FUN(base) base##t // unchanged

int f(float a, double);

#define ATTRIB inline

struct Sa {
  double f;
};

ATTRIB void g(struct S asd);
