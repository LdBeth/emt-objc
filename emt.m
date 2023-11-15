/* Copyright (c) 2023 LdBeth
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 3 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * GNU Emacs; see the file COPYING.  If not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
 * USA.
 */
#import <Foundation/Foundation.h>
#import <NaturalLanguage/NaturalLanguage.h>
#include "emacs-module.h"

#define DEFUN(lsym, csym, amin, amax, doc, data) \
  bind_function (env, lsym, \
         env->make_function (env, amin, amax, csym, doc, data))

#define VMAKE(len) make_vector(env, len)
#define VSET(vec, idx, val) env->vec_set(env, vec, idx, val)

#define CONS(a, b) make_cons(env, a, b)

#define QINT(x) env->make_integer(env, x)

int plugin_is_GPL_compatible;

static void bind_function (emacs_env *env, const char *name, emacs_value Sfun)
{
  /* Set the function cell of the symbol named NAME to SFUN using
     the 'fset' function.  */

  /* Convert the strings to symbols by interning them */
  emacs_value Qfset = env->intern (env, "fset");
  emacs_value Qsym = env->intern (env, name);

  /* Prepare the arguments array */
  emacs_value args[] = { Qsym, Sfun };

  /* Make the call (2 == nb of arguments) */
  env->funcall (env, Qfset, 2, args);
}

static emacs_value make_vector (emacs_env *env, int len) {
  emacs_value Qmake_vector = env->intern(env, "make-vector");
  emacs_value Qnil = env->intern(env, "nil");
  emacs_value length = QINT(len);

  emacs_value args[] = { length, Qnil };
  return env->funcall(env, Qmake_vector, 2, args);
}

static emacs_value make_cons (emacs_env *env, emacs_value a, emacs_value b) {
  emacs_value Qcons = env->intern(env, "cons");

  emacs_value args[] = { a, b };
  return env->funcall(env, Qcons, 2, args);
}

static emacs_value tokensForRange (emacs_env *env,
                                   ptrdiff_t nargs, emacs_value args[],
                                   void *data) {

  emacs_value lstring = args[0];
  ptrdiff_t strlen;

  /* Get string length */
  env->copy_string_contents(env, lstring, NULL, &strlen);
  /* Copy string */
  char* sdata = malloc(strlen);
  env->copy_string_contents(env, lstring, sdata, &strlen);
  emacs_value result;
  @autoreleasepool {
    NLTokenizer* tokenizer = [[[NLTokenizer alloc]
                                initWithUnit: NLTokenUnitWord] autorelease];
    NSString *string = [[[NSString alloc]
                          initWithBytesNoCopy: sdata
                                       length: strlen
                                     encoding: NSUTF8StringEncoding
                                 freeWhenDone: YES] autorelease];

    tokenizer.string = string;
    NSArray* ranges = [tokenizer
                        tokensForRange:NSMakeRange(0, [string length])];
    result = VMAKE([ranges count]);

    int i = 0;
    int a, b;
    for (NSValue* value in ranges) {
      NSRange r = value.rangeValue;
      a = r.location;
      b = r.location + r.length;
      VSET(result, i, CONS(QINT(a), QINT(b)));
      i++;
    }
  }
  return result;
}

static emacs_value tokenRangeAtIndex (emacs_env *env,
                                      ptrdiff_t nargs, emacs_value args[],
                                      void *data) {
  emacs_value lstring = args[0];
  NSUInteger pos = env->extract_integer(env, args[1]);
  ptrdiff_t strlen;

  /* Get string length */
  env->copy_string_contents(env, lstring, NULL, &strlen);
  /* Copy string */
  char* sdata = malloc(strlen);
  env->copy_string_contents(env, lstring, sdata, &strlen);
  emacs_value result;
  @autoreleasepool {
    NLTokenizer* tokenizer = [[[NLTokenizer alloc]
                                initWithUnit: NLTokenUnitWord] autorelease];
    NSString *string = [[[NSString alloc]
                          initWithBytesNoCopy: sdata
                                       length: strlen
                                     encoding: NSUTF8StringEncoding
                                 freeWhenDone: YES] autorelease];

    tokenizer.string = string;
    NSRange r = [tokenizer tokenRangeAtIndex:pos];

    int a, b;
    a = r.location;
    b = r.location + r.length;
    result =  CONS(QINT(a), QINT(b));
  }
  return result;
}

int emacs_module_init (struct emacs_runtime *runtime) {
  if (runtime->size < sizeof (*runtime))
    return 1;

  emacs_env *env = runtime->get_environment(runtime);

  DEFUN("emt--do-split-helper", \
        tokensForRange, 1, 1, "Tokenize ARG1 into a list of ranges.\n\n" \
        "Return an array of (BEGIN . END).\n", NULL);

  DEFUN("emt--word-at-point-or-forward-helper", \
        tokenRangeAtIndex, 2, 2, \
        "Return the range of current word at ARG2 in ARG1.\n", NULL);

  emacs_value feature = env->intern(env, "emt-helper");
  emacs_value Qprovide = env->intern(env, "provide");

  emacs_value args[] = { feature };
  env->funcall(env, Qprovide, 1, args);
  return 0;
}
