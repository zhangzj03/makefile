
OBJS = XXX.o \

CC = gcc

XXX : $(OBJS)
	$(CC) -o $@ $^





netsdk
一.先把每个文件编译过 
1.linux下区分大小写,Linux系统下文件名是区分大小写的，文件名采用大小写是不一样的；linux变量、命令、命令参数都是区分大小写的。
可以追溯到linux系统的开发，linux的内核是使用C语言开发的，C语言区分大小写。所以linux也区分大小写了。
2.宏定义， sys_inc.h
3.每个头文件加 sys_inc.h

#if (defined _WIN32) || (defined _WINDOWS_)
#difine __WIN32_OS__ 1
#define __VXWORKS_OS__ 0
#define __LINUX_OS__ 0
#else
#difine __WIN32_OS__ 0
#define __VXWORKS_OS__ 0
#define __LINUX_OS__ 1
#endif 

二.具体文件
1.rtspapp/targetver.h修改
1)统一用#ifndef 



2.rtspapp/include/typedef.h
1)增加typedef int BOOL;
 Linux 没有bool 
2)增加typedef void *HANDLE;
3)#define LPVOID void *

3.respapp/include/commonhead.h
1)增加#include <netinet/in.h>
