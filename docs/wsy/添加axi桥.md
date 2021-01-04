# 添加axi桥



## sram接口到sramlike接口的转变：

![image-20210104174946199](pics/%E6%B7%BB%E5%8A%A0axi%E6%A1%A5/image-20210104174946199.png)

对于i、d两种分别设计了两个，除了固定的信号转化之外，还需要对状态、获取的数据进行锁存：

![image-20210104175033070](pics/%E6%B7%BB%E5%8A%A0axi%E6%A1%A5/image-20210104175033070.png)



## 顶部模块连线

按照从datapath逐层向上请求的思路进行连接：

先将datapath的请求连出：

![image-20210104175158178](pics/%E6%B7%BB%E5%8A%A0axi%E6%A1%A5/image-20210104175158178.png)

将datapath的请求，连接到sram到sramlike的桥上（i\_sram2sram\_like、d）

![image-20210104175241881](pics/%E6%B7%BB%E5%8A%A0axi%E6%A1%A5/image-20210104175241881.png)

这一步将cpu发出的简单信号转化成了对cache的简单信号



将这些信号作为cache的cpuside接入cache：

![image-20210104175320207](pics/%E6%B7%BB%E5%8A%A0axi%E6%A1%A5/image-20210104175320207.png)

cache会生成一系列sram\_like类型的信号，并且期望与外部进行通信

![image-20210104175411700](pics/%E6%B7%BB%E5%8A%A0axi%E6%A1%A5/image-20210104175411700.png)

我们将上图的信号，接入`cpu_axi_interface`之中即可

![image-20210104175437745](pics/%E6%B7%BB%E5%8A%A0axi%E6%A1%A5/image-20210104175437745.png)

![image-20210104175445922](pics/%E6%B7%BB%E5%8A%A0axi%E6%A1%A5/image-20210104175445922.png)

这些信号已经在顶部模块进行了定义：

![image-20210104175510499](pics/%E6%B7%BB%E5%8A%A0axi%E6%A1%A5/image-20210104175510499.png)

## 对数据通路进行相应调整



### 对stall策略的调整

当前阶段，当等待cache交互的时候，需要将流水线进行停顿。

同时，由于cache需要获取流水线的停顿信息，所以我们也需要将流水线控制信息作为输出引入到上层模块。

这一段只需要对`datapath->stall_flush_controller`进行调整即可



对于controller:

![image-20210104180910031](pics/%E6%B7%BB%E5%8A%A0axi%E6%A1%A5/image-20210104180910031.png)



对于datapath而言只需要连线即可：：

对于mips\_cpu而言，也是只需要连线就可以了：

![image-20210104180942976](pics/%E6%B7%BB%E5%8A%A0axi%E6%A1%A5/image-20210104180942976.png)



## 最后的小更改

为了让我们的cpu能够接受longxin的debug，需要把一些信号连接出去，主要就是：

pc、

