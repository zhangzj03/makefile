makefile中:
OBJS = XXX.o \

CC = gcc

XXX : $(OBJS)
	$(CC) -o $@ $^

2)c++
CXX
CPLUS_INCLUDE_PATH是makefile中默认包含路径




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

对上述 增加 ||(defined(WIN32)) || (define(__WIN32__)) || (defined(__NT__))



#
二.具体文件(中期用#ifndef UNIXCON来屏蔽WINDOWS代码)
1.rtspapp/targetver.h修改(vc08下rtspApp.dll,现在librtsApp.so)
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
1)linux 没有CALLBACK __stdcall__

所以增加宏定义
#if  __WIN32_OS__
#define CALLBACK __stdcall
#elif __LINUX_OS__
#define CALLBACK
#endif
2)linux数据类型没有DWORD 
vs2005 08 为 typedef unsinged long DWORD (32bit)

所以linxu下若为设备
###################################
先定义为typedef unsing long DWORD





6.RtpSession.h
1)头文件的#ifndef 一定不要 写成#ifdef
否则包含不了RtpSession.h
且报  error: ISO C++ forbids declaration of ‘RtpSession’ with no type

2)RtpSession.h
	static DWORD WINAPI ThreadFunc的处理
	static DWORD WINAPI RecvProc的处理 

7.RtpSession.cpp
1)common.h中增加
#ifndef OutputDebugStringA
#define OutputDebugStringA(x) fprintf(stdout, x);
#endif


2)typedef int socklen_t
3)WSACleanup
释放套接字库,需要去除(看情况替换为 shutdown ,close) 

4)INVALID_SOCKET提换为 -1，或者<0;
windows下 定义为SOCKET（~0）,

5)WSAGetLastError,用errno代替

遗留问题
6)rtspsession中RecvProc中用到了很多winsock函数及winevent函数
WSANETWORKEVENTS
WSACREATEVENT
WSAJOINI
WSASocket及多播标示

WaitForSingleObject

7)GetLocalIPString中对网卡等信息的操作
PIP_ADAPTER_INFO
GetAdaptersInfo


8)函数名与类的成员函数名冲突
加成员域::符号

9)为 空指针

10)uint_ptr_t
/usr/include/stdint.h



7.RtspClient.cpp
1).屏蔽windows类型的头文件
2) 59行左右中间出现windows头文件 common.h strDup.h
3) strcpy 未发现 增加 "string.h"
4) 对OutPutDebugString加锁
5）对Sleep的处理
sleep,nanosleep,usleep,
6)对sockaddr_in的处理
i)linux: struct in_addr {
	               in_addr_t s_addr;
				              };
ii)windows:
typedef struct in_addr
{
	    union{
			            struct { unsigned char s_b1,s_b2,s_b3,s_b4; } S_un_b;
						            struct { unsigned short s_w1,s_w2; } S_un_w;
									            unsigned long S_addr;
												    }S_un;
}in_addr;

7）对transform的处理 
i) windows 下： transform调用 transform


8)
warning: cannot pass objects of non-POD type ‘struct std::string’ through ‘...’; call will abort at runtime
i) 这属于参数类型错误 ，fprintf里面需要参顺是char*类型，而不是string类型。string类型是c++的STL中的类型，它用于处理字符串。C语言中使用的字符串是C风格的字符串，即末尾以’\0‘字符为结束符。
2、string类型的字符串，可以调用其成员函数c_str()，来将string类型的对象转成C风格的字符串。这样就可以在printf后面输出string类型的变量了。


8.sys_inc.h


9.Rtp2H264.h 



10.Rtp2H264.cpp

11.SdpParse.h
12.SdpParse.cpp
TRACE();屏蔽


13.Socket.cpp 和Socket.h
1)GetLocalIP中用到
PIP_ADAPTER_INFO
GetAdaptersInfo 等window下的 Iphlpapi

用 UNIXCON来处理

14.Tcp.cpp Tcp.h
1)ioctlsocket 用的是 windows下的 
2)FIONBIO用的是windows下的

用 UNIXCON 屏蔽 

(三)StreamParse(原vc工程生成StreamParse.lib，现libStreamParse.so
1.FrameList.h
1)不用模板分离编译模式，
2.utils.h

##注意 StreamParse中模板与内嵌类实现的头文件的处理




