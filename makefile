
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


4.include/RtspClient.h中

typedef enum 原名 {
	
} 新名；
新名一定要加，否则报 warning


5.include/common.h
linux 没有CALLBACK __stdcall__

所以增加宏定义
#if  __WIN32_OS__
#define CALLBACK __stdcall
#elif __LINUX_OS__
#define CALLBACK
#endif

6.RtpSession.h
头文件的#ifndef 一定不要 写成#ifdef
否则包含不了RtpSession.h
且报  error: ISO C++ forbids declaration of ‘RtpSession’ with no type



文件编辑
1.去掉
三种行尾格式如下:
unix : \n
dos: \r\n
mac : \r
这意味着，如果你试图把一个文件从一种系统移到另一种系统，那么你就有换行符方面的麻烦。 
因为MS-DOS及Windows是回车＋换行来表示换行，因此在Linux下用Vim查看在Windows下写的代码，行尾后“^M”符号。 
在Vim中解决这个问题，很简单，在Vim中利用替换功能就可以将“^M”都删掉，键入如下替换命令行： 
:%s/^M//g
注意： 
上述命令行中的“^M”符，不是“^”再加上“M”，而是由“Ctrl+v”、“Ctrl+M”键生成的，或者Ctrl+v，再按回车。 
或者使用这个命令： 
:% s/\r//g

