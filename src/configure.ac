dnl Use autoconf 2.53
dnl (Things tend to break across versions, they're neither upwards nor
dnl downward compatible. Blame GNU.)

AC_INIT([dgamelaunch],[1.5.1],[https://github.com/zalethon/dgamelaunch-nh500/issues])
AC_PREREQ([2.72])
AC_CONFIG_SRCDIR([dgamelaunch.c])
AC_CONFIG_HEADERS([config.h])
AC_PREFIX_DEFAULT([/])

AC_PROG_CC(cc gcc)
AC_PATH_PROG(MKDEP, mkdep)
AC_PATH_PROG(MAKEDEPEND, makedepend)
AC_PROG_LN_S
AC_PROG_INSTALL
AC_PROG_LEX(yywrap)
AC_PROG_YACC
if test ! -x "`which $LEX`"; then AC_MSG_ERROR([lex or flex not found.]); fi;
if test ! -x "`which $YACC`"; then AC_MSG_ERROR([bison or yacc not found.]); fi;

# Check headers/types
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

# Checking functions
AC_FUNC_ALLOCA
AC_CHECK_HEADERS([fcntl.h inttypes.h libintl.h malloc.h stdint.h sys/ioctl.h sys/param.h sys/pstat.h sys/time.h termios.h unistd.h])
AC_FUNC_FORK
AC_FUNC_FSEEKO
AC_FUNC_MALLOC
AC_FUNC_REALLOC
# We need wait to fill in rusage, so must keep using AC_FUNC_WAIT3 even though it's not POSIX
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

#### Arguments to ./configure
AC_ARG_VAR([CHROOT], [The location of the chroot. Default ~/dgl-chroot])
AC_ARG_VAR([RLIMIT_CORE_MAX], [Set the core dump maximum size in bytes. Default 150Mb. Irrelevant if --enable-rlimit is not passed.])
AC_ARG_VAR([RLIMIT_MAX_MEMORY], [Set the maximum memory usage in bytes. Default 100Mb. Irrelevant if --enable-rlimit is not passed.])
AC_ARG_VAR([COMPRESSBIN], [The compress binary to be copied for NetHack])
AC_ARG_VAR([GREPBIN], [The grep bin to be copied flr dgamelaunch])

AC_ARG_ENABLE(sqlite,
[AS_HELP_STRING([--disable-sqlite],[Use a flat file instead of SQLite for the database.])],
[enable_sqlite=no], [enable_sqlite=yes])

AC_ARG_ENABLE(shmem,
[AS_HELP_STRING([--disable-shmem],[Disable shared memory; used for # of watchers on watch menu.])],
[enable_shmem=no], [enable_shmem=yes])

AC_ARG_ENABLE(debugfile,
[AS_HELP_STRING([--enable-debugfile],[Enable debugging output to a file.])],
[enable_debug=yes], [enable_debug=$enableval])

AC_ARG_ENABLE(rlimit,
[AS_HELP_STRING([--enable-rlimit],[Enable core dumps(?)])],
[enable_rlimit=no], [disable_rlimit=$enableval])

#### Logic to deal with arguments
# eg setting defaults, creating DEFINEs and so-called precious variables,
# perorming extra checks in case 

## Defaults arg vars
# CHROOT defaults = ${HOME}/dgl-chroot (check /root/dgl-chroot, root's home)
test -z "$CHROOT" && CHROOT=${HOME}/dgl-chroot || :;
# RLIMIT_CORE_MAX default = 150Mb
test -z "$RLIMIT_CORE_MAX" && RLIMIT_CORE_MAX=157286400 || :;
# RLIMIT_MAX_MEMORY default = 100Mb
test -z "$RLIMIT_MAX_MEMORY" && RLIMIT_MAX_MEMORY=104857600 || :;
# COMPRESSBIN default = gzip
test ! -x "`which "$COMPRESSBIN"`" || COMPRESSBIN=`which gzip` && :;
# GREPBIN default = grep
test ! -x "`which $GREPBIN`" || GREPBIN=`which grep` && :;

## Logic for 
if test "$enable_sqlite" = yes; then
   AC_DEFINE([USE_SQLITE3],1,[Use SQLite for the database instead of flat text file.])
   AC_DEFINE_UNQUOTED([USE_SQLITE_DB], "${CHROOT}${prefix}var/dgamelaunch.db", [Filename of the SQLite database.])
   MY_LIBS="$MY_LIBS -lsqlite3"
fi

if test "$enable_debugfile" = yes; then
   AC_DEFINE(USE_DEBUGFILE,1,[Output debugging into to a file in chroot.])
fi

if test "$enable_shmem" = yes; then
   AC_CHECK_HEADERS([semaphore.h], [], [AC_MSG_ERROR([semaphore.h not found. Disable shmem.])], [])
   AC_CHECK_HEADERS([sys/ipc.h], [], [AC_MSG_ERROR([sys/ipc.h not found. Disable shmem.])], [])
   AC_CHECK_HEADERS([sys/shm.h], [], [AC_MSG_ERROR([sys/shm.h not found. Disable shmem.])], [])
   AC_MSG_RESULT([Enabled showing number of watchers.])
   AC_DEFINE(USE_SHMEM,1,[Use shared memory block])
   MY_LIBS="$MY_LIBS -lrt"
   # or -pthread?
fi

if test "$enable_rlimit" = yes; then
   AC_CHECK_HEADERS([sys/resource.h], [], [AC_MSG_ERROR([sys/resource.h not found.])], [])
   AC_DEFINE(USE_RLIMIT,1,[Use getrlimit/setrlimit])
   # Possibly we can't have both of these at once
   # They were originally exclusive
   # TODO: Look into that
   AC_DEFINE_UNQUOTED(USE_RLIMIT_CORE, $dgl_rlimit_core, [Maximum core dump size])
   AC_DEFINE_UNQUOTED(USE_RLIMIT_AS, $dgl_rlimit_as, [Maximum mem usage])
   enable_rlimit=no
fi

if test "$ac_cv_func_setproctitle" = no; then
  SETPROCTITLE_C=setproctitle.c
  if test "$ac_cv_func_pstat" = yes; then
    AC_DEFINE(SPT_TYPE,SPT_PSTAT,[Type of setproctitle emulation to use.])
  else
    AC_DEFINE(SPT_TYPE,SPT_REUSEARGV)
  fi
else
  SETPROCTITLE_C=""
fi

# Check for system-specific dependency builder
UNAME=`uname -s`
if test -n "`echo "$UNAME" | grep -E "Linux|\w*BSD" -`"; then
   MY_LIBS="$MY_LIBS -lutil -lcrypt"
   AC_DEFINE(NOSTREAMS, 1, [Do not use SVR4 streams support in ttyrec.])
fi
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

####
# Now it's just making magic variables (afaic) and defining other output for
# the Makefile...
LIBS="$LIBS $MY_LIBS"
LEXLIBS="$LEXLIB"
AC_DEFINE_UNQUOTED(DEFCONFIG, "$CHROOT$prefix/etc/dgamelaunch.conf", [Path to the default config file.])
AC_SUBST(CHROOT)
AC_SUBST(dgl_sqlite_db)
AC_SUBST(MKDEP)
AC_SUBST(MKDEP_DIRECT)
AC_SUBST(SETPROCTITLE_C)
AC_SUBST(LEXLIBS)
AC_SUBST(GREPBIN)
AC_SUBST(COMPRESSBIN)

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
