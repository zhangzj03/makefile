makefile中:
OBJS = XXX.o \

CC = gcc

XXX : $(OBJS)
	$(CC) -o $@ $^
1)







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

(三)StreamParse(原vc工程生成StreamParse.lib, 为静态库，现libStreamParse.so
1.FrameList.h
1)不用模板分离编译模式，
2.utils.h

##注意 StreamParse中模板与内嵌类实现的头文件的处理




(四)TPLayer的处理(原vc工程TPLayer.lib,为静态库，现libTPLayer.so)
1.dh_atomic.h中
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


4)移到arm下时，借用placeform/common/sofia/core/SDK/netsdk/common/dh_atomic.h
注意区别
5)atomiccount.h和cpp文件也换成上述路径下的

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
Arm:
2)更换为hawk下的文件

15.atomicccount.cpp中
1)去除NAMESPACE_BEGIN(DHTools)的定义
Arm:
2)更换为hawk下的文件



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


(五).dhdvr(原vc公程(netsdk)生成libcom.dll,且依赖TPLayer.lib,和rtspApp.dll库,linux版本生成libcom.so)
1.ParaTimerImp.cpp 

1)dh_atomic.h
(1)<linux/config.h>
未添加 ，找不到合适的，就屏蔽吧,
/home/zhangzhijie/work/hawk20161219/platform/hi3518c/uboot/include/linux/config.h
/home/zhangzhijie/work/hawk20161219/platform/hi3518c/uboot/arch/arm/include/asm/config.h
但有资料说被autoconf.h代替，路径如下 (**在此工程中用autoconf.h代替***)
/home/zhangzhijie/work/hawk20170111/platform/vc0718/kernel/include/generated/autoconf.h 

(2)<linux/compiler.h>
/home/zhangzhijie/work/hawk20161219/platform/vc0718c/kernel/include/linux/compiler.h
/home/zhangzhijie/work/hawk20161219/platform/vc0718/kernel/include/linux/compiler.h

(3)<asm/processor.h>
用kernel下的 
/home/zhangzhijie/work/hawk20170111/platform/vc0718/kernel/arch/arm/include

arm:
4)更换为hawk下的

2.ParaTimer.h
1)增加头文件 #include "osIndependent.h"


3.Global.h
1）放开template <> class CUintForSize<8>
且 {public: typedef uint64 Type};改为{public: typedef __int64 Type}
2)增加 
//typedef long long __int64;
#define __int64 long long
4.windows版本 osIndependent.cpp osIndependent.h 与linux版本的有些许差异，但移植版本时 未考虑差异。
1)dh_atomic.h与最早版本的linux版本中atomic.h对应 

2)osIndependent.h中增加 
#define __int64 long long



5.dvrchannel
1)目前有windows和linux两个版本及两个架构，且parent class不一样。暂时基于windows修改，因为windows的架构目前与winAPI关联不大。且使用过程中成熟.linux架构没有使用过，且需要完善。
补充:
2),1)的方案有些行不通了，在移植过程中发现从16开始及9.dvrdevice开始不能基于windows一种修改，因为后编译也涉及到linux版本的内容，所以还需宏定义隔离合并。
3)添加connect.h的头文件,因为linux版本的用到


6.TcpSocket.h
1)WIN32宏定义
2)TPLayer层的头文件包含处理 
3)原linux版本与windows版本中关于宏定义有差异 
(1)windows版本比linux版本的数值 要大 
(2)linux版本比windows版本多了两个成员函数
SetSubReconnect和WriteDataNow,在移植新的 linux版本工程时，因没有winAPI关联，目前基于新的windows工程移植linux,并未加入这两个 成员函数。


补充:
4)根据16.以后的处理，还是先用宏定义隔离合并.
5)protected,private也不一样


7.处理新的Global.h,与osIndependent.h文件。
此两个文件在TPLayer和netsdk中同时出现。


8.TPTypedef.h
1)netsdk中一些 头文件调用了TPTypedef.h，但AutoBuffer.h找不到。加寻找路径即可处理


9.dvrdevice.h
1)去除 using namespace DHTOOls;
补充:
2）用宏定义合并windows版本和Linux代码吧，从16后边整合时发现，存在宏定义重复定义，且定义内容有差异，盘根错节，你中有我，我中有你，且各有特色。先编译通过，再合并代码
3)在1）中是基于windows版本处理，为了编译通过，先采用2）中提出的方案。
4)linux版本与windows版本的基类4)linux版本与windows版本的基类4)linux版本与windows版本的基类4)dvrdevice的linux版本与windows版本的基类侧重完全不同，linux版本的基类只侧重于断开连接，而windows版本基类则侧重于获取设备端的各种信息.
5)linux版本用到SocketCallBack.h的OnSubReconnect函数，window没有




10.dhdvr2cfg.h
1)有两个结构体与linux内核中的冲突，需要改名
CONFIG_NET改为sCONFIG_NET
CONFIG_ETHERNET改为sCONFIG_ETHERNET
2)最好linux版本与window版本整合，目前用ifdef win32宏定义整合，后期代码合并为一份代码。(与!2000处对应)



11.UdpSocket.cpp
1）UdpSocket继承了TPLayer工程中的两个类,TPUDPCLient和ITPListener
2)UdpSocket实现了 ITPListener类中的纯虚函数UdpOnData 和OnDealData，但由于UdpSocket是基于windows版本的工程修改了，而ITPListener是基于Llinux版本工程修改的,上述两个函数在window和linux两个工程中，虽然函数名相同，但参数类型及个数不相同，导致无法实例话。
可修改函数，但注意是否会对后续其他派生类产生影响。


12.CMultiCastSocket
1)与UdpSocket 同样的问题
2)代码基本一样，参数名称差异，类型一样


13.dvrinterface（Llinux版本中没有此文件）
1)因为此类应用了dvrdevice与dvrchannel， 后两者移植中的问题得到了解决，dvrinterface也相应的得到了处理。


14.dhmutex
1)需要整合linux版本和window版本
2)linux版本中的有CAutoMutex, windows中没有，但linux版本中在Client_SDK中的RtspServer中有调用a。
3)pthread_mutexattr_t中并没有__mutexkind成员(已查内核)，需移植linux版本
4)包含Basic.h


15.BitStatictics
1)有linux和windows两个版本
用win32和else合并两个文件


16.关于channel及其子类的移植
17.dvrsnapchannel
1)调用libmodel.h时,linux与window版本差异较大.
2)dhdvr2cfg.h中window版本 与linux版本有枚举定义冲突,需要用ifdef win32宏定义分离
(见!2000处)

18.dvrpacket_dvr2.h 及cpp
1)宏定义隔离合并.
2)服务器版本与PC(180)版本有差异。


19.SocketCallBack.h和cpp
1)linux版本比windows多的函数:
OnSubReconnect
2)cpp函数windows和linux差异不大，目前仍用宏定义隔离合并，后期考虑如何合并

20.afcinc.h
合并linux和windows，引文件较小，逐行合并
1)linux和windows版本afk_record_file_info_s有差异
2)linux版本没有afk_record_file_info_s_ex
3)afk_alarm_trriger_mode_info linux版本和windows版本定义的变量数目不同。
linux的为32个，windows的为16个
4)afk_dev_cap_s结构体变量int和 long类型不同: 
5)afk_media_channel_param_s,类型不同
6)PTZControlType
7)afx_snap_channel_param_s差异
8)typedef enum afk_device_info_type成员数量及顺序
9)GPSRevCallback：服务器版本与本地win7操作系统上的版本不同。变量数目及类型不同


21.osIndependent.h
1.windows版本在三个地方有此头文件，netsdk_vs2008\netsdk\netsdk;netsdk_vs2008\Client_SDK
;netsdk_vs2008\TPLayer\include
window下不同的工程，不会产生冲突，但Llinux下会出现宏定义重复定义，
1)屏蔽netsdk/netsdk/osIndepent.h中的RECT



22.dvralarmchannel(可逐行合并)


23.dvrcapturechannel()


23.backchannel
1）可逐行合并

24.StdAfx.h
1)太多的StdAfx.h头文件，宏定义最好不要放在StdAfx.h中，因为此文件并不是linux系统的固有文件
2)用户区 包含了内核文件，会保异常 

25.dvrsnapchannel_mobile.h
1)可逐行合并

26.dvrconfigchannel
1)可逐行合并


27.dvrdevice_DDNS
1)可逐行合并


28.dvrdevice_mobile
1)可逐行合并

29.dvrdownloadchannel
1)可逐行合并

30.dvrGpsChannel
1)可逐行合并

31.dvrGpsChannel_mobile
1)可逐行合并
2)注意cpp添加StdAfx.h头文件,否则会有宏未定义的error出现

32.dvrmediachannel
1)linux中open为虚函数 ；windows 中open_channel并不为虚函数
2)windows版本，服务器上NETRealDataCallBack函数和180上的此函数参数个数不一样。经确认，以考至于180上的为主

3)缺 rtspApp的linux版本（从刘工，刑工处已获取到）
4).cpp程序中未声明NO_MULTICAST，导致rtspApp.h的头文件未包含进去，但注意linux版本和windows版本的rtspApp.h的路径不同，需要注意相对路径的处理


33.dvrpacket_comm
1)可逐行合并
2）服务器与180上的 windows版本有差异，180上的有sendUserMsg_comm函数,补充此函数
3)注意DWORD UInt32数据类型定义
unsigned long; unsigned int


34.dvrpacket_dvr2
1)可逐行合并

35.dvrpacket_mobile.o
1)可逐行合并

36.dvrpreviewchannel
1)可逐行合并


37.dvrrawchannel
1)可逐行合并

38.dvrsearchchannel
1)可逐行合并.h文件
2）用宏定义隔离合并.cpp因为细节较多。
3)ReadWriteMutex.h头文件的包含,linux版本与windows版本的相对路径不同，linux版本去除较长的相对路径,直接采用#include "ReadWriteMutex.h"


39.dvrsearchchannel_DDNS
1)逐行合并


40.dvrstatiscchannel
1)逐行合并

41.dvrtalkchannel
1)可逐行合并

42.dvrtranschannel
1)可逐行合并

43.dvrupgradechannel
1)可逐行合并


44.dvruserchannel
1)可逐行合并