(四)TPLayer的处理(原vc工程TPLayer.lib，现libTPLayer.so)
1.dh_atomin.h中
1)<linux/config.h>
未添加 ，找不到合适的，就屏蔽吧,
/home/zhangzhijie/work/hawk20161219/platform/hi3518c/uboot/include/linux/config.h
/home/zhangzhijie/work/hawk20161219/platform/hi3518c/uboot/arch/arm/include/asm/config.h
但有资料说被autoconf.h代替，路径如下 
/home/zhangzhijie/work/hawk20170111/platform/vc0718/kernel/include/generated/autoconf.h 
2)<linux/compiler.h>
/home/zhangzhijie/work/hawk20161219/platform/vc0718c/kernel/include/linux/compiler.h
/home/zhangzhijie/work/hawk20161219/platform/vc0718/kernel/include/linux/compiler.h

3)<asm/processor.h>
用kernel下的 
/home/zhangzhijie/work/hawk20170111/platform/vc0718/kernel/arch/arm/include

2.Global.h
1)应用OS_LINUX的宏定义

3.TPTypedef.h
1)整合linux版本与win版本TPTypedef.h
2)添加osIndependent.h
3)NAMSPACE_BEGIN的引用改为NAMSPACE_BEGIN()


4.ITPObject.h
1)用宏开关把俩个文件合并成一个，并未细分
2)NAMSPACE_BEGIN的引用改为NAMSPACE_BEGIN()

5.ITPObject.cpp
1)用宏开关把俩个文件合并成一个，并未细分
2)NAMSPACE_BEGIN的引用改为NAMSPACE_BEGIN()

6.TPUDPClient.h
7.TPUDPClient.cpp
TPUDPClient::onIOData中this->m_listener->onData(mEngineId, nConnId, buffer, nRecvLen);改为
TPUDPClient::onIOData中this->m_listener->onData(mEngineId, nConnId, (const char *)buffer, nRecvLen);

2)


/usr/bin/ld: TPUDPClient.o: relocation R_X86_64_PC32 against undefined symbol `(anonymous namespace)::ITPObject::ITPObject()' can not be used when making a shared object; recompile with -fPIC
/usr/bin/ld: final link failed: Bad value
collect2: ld returned 1 exit status
make: *** [libTpLayer.so] Error 1
处理方法，把ITPObject.h与ITPObject.cpp ,TPUDPClient.h TPUDPClient.cpp, ITPListener.h的NAMSPACE_BEGIN及NAMSPACE_END去掉，








8.ITPListener.h
1)修改onDealData();
2)注意onData(int nEngineId, int nConnId, const unsigned char * data, int nLen)中第三个参数，const unsigned char *



9.TPTCPClient.h

10.TPTCPClient.cpp


11.Referable.h
1)命名空间处理
2)差异函数处理
较少，直接合并

12.AutoBuffer.h
1)注意:AutoBuffer.h中用到了using namespace DHTools;命名空间，前有定义此命名空间 ，
因目前屏蔽掉未出现问题，所以先屏蔽掉。但应考虑后续出问题的可能
2)BASIC_CLASS处理
在BASIC.h中定义，先屏蔽掉


13.AutoBuffer.cpp
1)合并win32与linux


14.atomiccount.h中
1)去除NAMESPACE_BEGIN(DHTools)的定义

15.atomicccount.cpp中
1)去除NAMESPACE_BEGIN(DHTools)的定义



16.ReadWriteMutex.cpp
1)屏蔽NAMESPACE_BEGIN(DH_TOOLS)
2)屏蔽NAMESPACE_END函数

17.ReadWriteMutex.h
1)屏蔽NAMESPACE_BEGIN(DH_TOOLS)
2)屏蔽NAMESPACE_END函数

18.TPServer.h
1)用宏合并win32版本和linux版本TPServer.h
2)去除NAMESPACE_BEGIN与NAMESPACE_END宏

19.TPServer.cpp



20.TPMulticastClient.h
1)win32与因为定义相同
2)去掉TPUDPClient.h的NAMESPACE_BEGIN与NAMESPACE_END的定义


20.TPMulticastClient.cpp
1)用宏定义OS_LINUX,OS_WIN32合并两个文件
2）屏蔽stdafx.h,注意在实际联调过程中，此文件是否会产生影响
3)处理匿名空间的影响。



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

