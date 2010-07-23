#include <ruby.h>
#include <version.h>
#include "narray.h"
#include "narray_config.h"

static VALUE
str_new4 (VALUE str)
{
  StringValue (str);
  if (FL_TEST (str, ELTS_SHARED))
    {
      rb_str_buf_cat2 (str, "");	/* unanchor literal string */
    }
  return rb_str_new4 (str);
}

static VALUE
na_s_str (int argc, VALUE * argv, VALUE klass)
{
  struct NARRAY *ary;
  VALUE v;
  VALUE str;
  int i, type, len = 1, str_len, *shape, rank = argc - 2;

  if (argc < 1)
    rb_raise (rb_eArgError, "String Argument required");

  if (argc < 2)
    rb_raise (rb_eArgError, "Type and Size Arguments required");

  type = na_get_typecode (argv[1]);
  str = str_new4 (argv[0]);
  str_len = RSTRING (str)->len;

  if (argc == 2)
    {
      rank = 1;
      shape = ALLOCA_N (int, rank);
      if (str_len % na_sizeof[type] != 0)
	rb_raise (rb_eArgError, "string size mismatch");
      shape[0] = str_len / na_sizeof[type];
    }
  else
    {
      shape = ALLOCA_N (int, rank);
      for (i = 0; i < rank; i++)
	len *= shape[i] = NUM2INT (argv[i + 2]);
      len *= na_sizeof[type];
      if (len != str_len)
	rb_raise (rb_eArgError, "size mismatch");
    }

  v = na_make_object (type, rank, shape, cNArray);
  GetNArray (v, ary);
  ary->ptr = RSTRING (str)->ptr;
  ary->ref = str;

  return v;
}

void
Init_na_str ()
{
  rb_require ("narray");
  rb_define_singleton_method (cNArray, "str", na_s_str, -1);
  rb_define_singleton_method (cNArray, "from_string", na_s_str, -1);
}