45.dvrusermsgchannel.h和cpp
1）服务器的linux版本和windows版本没有dvrusermsgchannel,而180上有
2）服务器的afkinc.h与180上的afkinc.h
（1）afk_usermsg_channel_s和afk_usermsg_channel_param_s名称及成员需 统一
3)LN_LIFECOUT的宏定义,linux下与windows下定义不同


46.dvrcap
1)几乎相同

47.dvrinterface
1)linux版本没有此文件，windows有,用WIN32 宏隔离。
2)直接合并

48.dhdvr
1)没有.h文件，只有.cpp
2)window和linux的差异较小，直接合并 


49.dhdevprob
1).h文件几乎一样，cpp文件差异较大，隔离合并法 
2)window没有VISSTcpSocket.h和cpp,而Linux的需要，所以从linux版本中cp这两个文件


50. SocketCallBack
1).h文件几乎一样
2）.cpp几乎一样 ，但量大，采用隔离合并
3)linux 版本的调用了Manager.h,SnapPicture.h
Windwos没有,去掉路径../
4)

51. CTcpSocket
1).h文件基本一致，函数参数名不同，访问类型不同
2).cpp文件，量较大，采用隔离合并

52. VISSTcpSocket
1)windows版本没有这两个文件，而linux需要，所以从linux版本中cp这两个文件。


六.Client_SDK
1.StdAfx.h:linux版本与windows版本的有差异
合并ClinetSdk\StdAfx.h



2.合并Manager(SocketCallBack用到)
1）.h文件隔离合并
2).cpp文件隔离合并
3)添加#include "dhmutex.h"
4)AutoBuffer.h
添加CPLUS_INCLUDE_TPLAYER_PATH路径
5)去除命名空间NAMESPACE_BEGIN
6)4096与4097行CONFIG_NET改为sCONFIG_NET,因为此名称与linux内核冲突,4120与4121同理

3.SnapPicture.h(SocketCallBack调用)
17周五，待周一补充
1)逐行合并

4.SnapPicture.cpp(SocketCallBack调用)
1)Windows版193和180有差异
SnapPictureQuery的参数intptr_t型和LONG型需要统一


5.dhmutex.cpp
1）pthread_mutexattr_t.__mutexkind，没有此成员变量
2)window版和linux版本在处理此pthread_mutexattr_t时有差异

6.AlarmDeal.h
1)对intptr_t的处理,windows先采用intptr_t，linux采用LONG
2)对st_Alarm_Info的处理
3)windows版本的afx_device_s与linux版本的CDvrDevic隔离整合

4)宏定义加入
(1)stdafx.h整合
(2)DeviceStateFunc的afx_handle_t的处理,定义路径的加入:
$(CPLUS_SRC_NETSDK_PATH)
(3)CDvrChannel路径
StdAfx.h中linux部分添加dvrdevice/dvrchannel.h
(4)Utils中的NET_TIME处理 

5)libmodel.h和osIndependent.h
中的RECT冲突
osIndependent.h中的RECT用
#ifndef RECT
#define RECT
#endif

6)<linux/config.h>
未添加 ，找不到合适的，就屏蔽吧,
/home/zhangzhijie/work/hawk20161219/platform/hi3518c/uboot/include/linux/config.h
/home/zhangzhijie/work/hawk20161219/platform/hi3518c/uboot/arch/arm/include/asm/config.h
但有资料说被autoconf.h代替，路径如下 (**在此工程中用autoconf.h代替***)
/home/zhangzhijie/work/hawk20170111/platform/vc0718/kernel/include/generated/autoconf.h 

7)<linux/compiler.h>
/home/zhangzhijie/work/hawk20161219/platform/vc0718c/kernel/include/linux/compiler.h
/home/zhangzhijie/work/hawk20161219/platform/vc0718/kernel/include/linux/compiler.h

8)<asm/processor.h>
用kernel下的 
/home/zhangzhijie/work/hawk20170111/platform/vc0718/kernel/arch/arm/include

9)libmodel.h
添加CPLUS_SRC_CLIENT_SDK_PATH
7.ParaTimer.h
1)增加头文件 #include "osIndependent.h"


8.Global.h


9.Utils
可逐行合并
1)中NET_TIME处理
(1)为window版本中定义的，linux版本中RVNET_TIME与之对应

2)大量的数据类型隔离合并


10.Alaw_encoder
1)可逐行合并


11.AVIWriter
同步服务器与180的windows版本
1)windows版本有，linux版本没有，先不加到到linux版本中，
原因如下:
1)用到windows的库，如Afw.h属于Microsoft的库
2)先用WIN32宏隔离
3)不加入编译链


12.Backup
1)windows版本的LONG变为intptr_t,使得服务器上的windows版本与180上的windows版本数据类型保持一致 
2)逐行宏隔离合并


13.DevConfig
1)代码量确实大,一个DevConfig类将近40000行
2)同步服务器与180上的windows版本代码
3)隔离合并，数据类型及函数功能有差异,后期再做数据类型及函数功能整合
4)需要整合log.h
5)因用到CONFIG_ETHERNET,需要重新设定路径,整合netsdk中dvrdevice下的dhdvr2cfg.h
(1)因前期未同步服务器和180的windows版本，现重新同步
(2)同步时，CONFIG_NET与CONFIG_ETHERNET拷贝到服务器版本中,与sCONFIG_NET和sCONFIG_ETHERNET结构体名称不同，内容相同
修正，不能这样改动，因为与linux内核的宏定义冲突，还是需要改名,改为sCONFIG_NET 和sCONFIG_ETHERNET
6)assert未定义
添加cassert
7)OutputDebugString
原为windows库函数，因linux调用，所以在rtspApp/include/sys_inc.h中重新进行了宏定义，需要包含此头文件

14.log.h
1)逐行合并
2)此文件原始版本专用于windows版本


15.DevControl
1)统一版本
同步服务器与180的本地版本，本地版本为最新版本范本
差异一般在intptr_t和long的统一，以及函数的增加
2).h文件逐行合并
3).cpp文件进行隔离合并
差异不大，但量较大

16.dhnetsdk.cpp(未完成,linux版本没有此文件)
1)无dhnetsdk.h文件
2)同步服务器与180的windows版本工程
差异主要涉及intptr_t和LONG的统一，以及新增函数
3)linux没有此文件
4)修改头文件VD_extraFuns.h
5)fDisConnect(Win32)与PFDisConnect对应
例:59
6)afk_device_s(Win32)与CDvrDevice结构体的对应
例:3223
7)g_Manager.SetLastError(NET_INVALID_HANDLE)在linux下改为g_Manager.SetLastError(RV_ET_INVALID_HANDLE)
如:3213
8)调用了CDevConfig中的SetDevConfigTwo_ex函数
windows版本中存在SetDevConfigTwo_ex函数，改为linux版本
9)g_Manager.IsDeviceValid((afk_device_s *)lLoginID)改为
g_Manager.IsDeviceValid((CDvrDevice *)lLoginID)

10)CLIENT_SetLanguage函数调用了CRealPlay的setLanguan函数，但此函数调用底层的库，Linux需要补充此函数，目前用#ifdef WIN32 隔离

11)调用了CManager的EndDevice(fk_device_s*pdv),改为linux版本
12) RV_DEV_TEST_DATA未定义
(1)应该同步180与服务器windows版本,180版本有
linux域中增加#define RVDEV_TEST_DATA 450


13)m_svacParam未定义,
增加RV_NET_SVAC_PARA成员变量及相关功能


17.GPSSubcrible
1)同步服务器与180的windows版本工程
intptr_t和LONG的统一
2)可逐行合并


18.Manager.h(未完成，涉及类较多)
1)同步服务器与180的windows版本工程

19.合并osIndependent.cpp和.h文件
1)linux版本的osIndependent在Basic中
2)ResetEvnetEx在windows版本的linux域中有，linux版本中反而没有
3)原文件中宏定义#define BOOL unsigned long 是错的，应该为 #define BOOL int

20.ParaTimer.cpp
在netsdk中已有此文件

21.ParaTimerImp
在netsdk中已有此文件


22. parseSVAC.c
1)可直接make 通过

23. RealPlay.cpp(未完成)
1)同步服务器与180的windows版本工程
2)去除所包含的头文件前的路径. ../BASIC
3)去除命名空间
4)保留wqParseStream.h头文件前的相对路径/StreamParse
5)同步服务器和180wqParseStream.h的windows版本
添加CPLUS_PRO_NETSDK_PATH
(1)分离合并windows版与linux版本
6)同步VD_extraFuns.h
(1)同步服务器和180windows版本
(2)包含此 头文件

7)处理RV_VideoRender:
(1)同步服务器与180windows版本
1)头文件数据类型，函数功能差异同步
2).cpp文件差异较大，数据类型，函数功能差异及函数增加
3)目前解码只支持windows操作系统,
整体上先采用隔离合并方式
4)windows版本和linux版本都有各自的windows实现和linux实现空函数,整体采用隔离合并方式

8)SP_InputData，SP_GetNextFrame, FRAME_TYPE_VIDEO,FRAME_TYPE_AUDIO,FRAME_TYPE_DATA未定义
(1)，原因是因为没有合并wqParseStream.h的window版本和linux版本
(2)FRAME_TYPE_DATA,FRAME_TYPE_VIDEO,FRAME_TYPE_AUDIO没有定义
(1)，原因wqParseStream.h的服务器和180的linux版本有差异
去掉三者前的WQ_

24.RenderManager.h
1)同步服务器和180windows版本
2)合并windows和linux

25.RV_VideoRender
1)同步服务器和180windows版本
详见 7)

26.SearchRecordAndPlayBack
1)同步服务器和180windows版本
2)windows版本没有SteamConverter.h和cpp,需要从linux版本移植
3)隔离合并法 


27.SearverSet
1)同步服务器和180windows版本
2)windows和linux逐行合并

28. SnapPicture
1)同步服务器和180的windows版本
2)逐行合并windows版本和linux版本

29.SvacNalDecLib
1)同步服务器和180的windows版本,
从180拷贝.cpp文件至服务器,原来在depend目录下
现在移植到Client_SDK目录下
2)linux没有此文件，直接编译通过

30.Talk
1)同步服务器和180的windows版本
2).h采用逐行合并
3).cpp采用隔离合并方式
差异为函数名， 变量类型，功能增减
4)版本相互交叉混乱
(1)windows版本中有实现的linux版本
(2)linux版本中有实现的windows版本
到底以哪个为标准:

