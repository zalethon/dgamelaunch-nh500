dnl Use autoconf 2.53
dnl (Things tend to break across versions, they're neither upwards nor
dnl downward compatible. Blame GNU.)

AC_INIT([dgamelaunch],[1.5.1],[https://github.com/zalethon/dgamelaunch-nh500/issues])
AC_PREREQ([2.72])
AC_CONFIG_SRCDIR([dgamelaunch.c])
AC_CONFIG_HEADERS([config.h])
AC_PREFIX_DEFAULT([/])


# Testing the environment
AC_PROG_CC(cc gcc)
AC_PATH_PROG(MKDEP, mkdep)
AC_PATH_PROG(MAKEDEPEND, makedepend)

CCVERSION=`$CC -V 2>&1`
AC_MSG_CHECKING([dependency generation])
if test "$ac_cv_c_compiler_gnu" = yes; then
  CFLAGS="$CFLAGS -Wall -Wno-unused"
  MKDEP="$CC -MM"
  MKDEP_DIRECT="> .depend"
  AC_MSG_RESULT(gcc)
elif test -n "`echo "$CCVERSION" | grep -E ".*Sun.*Workshop.*|.*Forte.*Developer.*" -`"; then
  MKDEP="$CC -xM"
  # -xM is noisy
  MKDEP_DIRECT="> .depend 2>/dev/null"
  AC_MSG_RESULT([Solaris cc])
elif test -n "$MKDEP"; then
  AC_MSG_RESULT(mkdep)
elif test -n "$MAKEDEPEND"; then
  MKDEP=":> .depend; $MAKEDEPEND -f.depend"
  MKDEP_DIRECT=">/dev/null 2>&1" # noisy prick of a program
  AC_MSG_RESULT(makedepend)
else
  MKDEP=:
  AC_MSG_RESULT([nothing!])
fi
AC_SUBST(MKDEP)
AC_SUBST(MKDEP_DIRECT)

UNAME=`uname -s`
if test -n "`echo "$UNAME" | grep -E "Linux|\w*BSD" -`"; then
   MY_LIBS="$MY_LIBS -lutil -lcrypt"
   AC_DEFINE(NOSTREAMS, 1, [Do not use SVR4 streams support in ttyrec.])
fi

AC_CHECK_HEADER_STDBOOL
AC_TYPE_UID_T
AC_TYPE_INT16_T
AC_TYPE_INT32_T
AC_TYPE_INT8_T
AC_TYPE_MODE_T
AC_TYPE_OFF_T
AC_TYPE_PID_T
AC_TYPE_SIZE_T
AC_TYPE_UINT16_T
AC_TYPE_UINT32_T
AC_TYPE_UINT8_T
AC_CHECK_TYPES([ptrdiff_t])

# Checking more programs
AC_PROG_LN_S
AC_PROG_INSTALL
AC_PROG_LEX(yywrap)
AC_PROG_YACC

if test ! -x "`which $LEX`"; then AC_MSG_ERROR([lex or flex not found.]); fi
LEXLIBS="$LEXLIB"
if test ! -x "`which $YACC`"; then AC_MSG_ERROR([bison or yacc not found.]); fi

# Checking libraries, headers, library functions
AC_FUNC_ALLOCA
AC_CHECK_HEADERS([fcntl.h inttypes.h libintl.h malloc.h stdint.h sys/ioctl.h sys/param.h sys/pstat.h sys/time.h termios.h unistd.h])
AC_FUNC_FORK
AC_FUNC_FSEEKO
AC_FUNC_MALLOC
AC_FUNC_REALLOC
AC_FUNC_WAIT3
AC_CHECK_FUNCS([alarm atexit dup2 ftruncate gettimeofday kqueue memmove memset mkdir openpty pstat putenv setenv setproctitle select setlocale strcasecmp strchr strdup strerror strncasecmp strstr strtoul])
AC_CHECK_LIB(pthread, pthread_create, [], [AC_MSG_ERROR([need pthreads])])
AC_SEARCH_LIBS(use_default_colors, [ncursesw],
[
   AC_MSG_RESULT([Using ncursesw and color.])
   AC_DEFINE(USE_NCURSES_COLOR,1,[Use ncursesw and color])
],
[
   AC_MSG_RESULT([Not using ncursesw, not using color.])
])

AC_SEARCH_LIBS(initscr, [ncursesw cursesw], [], [
   AC_MSG_ERROR([Cannot find cursesw or ncursesw devel libs.])
])

AC_MSG_CHECKING([if we need to replace setproctitle])
if test "$ac_cv_func_setproctitle" = no; then
  AC_MSG_RESULT("using included stproctitle.c")
  SETPROCTITLE_C=setproctitle.c
  if test "$ac_cv_func_pstat" = yes; then
    AC_DEFINE(SPT_TYPE,SPT_PSTAT,[Type of setproctitle emulation to use.])
  else
    AC_DEFINE(SPT_TYPE,SPT_REUSEARGV)
  fi
else
  AC_MSG_RESULT("Using system's setproctitle")
  SETPROCTITLE_C=""
fi

# Arguments

# --enable-options
AC_ARG_ENABLE(debugfile,
[AS_HELP_STRING([--enable-debugfile],[Enable debugging output to a file.])],
[], [])

if test "$enable_debugfile" = yes; then
   AC_MSG_RESULT([Enabling debugging output to a file.])
   AC_DEFINE(USE_DEBUGFILE,1,[Output debugging into to a file in chroot.])
fi

AC_ARG_ENABLE(sqlite,
[AS_HELP_STRING([--disable-sqlite],[Use a flat file instead of SQLite for the database.])],
[enable_sqlite=no], [enable_sqlite=yes])

AC_ARG_ENABLE(shmem,
[AS_HELP_STRING([--disable-shmem],[Disable shared memory; used for # of watchers on watch menu.])],
[enable_shmem=no], [enable_shmem=yes])

if test "$enable_shmem" = yes; then
   AC_CHECK_HEADERS([semaphore.h], [], [AC_MSG_ERROR([semaphore.h not found. Disable shmem.])], [])
   AC_CHECK_HEADERS([sys/ipc.h], [], [AC_MSG_ERROR([sys/ipc.h not found. Disable shmem.])], [])
   AC_CHECK_HEADERS([sys/shm.h], [], [AC_MSG_ERROR([sys/shm.h not found. Disable shmem.])], [])
   AC_MSG_RESULT([Enabled showing number of watchers.])
   AC_DEFINE(USE_SHMEM,1,[Use shared memory block])
   MY_LIBS="$MY_LIBS -lrt"
   # or -pthread?
fi

AC_ARG_VAR([CHROOT], [The location of the chroot])
if test -z "CHROOT"; then
  CHROOT=${HOME}/dgl-chroot
fi
AC_ARG_VAR([dgl_sqlite_db], [The absolute path and filename for the sqlite db.])
AC_SUBST(CHROOT)
AC_SUBST(dgl_sqlite_db)
if test "$enable_sqlite" = yes; then
   if test -z "$dgl_sqlite_db"; then
     dgl_sqlite_db=[dgamelaunch.db]
   fi
   AC_DEFINE([USE_SQLITE3],1,[Use SQLite for the database instead of flat text file.])
   MY_LIBS="$MY_LIBS -lsqlite3"
   AC_DEFINE_UNQUOTED(USE_SQLITE_DB, "$dgl_sqlite_db", [Path and filename of the SQLite database.])
fi

dgl_rlimit_core_default=157286400
AC_ARG_WITH(rlimit-core,
[AS_HELP_STRING([--with-rlimit-core=SIZE],[Enable and set the core dump maximum size.])],
[dgl_rlimit_core=$withval; enable_rlimit=yes], [dgl_rlimit_core=$dgl_rlimit_core_default])
if test "$enable_rlimit" = yes; then
   if test "$dgl_rlimit_core" = yes; then
      dgl_rlimit_core=$dgl_rlimit_core_default
   fi
   AC_CHECK_HEADERS([sys/resource.h], [], [AC_MSG_ERROR([sys/resource.h not found.])], [])
   AC_MSG_RESULT([Enabled and set maximum core dump size to $dgl_rlimit_core])
   AC_DEFINE(USE_RLIMIT,1,[Use getrlimit/setrlimit])
   AC_DEFINE_UNQUOTED(USE_RLIMIT_CORE, $dgl_rlimit_core, [Maximum core dump size])
   enable_rlimit=no
fi

dgl_rlimit_as_default=104857600
AC_ARG_WITH(rlimit-as,
[AS_HELP_STRING([--with-rlimit-as=SIZE],[Enable and set the maximum memory usage.])],
[dgl_rlimit_as=$withval; enable_rlimit=yes], [dgl_rlimit_as=$dgl_rlimit_as_default])

if test "$enable_rlimit" = yes; then
   if test "$dgl_rlimit_as" = yes; then
      dgl_rlimit_as=$dgl_rlimit_as_default
   fi
   AC_CHECK_HEADERS([sys/resource.h], [], [AC_MSG_ERROR([sys/resource.h not found.])], [])
   AC_MSG_RESULT([Enabled and set maximum memory usage limit to $dgl_rlimit_as])
   AC_DEFINE(USE_RLIMIT,1,[Use getrlimit/setrlimit])
   AC_DEFINE_UNQUOTED(USE_RLIMIT_AS, $dgl_rlimit_as, [Maximum mem usage])
   enable_rlimit=no
fi

AC_ARG_WITH(config-file,
[AS_HELP_STRING([--with-config-file=PATH],[Define the path to the default configuration file.])],
[configfile=$withval], [configfile="/etc/dgamelaunch.conf"])
AC_DEFINE_UNQUOTED(DEFCONFIG, "$configfile", [Path to the default config file.])

LIBS="$LIBS $MY_LIBS"

AC_SUBST(SETPROCTITLE_C)
AC_SUBST(LEXLIBS)

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
