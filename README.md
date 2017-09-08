# WeChatPlugin-MacOS


![](https://img.shields.io/badge/platform-osx-lightgrey.svg) 
![](https://img.shields.io/badge/support-wechat%202.2.8-green.svg)
   
微信助手插件   

![](https://ws2.sinaimg.cn/large/006tKfTcly1fjb23vrv0hj30en03a76s.jpg)

---

### 功能
* 消息防撤回
* 单聊撤回消息可自动发出
* 消息自动回复
* 远程控制
* 微信多开

远程控制：

- [x] 屏幕保护
- [x] 清空废纸篓
- [x] 锁屏、休眠、关机、重启
- [x] 退出QQ、WeChat、Chrome、Safari、所有程序
- [x] 网易云音乐(播放、暂停、下一首、上一首、喜欢、取消喜欢)

---

### 功能演示

#### 消息防撤回(不自动发出撤销内容)
* 单聊 <br />
	<img src="https://ws4.sinaimg.cn/large/006tKfTcly1fjb2wkigykg30qy0jmt9e.gif" width="727" height="530" />
	
* 群聊 <br />
	<img src="https://ws1.sinaimg.cn/large/006tKfTcly1fjb31n3amng30qy0jmt9d.gif" width="727" height="530" />
	
#### 消息防撤回(自动发出撤销内容)

* 单聊 <br />
  	<img src="https://ws2.sinaimg.cn/large/006tKfTcly1fjb34p11hcg30qy0jmjse.gif" width="727" height="530" />
  	
* 群聊 <br />
	<img src="https://ws1.sinaimg.cn/large/006tKfTcly1fjb377a3plg30qy0jm0tp.gif" width="727" height="530" />
	
#### 自动回复

* 单聊和群聊一样 <br />
  	<img src="https://ws3.sinaimg.cn/large/006tKfTcly1fjb37sg128g30qy0jm0u0.gif" width="727" height="530" />

#### 微信多开

* 助手菜单 <br />
  	<img src="https://ws2.sinaimg.cn/large/006tKfTcly1fjb3c42o9gj30l20dhgtc.jpg" width="727" height="480" />

#### 远程控制 (测试关闭Chrome、QQ、开启屏幕保护)

* 远程控制菜单 <br />
  	<img src="https://ws1.sinaimg.cn/large/006tKfTcly1fjb3dshfsaj30im0f2ab4.jpg" width="670" height="480" />

---
### 安装

**1. 无安装Xcode**

* 下载WeChatPlugin，用 Termimal 打开项目当前目录，执行 `./Other/Install.sh`即可。

**2. 已安装Xcode**

* 先更改微信的 owner，否则会出现类似**Permission denied**的错误。 

```bash
sudo chown -R $(whoami) /Applications/WeChat.app
```

* 错误 <br />

 	<img src="https://ws3.sinaimg.cn/large/006tKfTcly1fjb3g1l69bj30j901jweu.jpg" width="600" height="30" />

* 下载 WeChatPlugin, 用Xcode打开，先进行 Build (`command + B`)，之后 Run (`command + R`)即可启动微信，此时插件注入完成。
 
* 若 Error，提示找不到 Framework，先进行 Build。

---

### 卸载

在Terminal中，运行 `./Other/Uninstall.sh` 即可