31.VD_extraFuns.h
1)同步服务器和180的windows版本
2)逐行合并VD_extraFuns.h
3)修改.cpp文件中的头文件名称

32.Utils_StrParser
1)同步服务器和180的windows版本
2)逐行合并

33.Utils
1)同步服务器和180的windows版本


34.NetPlayBack
1)同步服务器和180的windows版本
没有差异
2)逐行合并windows与linux版本的NetPlayBack.h和cpp文件

35.NetPlayBackBuffer
1)同步服务器和180的windows版本
2)同步服务器和180的linux版本
3)逐步 合并windows与linux的.h和.cpp文件




36.Client_SDK中 linux版本中有的文件而windows没有
WQMediaFile的.h文件和.cpp文件(加)
TBuffer的.h文件和.cpp文件(加)
StreamConver.h文件和.cpp文件(加 )
SCWQToStdAVi的.h文件和.cpp文件(加)
RtspSever的.h文件和.cpp文件
RtspItem的.h文件和.cpp文件(加)
RtspClient的.h文件和.cpp文件(加)
RTPPacket的.h文件和.cpp文件(加)
NetSDK.cpp文件(加)
md5.h和md5.cpp文件(加)
Des的.h文件和.cpp文件(加)
decSPS.h文件和.cpp文件(加)
AviConv.h文件和.cpp文件(加)
AviDef.h文件:(加)

SCWQToStdAVi的.h文件和.cpp文件(加)
######
1)linux版本Client_SDK/StreamParse/wqParseStream.h与/StreamParse/wqParseStream.h差异较大
导致FRAME_TYPE_VIDEO_I_FRAME编不过
上述.h文件中增加#define FRAME_TYPE_VIDEO_I_FRAME 0
######
RtspSever的.h文件和.cpp文件
1)较多警告
NULL used in arithmatic

RtspItem的.h文件和.cpp文件
1)注意有较多警告，deprecated conversion from string const to char * 暂不处理


RtspClient的.h文件和.cpp文件(加)
#
1)注意此文件和rtspapp目录下的include下的RtspClient文件不同，名称相同，但类名及内容不同
#
RTPPacket的.h文件和.cpp文件(RTPPacket)(加)
1).h头文件中添加libmodel.h
arm:
2)hawk中没有此文件


NetSDK.cpp文件(加)
#
1)去除NAMESPACE_BEGIN命名空间
2)修改vd_extrafuns.h名称
3)报的一些错误,是由于缺少RTPPacket，Rtspsever,RtspItem造成，添加这些头文件即可,从linux版本中拷贝这些头文件即可 
去除RTPPacket,RtspItem,RtspSever的NAMESPACEBEGIN命名空间
4)找不到SafeStrCopy,
(1)需要同步linux版本和window版本的此文件
在StdAfx.h中定义，应为此文件中定义了命名空间，所以导致找不到，去除命名空间
5)找不到CRtspClient类
(1)rtspapp和Client_SDK中有相同名称的RtspClient.h及cpp文件，但内容完全不同,在Client_SDK的RtspClient.h中才有CRtspClient类
rtspapp中的为RtspClient类
#
md5.h和md5.cpp文件(加)
Des的.h文件和.cpp文件(加)
#
修改stdafx.h文件名称
#
decSPS.h文件和.cpp文件(加)
AviConv.h文件和.cpp文件(加)
AviDef.h文件:(加)

Windows版本有的文件而linux没有
AVIWriter的.h文件和.cpp文件
dhnetsdk.cpp
parseSVAC.c


不同版本有差异的


Client_SDK 中的StdAfx.h中的OutputDebugString报
Variable Or Field Declared Void



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























//20170522 接唐工netsdk重新编译 mmm platform/common/sofia/sdk -B
1)platform/common/sofia/sdk/netsdk/Client_SDK/NetSDK.h:133: error: conflicting declaration 'typedef void (* FRtspCallBack)(intptr_t, unsigned char*, int, int)'
./platform/common/sofia/sdk/netsdk/inc/libmodel.h:1937: error: 'FRtspCallBack' has a previous declaration as 'typedef void (* FRtspCallBack)(long int, unsigned char*, int, int)'
platform/common/sofia/sdk/netsdk/Client_SDK/NetSDK.cpp: In function 'intptr_t CLIENT_RtspPlay(const char*, int&, void*, int, void (*)(long int, unsigned char*, int, int), int)':
platform/common/sofia/sdk/netsdk/Client_SDK/NetSDK.cpp:724: error: declaration of C function 'intptr_t CLIENT_RtspPlay(const char*, int&, void*, int, void (*)(long int, unsigned char*, int, int), int)' conflicts with
platform/common/sofia/sdk/netsdk/Client_SDK/NetSDK.h:145: error: previous declaration 'long int CLIENT_RtspPlay(const char*, int&, void*, int, void (*)(long int, unsigned char*, int, int), int)' here





2)platform/common/sofia/sdk/netsdk/Client_SDK/Talk.cpp:1942: error: prototype for 'void CTalk::RecordFunc(unsigned char*, long unsigned int, long int)' does not match any in class 'CTalk'
platform/common/sofia/sdk/netsdk/Client_SDK/Talk.h:121: error: candidate is: static void CTalk::RecordFunc(unsigned char*, long unsigned int, intptr_t)




3)platform/common/sofia/sdk/netsdk/TPLayer/ITPObject.cpp: In member function 'int ITPObject::Create(opMode)':
platform/common/sofia/sdk/netsdk/TPLayer/ITPObject.cpp:1200: error: 'TP_SOCK_UDP' was not declared in this scope
放开sdk/netsdk/inc/TPTypedef.h中的 TP_SOCK_TYPE定义,删除 TPLayer中的 TPTypedef.h









4)./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h:91: error: 'DHMutex' does not name a type
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h: In member function 'SRTPMediaData* CRtpBuffer::PushPubBuffer(const unsigned char*, int)':
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h:45: error: 'm_dataBufLock' was not declared in this scope
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h: In member function 'int CRtpBuffer::PopPubBuffer(SRTPMediaData*)':
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h:82: error: 'm_dataBufLock' was not declared in this scope
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h: At global scope:
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h:185: error: 'DHMutex' does not name a type
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h:202: error: 'DHMutex' does not name a type
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h: In member function 'int CRtspClient::GetSeq()':
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h:149: error: 'm_stateLock' was not declared in this scope
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp: In member function 'int CRtspApp::RealPlay_open(char*, int, char*, int, int)':
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:96: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:97: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:106: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:108: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:109: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:110: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:133: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:134: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:138: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:145: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:154: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:155: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:156: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:159: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:171: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp: In member function 'int CRtspApp::RealPlay_close()':
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:208: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:209: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'


5)
platform/common/sofia/sdk/netsdk/inc/atomiccount.cpp: In member function 'bool AtomicCount::ref()':
platform/common/sofia/sdk/netsdk/inc/atomiccount.cpp:23: error: impossible constraint in 'asm'
用20170301版本中的dh_atomic.h替换 20170517版本中的原来netsdk中的dh_atomic.h注意差异
第一:718版本中没有netsdk版本中的__WIN32_OS__的宏定义及包含头文件.
第二:718版本中具有atomic_t的结构体定义
第三:718版本中atomic_add_return 中有linux环境下的处理方式

用20170301版本中的atomiccount.h 替换20170517版本中的netsdk中的 atomiccount.h
第一:需要去掉命名空间
第二:去掉BASIC_CLASS符号

用20170301版本中的atomiccount.cpp 替换20170517版本中的netsdk中的 atomiccount.cpp
第一:需要去掉命名空间
第二:注意区别，原版本具有汇编，718工程由c实现


6)
platform/common/sofia/sdk/netsdk/inc/TBuffer.h:82: error: 'FILE' has not been declared
platform/common/sofia/sdk/netsdk/inc/TBuffer.cpp:80: error: 'int CTBuffer::MemWriteFile' is not a static member of 'class CTBuffer'
platform/common/sofia/sdk/netsdk/inc/TBuffer.cpp:80: error: 'FILE' was not declared in this scope
platform/common/sofia/sdk/netsdk/inc/TBuffer.cpp:80: error: 'pFile' was not declared in this scope
platform/common/sofia/sdk/netsdk/inc/TBuffer.cpp:80: error: expected primary-expression before 'unsigned'
platform/common/sofia/sdk/netsdk/inc/TBuffer.cpp:80: error: expected primary-expression before 'int'
platform/common/sofia/sdk/netsdk/inc/TBuffer.cpp:80: error: initializer expression list treated as compound expression
platform/common/sofia/sdk/netsdk/inc/TBuffer.cpp:81: error: expected ',' or ';

需要包换"stdio.h", 具有此文件的原头文件有commonhead.h;sys_inc.h;Global.h;Utils.h;
处理方法，在osIndependent.h中增加 #include <stdio.h>



7)
platform/common/sofia/sdk/netsdk/inc/atomiccount.cpp:5:20: error: atomic.h: No such file or directory
解决方法:
把718下的atomic.h复制到netsdk/inc/目录下，因为此文件中定义了atomic_add_return等的定义


8)
platform/common/sofia/sdk/netsdk/Client_SDK/DevConfig.cpp:516: error: 'OutputDebugString' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/DevConfig.cpp:527: error: 'OutputDebugString' was not declared in this scope
解决方法:包含sys_inc.h 此文件包含在netsdk/inc/commonhead.h netsdk/inc/Global.h等文件中



9)
platform/common/sofia/sdk/netsdk/Client_SDK/DevControl.cpp:559: error: 'OutputDebugStringA' was not declared in this scope
解决方法:包含sys_inc.h 此文件包含在netsdk/inc/commonhead.h netsdk/inc/Global.h等文件中



10)
包含sys_inc.h 此文件包含在netsdk/inc/commonhead.h netsdk/inc/Global.h等文件中tform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp: In function 'void* pbthreadproc(void*)':
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:1837: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:1903: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:1909: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:1916: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:1946: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:1975: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp: In function 'void* pbthreadprocnew(void*)':
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:1996: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:2011: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:2034: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:2099: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:2105: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:2112: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:2142: error: 'OutputDebugStringA' was not declared in this scope
platform/common/sofia/sdk/netsdk/Client_SDK/SearchRecordAndPlayBack.cpp:2171: error: 'OutputDebugStringA' was not declared in this scope
make: *** [out/target/product/generic_arm/obj/STATIC_LIBRARIES/libsdk_intermediates/Client_SDK/SearchRecordAndPlayBack.o] Error 1
解决方法:包含sys_inc.h 此文件包含在netsdk/inc/commonhead.h netsdk/inc/Global.h等文件中


11)
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h:185: error: 'DHMutex' does not name a type
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h:202: error: 'DHMutex' does not name a type
fix:#include  "dhmutex.h"


12)
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h:45: error: 'm_dataBufLock' was not declared in this scope
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h: In member function 'int CRtpBuffer::PopPubBuffer(SRTPMediaData*)':
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h:82: error: 'm_dataBufLock' was not declared in this scope
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h: At global scope:
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h: In member function 'int CRtspClient::GetSeq()':
./platform/common/sofia/sdk/netsdk/Client_SDK/RtspClient.h:149: error: 'm_stateLock' was not declared in this scope
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp: In member function 'int CRtspApp::RealPlay_open(char*, int, char*, int, int)':
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:96: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:97: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:106: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:108: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:109: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:110: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:133: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:134: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:138: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:145: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:154: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:155: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:156: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:159: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:171: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp: In member function 'int CRtspApp::RealPlay_close()':
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:208: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:209: error: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: error: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:211: warning: possible problem detected in invocation of delete operator:
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:211: warning: invalid use of incomplete type 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspApp.h:32: warning: forward declaration of 'struct RtspClient'
platform/common/sofia/sdk/netsdk/rtspapp/rtspapp.cpp:211: note: neither the destructor nor the class-specific operator delete will be called, even if they are declared when the class is defined.
解决方法:删除了32行的两个前置声明


找不到CRtspClient类
(1)rtspapp和Client_SDK中有相同名称的RtspClient.h及cpp文件，但内容完全不同,在Client_SDK的RtspClient.h中才有CRtspClient类
rtspapp中的为RtspClient类,1月份的时候是把Client_SDK下的 RtspClient.h改为了RtspClient1.h

 "RtspClient1.h"即为原Client_SDK下的RtspClient 文件被如下两个cpp文件引用

./Client_SDK/NetSDK.cpp:22:#include "RtspClient1.h"
./Client_SDK/RtspClient1.cpp:7:#include "RtspClient1.h"
./dhnetsdk.cpp:20:#include "RtspClient1.h"


二.
主干分支0601与0517进行整合
1)
sdk/Android.mk
sdk/netsdk/source.mk

2)
demo 
Makefile & main.cpp




3)
#
##directorymodified:   netsdk/Client_SDK/DevControl.cpp
#cppmodified:   netsdk/Client_SDK/NetSDK.cpp
#cppmodified:   netsdk/Client_SDK/NetSDK.h
#NetSDKdeleted:    netsdk/Client_SDK/RtspClient.cpp
#cppdeleted:    netsdk/Client_SDK/RtspClient.h
#RtspClientmodified:   netsdk/Client_SDK/SearchRecordAndPlayBack.h
#SearchRecordAndPlayBackmodified:   netsdk/Client_SDK/Talk.cpp
#cppmodified:   netsdk/Client_SDK/dhnetsdk.cpp
#cppdeleted:    netsdk/Client_SDK/libclient_20170207.h
#libclient_20170207modified:   netsdk/Client_SDK/libmodelx64.so
#somodified:   netsdk/TPLayer/ITPObject.cpp
#cppdeleted:    netsdk/TPLayer/TPTypedef.h
#TPTypedefdeleted:    netsdk/demo/demo
#demomodified:   netsdk/inc/TPTypedef.h
#TPTypedefmodified:   netsdk/inc/atomiccount.cpp
#cppmodified:   netsdk/inc/atomiccount.h
#atomiccountmodified:   netsdk/inc/dh_atomic.h
#dh_atomicmodified:   netsdk/inc/libmodel.h
#libmodelmodified:   netsdk/inc/osIndependent.h
#osIndependentmodified:   netsdk/source.mk


4)
(use "git add <file>..." to include in what will be committed)
#
##committednetsdk/Client_SDK/DevConfig.cpp.0301
#0301netsdk/Client_SDK/RtspClient1.cpp
#cppnetsdk/Client_SDK/RtspClient1.h
#RtspClient1netsdk/Client_SDK/RtspClient1.h.0301
#0301netsdk/Client_SDK/dhnetsdk.cpp.0301
#0301netsdk/Client_SDK/libclient.h.20170207
#20170207netsdk/TPLayer/TPTypedef20170525.h
#TPTypedef20170525netsdk/cscope.in.out
#outnetsdk/cscope.out
#outnetsdk/cscope.po.out
#outnetsdk/demo1/
#demo1netsdk/inc/TBuffer0301.cpp
#cppnetsdk/inc/TBuffer0301.h
#TBuffer0301netsdk/inc/atomic.h
#atomicnetsdk/inc/atomic0301.h
#atomic0301netsdk/inc/atomiccount0301.cpp
#cppnetsdk/inc/atomiccount0301.h
#atomiccount0301netsdk/inc/atomiccount_718.cpp
#cppnetsdk/inc/atomiccount_718.h
#atomiccount_718netsdk/inc/atomiccount_netsdk.cpp
#cppnetsdk/inc/atomiccount_netsdk.h
#atomiccount_netsdknetsdk/inc/dh_atomic0301.h
#dh_atomic0301netsdk/inc/dh_atomic_718.h
#dh_atomic_718netsdk/inc/dh_atomic_netsdk.h
#dh_atomic_netsdknetsdk/rtspapp/rtspApp0301.h
#rtspApp0301netsdk/source20170524.mk
#mknetsdk/tags
#tagsnetsdk_PCver_GIT/




5)tapitest改为单线程获取视频流，计数超过2000次，停止获取。原demo为双线程，命令行w,s,e 控制

  目前已经能够利用netsdk生成的libsdk.so 在设备端(测试设备IP：10.0.14.185)抓取视频流，所进行的两个测试实例如下:

1)回环地址：127.0.0.1，抓取185设备视频流

2)在10.0.14.185设备上抓取10.0.14.186的视频流






第三任务：
VCU整合新版本libsdk
mmm platfomr/common/sofia/stream/adapter -B
1.错误
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3003: error: 'DWORD' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3005: error: 'DWORD' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3010: error: 'DWORD' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3012: error: 'DWORD' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3013: error: 'WORD' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3014: error: 'WORD' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3020: error: 'DWORD' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3024: error: 'BYTE' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3025: error: 'BYTE' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3026: error: 'BYTE' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3027: error: 'BYTE' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3028: error: 'BYTE' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3029: error: 'BYTE' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3030: error: 'BYTE' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3031: error: 'BYTE' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3032: error: 'BYTE' does not name a type
./platform/common/sofia/stream/adapter/sdk/libsdk.h:3033: error: 'BYTE' does not name a typ

解决方法:
在adapter/sdk下加osIndependent.h,typedef.h libclient.h dh_atomic.h


2.错误
./platform/common/sofia/inc/TLV/TlvCfg.h:182: error: conflicting declaration 'typedef enum __cfg_index_t CFG_INDEX'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1258: error: 'CFG_INDEX' has a previous declaration as 'typedef enum _CFG_INDEX CFG_INDEX'
解决方法:
屏幕libmodel.h和libsdk.h中的CFG_INDEX


3.错误
./platform/common/sofia/inc/KIT/DVRDEF.H:167: error: conflicting declaration 'typedef struct VD_RECT RECT'
./platform/common/sofia/stream/adapter/sdk/osIndependent.h:54: error: 'RECT' has a previous declaration as 'typedef struct tagRECT RECT'
解决方法:
先把osIndependent.h中的RECT屏蔽掉, 但是为了验证vcu接口,先这样做，但不做正式发布。

4.错误
./platform/common/sofia/inc/KIT/DVRDEF.H:222: error: conflicting declaration 'typedef union IPADDR IPADDR'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:806: error: 'IPADDR' has a previous declaration as 'typedef union _IPADDR IPADDR'
解决方法:
先把libsdk.h中的IPADDR屏蔽掉，这样会导致libsdk编译不通过，但是为了验证vcu接口,先这样做，但不做正式发布。


5.错误
./platform/common/sofia/inc/TLV/TlvCmd.h:415: error: expected identifier before numeric constant
./platform/common/sofia/inc/TLV/TlvCmd.h:415: error: expected `}' before numeric constant
./platform/common/sofia/inc/TLV/TlvCmd.h:415: error: expected unqualified-id before numeric constant
./platform/common/sofia/inc/TLV/TlvCmd.h:465: error: expected declaration before '}' token
原因:有重复定义如下
ENCODE_COLOR_TYPE_EX = 423
ENCODE_COLOR_TYPE_EX_TABLE = 424
ENCODE_CHANNEL_MUTILE_TITLE = 425
解决方法:
屏蔽掉libsdk.h中3个宏定义,
#define ENCODE_COLOR_TYPE_EX 0x800001A7
#define ENCODE_COLOR_TYPE_EX_TABEL 424
#define ENCODE_CHANNEL_MUTILT_TITLE 0x800001A9



6.错误
./platform/common/sofia/inc/TLV/TlvApi.h:319: error: conflicting declaration 'CAPTURE_SIZE_D1'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1271: error: 'CAPTURE_SIZE_D1' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_D1'
./platform/common/sofia/inc/TLV/TlvApi.h:320: error: conflicting declaration 'CAPTURE_SIZE_HD1'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1272: error: 'CAPTURE_SIZE_HD1' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_HD1'
./platform/common/sofia/inc/TLV/TlvApi.h:321: error: conflicting declaration 'CAPTURE_SIZE_BCIF'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1273: error: 'CAPTURE_SIZE_BCIF' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_BCIF'
./platform/common/sofia/inc/TLV/TlvApi.h:322: error: conflicting declaration 'CAPTURE_SIZE_CIF'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1274: error: 'CAPTURE_SIZE_CIF' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_CIF'
./platform/common/sofia/inc/TLV/TlvApi.h:323: error: conflicting declaration 'CAPTURE_SIZE_QCIF'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1275: error: 'CAPTURE_SIZE_QCIF' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_QCIF'
./platform/common/sofia/inc/TLV/TlvApi.h:324: error: conflicting declaration 'CAPTURE_SIZE_VGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1276: error: 'CAPTURE_SIZE_VGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_VGA'
./platform/common/sofia/inc/TLV/TlvApi.h:325: error: conflicting declaration 'CAPTURE_SIZE_QVGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1277: error: 'CAPTURE_SIZE_QVGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_QVGA'
./platform/common/sofia/inc/TLV/TlvApi.h:326: error: conflicting declaration 'CAPTURE_SIZE_SVCD'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1278: error: 'CAPTURE_SIZE_SVCD' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_SVCD'
./platform/common/sofia/inc/TLV/TlvApi.h:327: error: conflicting declaration 'CAPTURE_SIZE_QQVGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1279: error: 'CAPTURE_SIZE_QQVGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_QQVGA'
./platform/common/sofia/inc/TLV/TlvApi.h:328: error: conflicting declaration 'CAPTURE_SIZE_720P'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1280: error: 'CAPTURE_SIZE_720P' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_720P'
./platform/common/sofia/inc/TLV/TlvApi.h:329: error: conflicting declaration 'CAPTURE_SIZE_1080P'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1281: error: 'CAPTURE_SIZE_1080P' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_1080P'
./platform/common/sofia/inc/TLV/TlvApi.h:330: error: conflicting declaration 'CAPTURE_SIZE_SVGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1282: error: 'CAPTURE_SIZE_SVGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_SVGA'
./platform/common/sofia/inc/TLV/TlvApi.h:331: error: conflicting declaration 'CAPTURE_SIZE_XVGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1283: error: 'CAPTURE_SIZE_XVGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_XVGA'
./platform/common/sofia/inc/TLV/TlvApi.h:332: error: conflicting declaration 'CAPTURE_SIZE_WXGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1284: error: 'CAPTURE_SIZE_WXGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_WXGA'
./platform/common/sofia/inc/TLV/TlvApi.h:333: error: conflicting declaration 'CAPTURE_SIZE_SXGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1285: error: 'CAPTURE_SIZE_SXGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_SXGA'
./platform/common/sofia/inc/TLV/TlvApi.h:334: error: conflicting declaration 'CAPTURE_SIZE_WSXGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1286: error: 'CAPTURE_SIZE_WSXGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_WSXGA'
./platform/common/sofia/inc/TLV/TlvApi.h:335: error: conflicting declaration 'CAPTURE_SIZE_UXGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1287: error: 'CAPTURE_SIZE_UXGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_UXGA'
./platform/common/sofia/inc/TLV/TlvApi.h:336: error: conflicting declaration 'CAPTURE_SIZE_WUXGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1288: error: 'CAPTURE_SIZE_WUXGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_WUXGA'
./platform/common/sofia/inc/TLV/TlvApi.h:342: error: conflicting declaration 'CAPTURE_SIZE_NR'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1290: error: 'CAPTURE_SIZE_NR' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_NR'


7错误
./platform/common/sofia/inc/TLV/TlvType.h:274: error: using typedef-name 'SNAP_TYPE' after 'enum'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1266: error: 'SNAP_TYPE' has a previous declaration here
在俩个文件中定义的enum SNAP_TYPE中的成员的名称和值都不同

解决方法:
先屏蔽,可以netsdk内部还用libmodel.h,对外使用libsdk.h


8错误
./platform/common/sofia/inc/TLV/TlvType.h:352: error: conflicting declaration 'typedef struct tagINNER_VERSION INNER_VERSION'
./platform/common/sofia/stream/adapter/sdk/libclient.h:599: error: 'INNER_VERSION' has a previous declaration as 'typedef struct _INNER_VERSION_ INNER_VERSION'
./platform/common/sofia/inc/TLV/TlvType.h:372: error: conflicting declaration 'typedef struct tagMODULE_VERSION MODULE_VERSION'
./platform/common/sofia/stream/adapter/sdk/libclient.h:613: error: 'MODULE_VERSION' has a previous declaration as 'typedef struct _MODULE_VERSION_ MODULE_VERSION'

解决方法:
屏蔽libclient.h中的INNER_VERSION,netsdk内部还用没屏蔽INNVER_VERSION的libclient.h
屏蔽libclient.h中的MODULE_VERSION,netsdk内部还用没屏蔽MODULE_VERSION的libclient.h



9错误
./platform/common/sofia/inc/TLV/TlvType.h:1131: error: conflicting declaration 'typedef struct tagRECORD_ABILITY RECORD_ABILITY'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6697: error: 'RECORD_ABILITY' has a previous declaration as 'typedef struct _RECORD_ABILITY RECORD_ABILITY'

解决方法:
屏蔽libsdk.h中的 RECORD_ABITITY


10.错误
./platform/common/sofia/stream/adapter/sdk/libsdk.h:4209: error: 'SNAP_TYP_NUM' was not declared in this scope
是由屏蔽了7中的SNAP_TYPE引起的

解决方法:
先屏蔽掉RVDEV_SNAP_CFG



11.错误
./platform/common/sofia/inc/TLV/OldVideo.h:123: error: conflicting declaration 'ISP_VIMICRO_VC356'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6391: error: 'ISP_VIMICRO_VC356' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_VIMICRO_VC356'
./platform/common/sofia/inc/TLV/OldVideo.h:124: error: conflicting declaration 'ISP_SONY_IT1'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6392: error: 'ISP_SONY_IT1' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_SONY_IT1'
./platform/common/sofia/inc/TLV/OldVideo.h:125: error: conflicting declaration 'ISP_HITACHI_SC220'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6393: error: 'ISP_HITACHI_SC220' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_HITACHI_SC220'
./platform/common/sofia/inc/TLV/OldVideo.h:126: error: conflicting declaration 'ISP_HITACHI_SC110'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6394: error: 'ISP_HITACHI_SC110' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_HITACHI_SC110'
./platform/common/sofia/inc/TLV/OldVideo.h:127: error: conflicting declaration 'ISP_HITACHI_SC110E'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6395: error: 'ISP_HITACHI_SC110E' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_HITACHI_SC110E'
./platform/common/sofia/inc/TLV/OldVideo.h:128: error: conflicting declaration 'ISP_STARLIGHT'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6396: error: 'ISP_STARLIGHT' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_STARLIGHT'
./platform/common/sofia/inc/TLV/OldVideo.h:129: error: conflicting declaration 'ISP_HITACHI_SC110JG'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6397: error: 'ISP_HITACHI_SC110JG' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_HITACHI_SC110JG'
./platform/common/sofia/inc/TLV/OldVideo.h:130: error: conflicting declaration 'ISP_FTD_6300'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6398
原因两个枚举结构中的成员定义有冲突，
解决方法:
屏蔽掉libsdk.h中ISP_VENDOR_AND_TYPE中冲突的成员






12.错误
./platform/common/sofia/inc/TLV/NewVideo.h:192: error: conflicting declaration 'EXPOSURE_MANUAL'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6534: error: 'EXPOSURE_MANUAL' has a previous declaration as 'RV_EXPOSURE_MODE EXPOSURE_MANUAL'
./platform/common/sofia/inc/TLV/NewVideo.h:193: error: conflicting declaration 'EXPOSURE_AUTO'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6533: error: 'EXPOSURE_AUTO' has a previous declaration as 'RV_EXPOSURE_MODE EXPOSURE_AUTO'
原因两个枚举结构中的成员定义有冲突，
解决方法:
屏蔽掉libsdk.h中RV_EXPOSURE_MODE中冲突的成员, 且冲突的成员在两个枚举中定义的值不同



13.错误
./platform/common/sofia/inc/TLV/PtzCmd.h:33: error: expected identifier before numeric constant
./platform/common/sofia/inc/TLV/PtzCmd.h:33: error: expected `}' before numeric constant
./platform/common/sofia/inc/TLV/PtzCmd.h:33: error: expected unqualified-id before numeric constant
./platform/common/sofia/inc/TLV/PtzCmd.h:69: error: expected declaration before '}' token
原因:
libsdk.h中关于平台控制的 宏定义与PtzCmd.h中的枚举类型冲突，且数值不一样
屏蔽掉libsdk.h中的平台控制宏定义




14.错误
/platform/common/sofia/inc/TLV/PtzCmd.h:176: error: expected identifier before numeric constant
./platform/common/sofia/inc/TLV/PtzCmd.h:176: error: expected `}' before numeric constant
./platform/common/sofia/inc/TLV/PtzCmd.h:176: error: expected unqualified-id before numeric constant
./platform/common/sofia/inc/TLV/PtzCmd.h:178: error: expected declaration before '}' token
原因libsdk.h中PTZ_DEV与 PTZ_MATRIX 与 PtzCmd.h中 枚举 定义冲突
解决原因， 先屏蔽掉





15.错误

./platform/common/sofia/inc/TLV/PtzCmd.h:225: error: conflicting declaration 'typedef struct tagPTZ_OPT_ATTR PTZ_OPT_ATTR'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:4740: error: 'PTZ_OPT_ATTR' has a previous declaration as 'typedef struct PTZ_OPT_ATTR PTZ_OPT_ATTR'
可以屏蔽
./platform/common/sofia/inc/TLV/PtzCmd.h:289: error: redefinition of 'struct tagCONFIG_PTZREGRESS'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6929: error: previous definition of 'struct tagCONFIG_PTZREGRESS'
PtzCmd.h中有tagCONFIG_PTZREGRESS还有一个 tagNET_CONFIG_PTZREGRESS,
而libsdk.h中 的tagCONFIG_PTZREGRESS的内容与tagNET_CONFIG_PTZREGRESS内容一致，且只有 一个 


./platform/common/sofia/inc/TLV/PtzCmd.h:294: error: invalid type in declaration before ';' token
./platform/common/sofia/inc/TLV/PtzCmd.h:303: error: conflicting declaration 'typedef struct tagNET_CONFIG_PTZREGRESS NET_CONFIG_PTZREGRESS'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:6936: error: 'NET_CONFIG_PTZREGRESS' has a previous declaration as 'typedef struct tagCONFIG_PTZREGRESS NET_CONFIG_PTZREGRESS'



16.错误
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp: In function 'int StartVideoEncode(uint, uint)':
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:425: error: 'SDK_RealPlay' was not declared in this scope
解决方法:
用CLIENT_RealPlayEx代替，注意参数列表，不要用CLIENT_RealPlay


17.错误
:tform/common/sofia/stream/adapter/sdk/vcusdk.cpp: In function 'int StopVideoEncode(uint, uint)':
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:445: error: 'SDK_StopRealPlay' was not declared in this scope
解决方法:
用CLIENT_StopRealPlay代替


18.错误 
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:433: error: invalid conversion from 'void (*)(long int, unsigned int, unsigned char*, unsigned int, unsigned int)' to 'void (*)(intptr_t, long unsigned int, unsigned char*, long unsigned int, intptr_t)'
解决方法:
修改adapter/sdk/vcusdk.cpp中的RealDataCBFunc函数



19.错误
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp: In function 'int uniit_sdk()':
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:503: error: 'SDK_Logout' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:505: error: 'SDK_Cleanup' was not declared in this scope

解决方法:
用CLIENT_Logout(g_lLoginID);CLIENT_Cleanup();


20.错误
m/tform/common/sofia/stream/adapter/sdk/vcusdk.cpp: In function 'int init_sdk()':
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:470: error: 'RVNET_PARAM' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:470: error: expected `;' before 'netPar'
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:472: error: 'RVNetDeviceInfo' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:472: error: expected `;' before 'tmpInfo'
common/sofia/stream/adapter/sdk/vcusdk.cpp:433: error: invalid conversion from 'void (*)(long int, unsigned int, unsigned char*, unsigned int, unsigned int)' to 'void (*)(intptr_t, long unsigned int, unsigned char*, long unsigned int, intptr_t)'

解决方法:
用NET_PARAM;NET_DEVICEINFO



21.错误
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp: In function 'int init_sdk()':
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:476: error: 'SDK_Init' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:483: error: 'SDK_SetNetworkParam' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:491: error: 'SDK_Login' was not declared in this scope


解决方法:
用 CLIENT_Init; CLIENT_SetNetworkParam;CLIENT_Login,暂不用CLIENT_LoginEx


22.错误
m/tform/common/sofia/stream/adapter/sdk/vcusdk.cpp: In function 'int Ptz_Ctrl(PTZ_SET_S*)':
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:710: error: 'SDK_PTZControl' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:716: error: 'SDK_PTZControl' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:722: error: 'SDK_PTZControl' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:728: error: 'SDK_PTZControl' was not declared in this scope
解决方法;
改成:CLIENT_PTZControl


23.错误
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp: In function 'int GetAlarmInStatus(int)':
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:749: error: 'RVNET_CLIENT_STATE' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:749: error: expected `;' before 'status'
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:751: error: 'status' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:751: error: 'SDK_QueryDevState' was not declared in this scope
解决方法:
用NET_CLIENT_STATE;CLIENT_QueryDevState


24.错误
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp: In function 'int StopVideoEncode(uint, uint)':
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:447: error: 'SDK_StopRealPlay' was not declared in this scope
解决方法:
1.CLIENT_StopRealPlay:



25.错误
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:435: error: invalid conversion from 'void (*)(intptr_t, unsigned int, unsigned char*, unsigned int, intptr_t)' to 'void (*)(intptr_t, long unsigned int, unsigned char*, long unsigned int, intptr_t)'
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:435: error:   initializing argument 2 of 'int CLIENT_SetRealDataCallBack(intptr_t, void (*)(intptr_t, long unsigned int, unsigned char*, long unsigned int, intptr_t), intptr_t)
解决方法:
32,64位机器上unsigned int 都为32位
64位机器上unsigned long 为64位， 32位机器上为32位
RealDataCBFunc中的DWORD改为unsigned long,

26.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_SET_IframeInterval(int, int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:786: error: 'SDK_GetDevConfig' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:807: error: 'SDK_SetDevConfig' was not declared in this scope
解决方法:
CLIENT_GetDevConfig
CLIENT_SetDevConfig


27.错误
cotform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_IframeInterval(int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:750: error: 'SDK_GetDevConfig' was not declared in this scope
mmon/ddsofia/stream/adapter/sdk/vcusdk.cpp:433: error: invalid conversion from 'void (*)(long int, unsigned int, unsigned char*, unsigned int, unsigned int)' to 'void (*)(intptr_t, long unsigned int, unsigned char*, long unsigned int, intptr_t)'

28.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_SET_VideoRes(int, int, char*)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:715: error: 'SDK_GetDevConfig' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:726: error: 'SDK_SetDevConfig' was not declared in this scope

29.错误
cotform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_VideoRes(int, int, char*)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:670: error: 'SDK_GetDevConfig' was not declared in this scopemmon/ddsofia/stream/adapter/sdk/vcusdk.cpp:433: error: invalid conversion from 'void (*)(long int, unsigned int, unsigned char*, unsigned int, unsigned int)' to 'void (*)(intptr_t, long unsigned int, unsigned char*, long unsigned int, intptr_t)'

30.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_SET_VideoFrameRate(int, int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:594: error: 'SDK_GetDevConfig' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:605: error: 'SDK_SetDevConfig' was not declared in this scope


31.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_VideoFrameRate(int, int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:594: error: 'SDK_GetDevConfig' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:605: error: 'SDK_SetDevConfig' was not declared in this scope



32.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_SET_VideoBitRateType(int, int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:531: error: 'SDK_GetDevConfig' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:542: error: 'SDK_SetDevConfig' was not declared in this scope

33.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_VideoBitRateType(int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:504: error: 'SDK_GetDevConfig' was not declared in this scope

34.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_VideoBitRate(int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:442: error: 'SDK_GetDevConfig' was not declared in this scope

35.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_SET_VideoBitRate(int, int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:469: error: 'SDK_GetDevConfig' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:480: error: 'SDK_SetDevConfig' was not declared in this scope
解决方法:

36.错误
tform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_SET_EncodeMode(int, int, char*)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:234: error: 'ECOMPRESSION_MODE_NR' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:236: error: 'fmtlist' was not declared in this scope
ECOMPRESSION_MODE_NR如何处理，老的libmodel.h中有，新的被注释掉.可以放在基于libmodel.h修改的libsdk.h中，但libmodel.h还保持屏蔽
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:240: error: 'SDK_GetDevConfig' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:251: error: 'SDK_SetDevConfig' was not declared in this scope

37.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_VideoPicQuality(int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:276: error: 'SDK_GetDevConfig' was not declared in this scope

platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_SET_VideoPicQuality(int, int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:311: error: 'SDK_GetDevConfig' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:322: error: 'SDK_SetDevConfig' was not declared in this scope

38.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_VideoType(int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:346: error: 'SDK_GetDevConfig' was not declared in this scope

39.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_SET_VideoType(int, int, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:385: error: 'SDK_GetDevConfig' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:418: error: 'SDK_SetDevConfig' was not declared in this scope



40.错误
tform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_AlarmInNum()':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:72: error: 'SDK_GetDevConfig' was not declared in this scope

41.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_AlarmOutNum()':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:96: error: 'SDK_GetDevConfig' was not declared in this scope

42.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_SoftVersion(char*)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:133: error: 'SDK_GetDevConfig' was not declared in this scope

43.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_HardVersion(char*)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:158: error: 'SDK_GetDevConfig' was not declared in this scope

44.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_SerialNumber(char*, int)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:183: error: 'SDK_GetDevConfig' was not declared in this scope

45.错误
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_EncodeMode(int, int, char*)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:208: error: 'SDK_GetDevConfig' was not declared in this scope

home/zhangzhijie/work/hawk20170601/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/include/stddef.h:400:1: warning: this is the location of the previous definition
In file included from ./platform/common/sofia/stream/adapter/sdk/libsdk.h:16,
                 from platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:28:

46.错误
./platform/common/sofia/stream/adapter/sdk/typedef.h:31: error: duplicate 'unsigned'
./platform/common/sofia/stream/adapter/sdk/typedef.h:31: error: declaration does not declare anything

In file included from ./platform/common/sofia/inc/KIT/DVRDEF.H:6,
   from ./platform/common/sofia/inc/KIT/kitdef.h:4,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:4,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   ./platform/common/sofia/inc/KIT/VTypes.h:81:1: warning: "LPBYTE" redefined

解決方法:
#ifndef DWORD
typedef unsigned long DWORD 
#endif



47.錯誤
./platform/common/sofia/stream/adapter/sdk/typedef.h:30: error: duplicate 'unsigned'
./platform/common/sofia/stream/adapter/sdk/typedef.h:30: error: multiple types in one declaration
./platform/common/sofia/stream/adapter/sdk/typedef.h:30: error: declaration does not declare anything


In file included from ./platform/common/sofia/stream/adapter/sdk/libsdk.h:16,
  from platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:28:
  ./platform/common/sofia/stream/adapter/sdk/typedef.h:120:1: warning: "DWORD" redefined
  In file included from ./platform/common/sofia/inc/KIT/DVRDEF.H:6,
  from ./platform/common/sofia/inc/API/Net.h:4,
  from platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:22:
  ./platform/common/sofia/inc/KIT/VTypes.h:87:1: warning: this is the location of the previous definition

48.錯誤

In file included from platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:28:
./platform/common/sofia/stream/adapter/sdk/libsdk.h:5569: error: expected unqualified-id before 'void'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:5569: error: expected initializer before 'void'

解決方法:
#ifndef VD_HANDLE
#endif


49.錯誤
./platform/common/sofia/stream/adapter/sdk/libsdk.h:5570: error: multiple types in one declaration
./platform/common/sofia/stream/adapter/sdk/libsdk.h:5570: error: declaration does not declare anything

解決方法:
#ifndef VD_BOOL
#endif



50.用307viss帐号，一直无法出图原因
是由于 /lib/libstream.so 加载失败，undefined symbol :VCU_GET_AudioEncType导致
在 /stream/adapter/sdk/vcuapi.cpp中加入
int VCU_GET_AudioEncType(uint chan)
{
	return 0;	
}

51.build/core/binary.mk:391: target `out/target/product/generic_arm/obj/STATIC_LIBRARIES/libkit_intermediates/base/IPC.o' given more than once in the same rule.
build/core/base_rules.mk:171: *** platform/common/sofia/stream/adapter: MODULE.TARGET.SHARED_LIBRARIES.libstream already defined by platform/common/sofia/stream/adapter.  Stop.
产生原因:
是由于在此sofia/stream下做了一个 adapter_backup的备份文件夹，但产生机制需要再次确认



四.第四任务, 处理唐工7月18日调整的libmodel.h 
1.libmodel.h中文件名改为libsdk.h,且 原文件宏定义VD_CLIENT_SDK_H改为__LIBSDK_H__




2.
./platform/common/sofia/inc/KIT/Asn1Tool.h:44: error: template with C linkage
./platform/common/sofia/inc/KIT/Asn1Tool.h:123: error: template with C linkage
./platform/common/sofia/inc/KIT/Asn1Tool.h:148: error: template with C linkage
./platform/common/sofia/inc/KIT/Asn1Tool.h:289: error: template with C linkage
In file included from /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/map:65,
   from ./platform/common/sofia/inc/KIT/json/value.h:9,
   from ./platform/common/sofia/inc/KIT/json/json.h:5,
   from ./platform/common/sofia/inc/KIT/ConfigBase.h:7,
   from ./platform/common/sofia/inc/KIT/kitdef.h:31,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:4,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:131: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:142: error: declaration of C function 'const std::_Rb_tree_node_base* std::_Rb_tree_increment(const std::_Rb_tree_node_base*)' conflicts with
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:139: error: previous declaration 'std::_Rb_tree_node_base* std::_Rb_tree_increment(std::_Rb_tree_node_base*)' here
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:148: error: declaration of C function 'const std::_Rb_tree_node_base* std::_Rb_tree_decrement(const std::_Rb_tree_node_base*)' conflicts with
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:145: error: previous declaration 'std::_Rb_tree_node_base* std::_Rb_tree_decrement(std::_Rb_tree_node_base*)' here
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:150: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:220: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:295: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:301: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:318: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:741: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:751: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:761: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:768: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:775: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:782: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:789: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:820: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:842: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:861: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:879: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:896: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:932: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:948: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:964: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:980: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:996: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1012: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1043: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1074: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1128: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1157: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1174: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1233: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1287: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1298: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1309: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1323: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1337: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1349: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1362: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1375: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1385: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1398: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1411: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_tree.h:1426: error: template with C linkage
   In file included from /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/map:66,
   from ./platform/common/sofia/inc/KIT/json/value.h:9,
   from ./platform/common/sofia/inc/KIT/json/json.h:5,
   from ./platform/common/sofia/inc/KIT/ConfigBase.h:7,
   from ./platform/common/sofia/inc/KIT/kitdef.h:31,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:4,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_map.h:89: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_map.h:753: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_map.h:770: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_map.h:777: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_map.h:784: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_map.h:791: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_map.h:798: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_map.h:805: error: template with C linkage
   In file included from /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/map:67,
   from ./platform/common/sofia/inc/KIT/json/value.h:9,
   from ./platform/common/sofia/inc/KIT/json/json.h:5,
   from ./platform/common/sofia/inc/KIT/ConfigBase.h:7,
   from ./platform/common/sofia/inc/KIT/kitdef.h:31,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:4,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multimap.h:88: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multimap.h:683: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multimap.h:700: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multimap.h:707: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multimap.h:714: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multimap.h:721: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multimap.h:728: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multimap.h:735: error: template with C linkage
   In file included from /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/stack:67,
   from ./platform/common/sofia/inc/KIT/json/reader.h:7,
   from ./platform/common/sofia/inc/KIT/json/json.h:6,
   from ./platform/common/sofia/inc/KIT/ConfigBase.h:7,
   from ./platform/common/sofia/inc/KIT/kitdef.h:31,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:4,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_stack.h:97: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_stack.h:236: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_stack.h:254: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_stack.h:260: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_stack.h:266: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_stack.h:272: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_stack.h:278: error: template with C linkage
   In file included from ./platform/common/sofia/inc/KIT/json/json.h:7,
   from ./platform/common/sofia/inc/KIT/ConfigBase.h:7,
   from ./platform/common/sofia/inc/KIT/kitdef.h:31,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:4,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   ./platform/common/sofia/inc/KIT/json/writer.h:86: error: declaration of C function 'void Json::valueToString(std::string&, unsigned int)' conflicts with
   ./platform/common/sofia/inc/KIT/json/writer.h:85: error: previous declaration 'void Json::valueToString(std::string&, int)' here
   ./platform/common/sofia/inc/KIT/json/writer.h:87: error: declaration of C function 'void Json::valueToString(std::string&, double)' conflicts with
   ./platform/common/sofia/inc/KIT/json/writer.h:86: error: previous declaration 'void Json::valueToString(std::string&, unsigned int)' here
   ./platform/common/sofia/inc/KIT/json/writer.h:88: error: declaration of C function 'void Json::valueToString(std::string&, bool)' conflicts with
   ./platform/common/sofia/inc/KIT/json/writer.h:87: error: previous declaration 'void Json::valueToString(std::string&, double)' here
   In file included from /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/set:66,
   from ./platform/common/sofia/inc/KIT/ConfigBase.h:9,
   from ./platform/common/sofia/inc/KIT/kitdef.h:31,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:4,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_set.h:90: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_set.h:594: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_set.h:611: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_set.h:618: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_set.h:625: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_set.h:632: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_set.h:639: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_set.h:646: error: template with C linkage
   In file included from /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/set:67,
   from ./platform/common/sofia/inc/KIT/ConfigBase.h:9,
   from ./platform/common/sofia/inc/KIT/kitdef.h:31,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:4,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multiset.h:87: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multiset.h:580: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multiset.h:597: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multiset.h:604: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multiset.h:611: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multiset.h:618: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multiset.h:625: error: template with C linkage
   /home/zhangzhijie/work/hawk20170711/prebuilts/gcc/linux-x86/arm/arm-none-linux-gnueabi-4.3.3/bin/../lib/gcc/arm-none-linux-gnueabi/4.3.3/../../../../arm-none-linux-gnueabi/include/c++/4.3.3/bits/stl_multiset.h:632: error: template with C linkage
   In file included from ./platform/common/sofia/inc/KIT/kitdef.h:31,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:4,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   ./platform/common/sofia/inc/KIT/ConfigBase.h:143: error: template with C linkage
   ./platform/common/sofia/inc/KIT/ConfigBase.h:146: error: template with C linkage
   ./platform/common/sofia/inc/KIT/ConfigBase.h:221: error: template with C linkage
   ./platform/common/sofia/inc/KIT/ConfigBase.h:224: error: template with C linkage
   ./platform/common/sofia/inc/KIT/ConfigBase.h:227: error: template with C linkage
   关于linkage的 解决方法 :
   /C++混用的项目时，可能会遇到这个问题。

   1.某个头文件中extern “C”的使用存在问题，如果包含这个有问题的头文件之后，又包含<map>,<vector>等就会出现这个问题。

   1). 需要检查extern "C"后面为一个函数 

   extern "C" int get_value(void);

   2). extern "C" { }的定义是否完整。

#ifdef __cplusplus

   extern "C" {

#endif

#ifdef __cplusplus

   }

#endif

2. 不要在extern "C"的中引用C++ STL库的头文件，如<map>, <vector>等具有template的头文件。

extern "language_name" declaration ;
extern "language_name" { declaration ; declaration ; ... }

extern "C" {
	void f();             // C linkage
	extern "C++" {
		void g();         // C++ linkage
		extern "C" void h(); // C linkage
		void g2();        // C++ linkage
	}
	extern "C++" void k();// C++ linkage
	void m();             // C linkage
}



3../platform/common/sofia/inc/KIT/DVRDEF.H:185: error: conflicting declaration 'typedef struct VD_RECT RECT'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:7301: error: 'RECT' has a previous declaration as 'typedef struct tagRECT RECT'
In file included from ./platform/common/sofia/inc/TLV/tlvdef.h:10,
   from ./platform/common/sofia/stream/adapter/vcu/vcudef.h:5,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:5,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   ./platform/common/sofia/inc/TLV/TlvCmd.h:420: error: expected identifier before numeric constant
   ./platform/common/sofia/inc/TLV/TlvCmd.h:420: error: expected `}' before numeric constant
   421:error
   422:error
   ./platform/common/sofia/inc/TLV/TlvCmd.h:420: error: expected unqualified-id before numeric constant
   ./platform/common/sofia/inc/TLV/TlvCmd.h:497: error: expected declaration before '}' token
解决方法:
1)原来文件为REALEASE_HEADER
现在屏蔽了RECT  
2)ENCODE_COLOR_TYPE_EX重复定义了
所以屏蔽
3)屏蔽了ENCODE_COLOR_TYPE_EX_TABLE
4)屏蔽了ENCODE_CHANNEL_MUTILE_TITLE


4../platform/common/sofia/inc/TLV/TlvApi.h:319: error: conflicting declaration 'CAPTURE_SIZE_D1'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1511: error: 'CAPTURE_SIZE_D1' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_D1'
./platform/common/sofia/inc/TLV/TlvApi.h:320: error: conflicting declaration 'CAPTURE_SIZE_HD1'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1512: error: 'CAPTURE_SIZE_HD1' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_HD1'
./platform/common/sofia/inc/TLV/TlvApi.h:321: error: conflicting declaration 'CAPTURE_SIZE_BCIF'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1513: error: 'CAPTURE_SIZE_BCIF' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_BCIF'
./platform/common/sofia/inc/TLV/TlvApi.h:322: error: conflicting declaration 'CAPTURE_SIZE_CIF'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1514: error: 'CAPTURE_SIZE_CIF' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_CIF'
./platform/common/sofia/inc/TLV/TlvApi.h:323: error: conflicting declaration 'CAPTURE_SIZE_QCIF'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1515: error: 'CAPTURE_SIZE_QCIF' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_QCIF'
./platform/common/sofia/inc/TLV/TlvApi.h:324: error: conflicting declaration 'CAPTURE_SIZE_VGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1516: error: 'CAPTURE_SIZE_VGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_VGA'
./platform/common/sofia/inc/TLV/TlvApi.h:325: error: conflicting declaration 'CAPTURE_SIZE_QVGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1517: error: 'CAPTURE_SIZE_QVGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_QVGA'
./platform/common/sofia/inc/TLV/TlvApi.h:326: error: conflicting declaration 'CAPTURE_SIZE_SVCD'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1518: error: 'CAPTURE_SIZE_SVCD' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_SVCD'
./platform/common/sofia/inc/TLV/TlvApi.h:327: error: conflicting declaration 'CAPTURE_SIZE_QQVGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1519: error: 'CAPTURE_SIZE_QQVGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_QQVGA'
./platform/common/sofia/inc/TLV/TlvApi.h:328: error: conflicting declaration 'CAPTURE_SIZE_720P'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1520: error: 'CAPTURE_SIZE_720P' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_720P'
./platform/common/sofia/inc/TLV/TlvApi.h:329: error: conflicting declaration 'CAPTURE_SIZE_1080P'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1521: error: 'CAPTURE_SIZE_1080P' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_1080P'
./platform/common/sofia/inc/TLV/TlvApi.h:330: error: conflicting declaration 'CAPTURE_SIZE_SVGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1522: error: 'CAPTURE_SIZE_SVGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_SVGA'
./platform/common/sofia/inc/TLV/TlvApi.h:331: error: conflicting declaration 'CAPTURE_SIZE_XVGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1523: error: 'CAPTURE_SIZE_XVGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_XVGA'
./platform/common/sofia/inc/TLV/TlvApi.h:332: error: conflicting declaration 'CAPTURE_SIZE_WXGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1524: error: 'CAPTURE_SIZE_WXGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_WXGA'
./platform/common/sofia/inc/TLV/TlvApi.h:333: error: conflicting declaration 'CAPTURE_SIZE_SXGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1525: error: 'CAPTURE_SIZE_SXGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_SXGA'
./platform/common/sofia/inc/TLV/TlvApi.h:334: error: conflicting declaration 'CAPTURE_SIZE_WSXGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1526: error: 'CAPTURE_SIZE_WSXGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_WSXGA'
./platform/common/sofia/inc/TLV/TlvApi.h:335: error: conflicting declaration 'CAPTURE_SIZE_UXGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1527: error: 'CAPTURE_SIZE_UXGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_UXGA'
./platform/common/sofia/inc/TLV/TlvApi.h:336: error: conflicting declaration 'CAPTURE_SIZE_WUXGA'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1528: error: 'CAPTURE_SIZE_WUXGA' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_WUXGA'
./platform/common/sofia/inc/TLV/TlvApi.h:342: error: conflicting declaration 'CAPTURE_SIZE_NR'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:1530: error: 'CAPTURE_SIZE_NR' has a previous declaration as '_CAPTURE_SIZE CAPTURE_SIZE_NR'
解决方法:
屏蔽了CAPTURE_SIZE中除CAPTURE_SIZE_960P的其它成员,且赋值=18 

5.
In file included from ./platform/common/sofia/inc/TLV/tlvdef.h:15,
   from ./platform/common/sofia/stream/adapter/vcu/vcudef.h:5,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:5,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   ./platform/common/sofia/inc/TLV/OldVideo.h:123: error: conflicting declaration 'ISP_VIMICRO_VC356'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:6692: error: 'ISP_VIMICRO_VC356' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_VIMICRO_VC356'
   ./platform/common/sofia/inc/TLV/OldVideo.h:124: error: conflicting declaration 'ISP_SONY_IT1'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:6693: error: 'ISP_SONY_IT1' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_SONY_IT1'
   ./platform/common/sofia/inc/TLV/OldVideo.h:125: error: conflicting declaration 'ISP_HITACHI_SC220'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:6694: error: 'ISP_HITACHI_SC220' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_HITACHI_SC220'
   ./platform/common/sofia/inc/TLV/OldVideo.h:126: error: conflicting declaration 'ISP_HITACHI_SC110'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:6695: error: 'ISP_HITACHI_SC110' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_HITACHI_SC110'
   ./platform/common/sofia/inc/TLV/OldVideo.h:127: error: conflicting declaration 'ISP_HITACHI_SC110E'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:6696: error: 'ISP_HITACHI_SC110E' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_HITACHI_SC110E'
   ./platform/common/sofia/inc/TLV/OldVideo.h:128: error: conflicting declaration 'ISP_STARLIGHT'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:6697: error: 'ISP_STARLIGHT' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_STARLIGHT'
   ./platform/common/sofia/inc/TLV/OldVideo.h:129: error: conflicting declaration 'ISP_HITACHI_SC110JG'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:6698: error: 'ISP_HITACHI_SC110JG' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_HITACHI_SC110JG'
   ./platform/common/sofia/inc/TLV/OldVideo.h:130: error: conflicting declaration 'ISP_FTD_6300'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:6699: error: 'ISP_FTD_6300' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_FTD_6300'
   ./platform/common/sofia/inc/TLV/OldVideo.h:131: error: conflicting declaration 'ISP_Panasonic_MH3XX'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:6700: error: 'ISP_Panasonic_MH3XX' has a previous declaration as 'ISP_VENDER_AND_TYPE ISP_Panasonic_MH3XX'
解决方法:
屏蔽了ISP_VENDER_AND_TYPE枚举类型

6.

   In file included from ./platform/common/sofia/inc/TLV/tlvdef.h:16,
   from ./platform/common/sofia/stream/adapter/vcu/vcudef.h:5,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:5,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   ./platform/common/sofia/inc/TLV/NewVideo.h:192: error: conflicting declaration 'EXPOSURE_MANUAL'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:6835: error: 'EXPOSURE_MANUAL' has a previous declaration as 'RV_EXPOSURE_MODE EXPOSURE_MANUAL'
   ./platform/common/sofia/inc/TLV/NewVideo.h:193: error: conflicting declaration 'EXPOSURE_AUTO'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:6834: error: 'EXPOSURE_AUTO' has a previous declaration as 'RV_EXPOSURE_MODE EXPOSURE_AUTO'
解决方法：
屏蔽了RV_EXPOSURE_MODE

7.
   In file included from ./platform/common/sofia/inc/TLV/tlvdef.h:17,
   from ./platform/common/sofia/stream/adapter/vcu/vcudef.h:5,
   from ./platform/common/sofia/stream/adapter/sdk/vcusdk.h:5,
   from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:5:
   ./platform/common/sofia/inc/TLV/PtzCmd.h:225: error: conflicting declaration 'typedef struct tagPTZ_OPT_ATTR PTZ_OPT_ATTR'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:5046: error: 'PTZ_OPT_ATTR' has a previous declaration as 'typedef struct PTZ_OPT_ATTR PTZ_OPT_ATTR'
解决方法:
屏蔽了PTZ_OPT_ATTR

8.
   ./platform/common/sofia/inc/TLV/PtzCmd.h:289: error: redefinition of 'struct tagCONFIG_PTZREGRESS'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:7223: error: previous definition of 'struct tagCONFIG_PTZREGRESS'
   ./platform/common/sofia/inc/TLV/PtzCmd.h:294: error: invalid type in declaration before ';' token
   ./platform/common/sofia/inc/TLV/PtzCmd.h:303: error: conflicting declaration 'typedef struct tagNET_CONFIG_PTZREGRESS NET_CONFIG_PTZREGRESS'
   ./platform/common/sofia/stream/adapter/sdk/libsdk.h:7230: error: 'NET_CONFIG_PTZREGRESS' has a previous declaration as 'typedef struct tagCONFIG_PTZREGRESS NET_CONFIG_PTZREGRESS'
解决方法:
屏蔽了tagCONFIG_PTZREGRESS

9.
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:435: error: invalid conversion from
'void (*)(long int, long unsigned int, unsigned char*, long unsigned int, long int)' to 
'void (*)(intptr_t, long unsigned int, unsigned char*, long unsigned int, intptr_t)'
platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:435: error:   initializing argument 2 of 
'int CLIENT_SetRealDataCallBack(intptr_t, void (*)(intptr_t, long unsigned int, unsigned char*, long unsigned int, intptr_t), intptr_t)'
原因是因为原linux版本中的#define intptr_t long
没起作用,目录下的osIndependent.h文件的文件宏定义RV_OSINDEPENDENT_H起了作用 
解决方法:
把目录下的osIndependent.h文件去除
因RELEASE_HEADER在NetClient/dhnetsdk.h中定义，故采用RV_OSINDEPENDENT_H来处理
//建议typedef.h或这osIndepent.h中加上#define intptr_t long 的定义
目前屏蔽了#define intptr_t LONG


10.FRtspCallBack(LONG Handle, unsigned char *pBuffer,int nParam, int nUser)
处理:
暂时屏蔽#define intptr_t LONG




11.
In file included from platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:28:
./platform/common/sofia/stream/adapter/sdk/libsdk.h:43: error: duplicate 'unsigned'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:43: error: multiple types in one declaration
./platform/common/sofia/stream/adapter/sdk/libsdk.h:43: error: declaration does not declare anything
./platform/common/sofia/stream/adapter/sdk/libsdk.h:44: error: duplicate 'unsigned'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:44: error: declaration does not declare anything
解决方法:

43行和44行的typedef unsigned char BYTE
typedef unsigned long DWORD
用#ifndef BYTE
#endif

#ifndef DWORD
#endif


12.
In file included from platform/common/sofia/stream/adapter/sdk/vcusdk.cpp:4:
./platform/common/sofia/stream/adapter/sdk/libsdk.h:61: error: 'DWORD' does not name a type
#ifndef ULONG
typedef DWORD ULONG
#endif


13.
In file included from platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:28:
./platform/common/sofia/stream/adapter/sdk/libsdk.h:5871: error: expected unqualified-id before 'void'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:5871: error: expected initializer before 'void'
./platform/common/sofia/stream/adapter/sdk/libsdk.h:5872: error: multiple types in one declaration
./platform/common/sofia/stream/adapter/sdk/libsdk.h:5872: error: declaration does not declare anything
解决方法:
#ifndef VD_HANDLE
typedef void*  VD_HANDLE;
#endif

#ifndef VD_BOOL
typedef int VD_BOOL;
#endif


14.platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:45: error: 'ECOMPRESSION_MODE_NR' was not declared in this scope
放开:
ECOMPROSSION_MODE定义
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_GET_EncodeMode(int, int, char*)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:225: error: 'fmtlist' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:227: error: 'fmtlist' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp: In function 'int VCU_SET_EncodeMode(int, int, char*)':
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:247: error: 'ECOMPRESSION_MODE_NR' was not declared in this scope
platform/common/sofia/stream/adapter/sdk/vcuapi.cpp:249: error: 'fmtlist' was not declared in this scope

15.typedef  void(CALLBACK * FRtspCallBack)(LONG lHandle unsigned char *pBuffer, int nParam, int nUser);
中的LONG改为intptr_t



















































