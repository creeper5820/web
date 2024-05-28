---
title: can_tutorial
date: 2024-05-12 10:58:16
---

## 引子

现在是2024年1月18号晚上零点半，电路工数等困难科目已经考完，只是剩一门马原

临近寒假的这一段时间颇为闲暇，于是在工作室寻得一些 **M2006无刷电机**和 **C610电调** ，加上手头上的 **C板**，试着组一台个人未来比赛用的四驱底盘

依据大疆资料来看，电调需要使用CAN通信来控制，正中知识盲区，于是放下手中的马原教材（其实根本没有拿起来过），学习一下CAN

## 环境准备

### 前置知识
- STM32CubeMX的使用
- 一定的C语言使用经验

### 软件环境

- 代码生成 `STM32CubeMX`
- 编译工具 `arm-none-eabi工具链`
- 编写环境 `VSCode`+`Embedded IDE`
- 调试工具 `Ozone`

### 硬件环境

- 主控芯片 `大疆C板-STM32F407IG`
- 烧录工具 `JLink`
- 通讯目标 `C610电调`

## CAN的初印象

### 何为CAN？

在查阅了很多资料后，我提取了几个关键词：`总线结构`，`串行通讯`，`标准协议`，只需要两条线，即可解决沿途中设备的通信需求，例如，使用一块主控板加上CAN总线就可以很轻松的控制多个电机，极大缓解了布线带给我们的`焦虑`

<center>
<img src=https://img-blog.csdnimg.cn/direct/0334eb74241d49979182c2ec0562302b.jpeg 
    width=80% 
    />
</center>
<center>
布线地狱
</center>
</br>

至于书面，准确，乃至于繁缛的官方定义，我便不写入文章里，百度看看就好

### CAN的硬件组成

我们可以称一个通讯单元为**节点**，一个节点一般有三个部分：**微控制器**， **CAN控制器**，**CAN收发器**，总线两端须串上120Ω的电阻，以模拟无限远传输线的特性阻抗，通过开关等手段来选择是否使用这个电阻

<center>
<img src=https://img-blog.csdnimg.cn/direct/fc40ed4d25ce4e14b155bb0b385efd73.png
    width=80% 
    />
</center>
<center>
CAN总线结构
</center>
</br>

STM32芯片会自带CAN外设拓展，名为**bxCAN** `(Basic Extended CAN  - 基本拓展CAN)`，详细内容此处不展开

## CAN通信初试

姑且暂停理论部分的讲解，**繁杂的原理**总是令人头大，使人望而却步，我们先**启动**开发软件，走通一个通讯的流程，再来细细分析其中的缘由，或者跳过理论，只掌握软件层的流程也是可以的

基本步骤：`配置STM32CubeMX` > `配置CAN过滤器` > `发送接收报文`

### 配置STM32CubeMX

启动CubeMX，选好芯片类型创建项目，首先把**常规设置**搞定

<center>
<img src=https://img-blog.csdnimg.cn/direct/5c952ce9d3e74729bef9badd88baf38f.png
    width=80% 
    />
</center>
<center>
RCC设置
</center>
</br>

<center>
<img src=https://img-blog.csdnimg.cn/direct/14c833c93c1a4343911d8267e5a1948c.png
    width=80% 
    />
</center>
<center>
SWD设置
</center>
</br>

<center>
<img src=https://img-blog.csdnimg.cn/direct/62a9fa51e5ad40258de9884d6d7edf0d.png
    width=80% 
    />
</center>
<center>
时钟设置
</center>
</br>

<center>
<img src=https://img-blog.csdnimg.cn/direct/5ce51f07fb40420098f0e63340972fea.png
    width=80% 
    />
</center>
<center>
.c文件和.h文件分开生成
</center>
</br>

项目管理类型之类的根据**自己使用的开发环境**来设置即可

简单写一个点灯测试一下

这是板载灯的连线

- `TIM5_CH1` - `LED_BLUE`
- `TIM5_CH2` - `LED_GREEN`
- `TIM5_CH3` - `LED_RED`

```cpp
void breath_led()
{
    for (int i = 0; i < 100; i++) {
        HAL_Delay(10);
        __HAL_TIM_SetCompare(&htim5, TIM_CHANNEL_1, 20000 * i / 100);
        __HAL_TIM_SetCompare(&htim5, TIM_CHANNEL_2, 20000 * i / 100);
        __HAL_TIM_SetCompare(&htim5, TIM_CHANNEL_3, 20000 * i / 100);
    }

    for (int i = 100; i > 0; i--) {
        HAL_Delay(10);
        __HAL_TIM_SetCompare(&htim5, TIM_CHANNEL_1, 20000 * i / 100);
        __HAL_TIM_SetCompare(&htim5, TIM_CHANNEL_2, 20000 * i / 100);
        __HAL_TIM_SetCompare(&htim5, TIM_CHANNEL_3, 20000 * i / 100);
    }
}
```
将其放入主循环中运行，理所应当地成功了
<center>
<img src=https://img-blog.csdnimg.cn/direct/1d9fc725662a4a28b4bf8b925585b0fc.jpeg
    width=80% 
    />
</center>
<center>
呼吸灯测试
</center>
</br>

现在开始配置**CAN通信**

CubeMX界面中，在`CAN1`的**Parameter Settings**我们可以看到

- **Bit Timings Parameters** - 配置传输速度
    - **Prescaler (for Time Quantum)** - 分频，调整TQ（Time Quantum）大小
    - Time Quantum - 最小时间单位
    - **Time Quanta in Bit Segment 1** - 相位缓冲段1段占几个TQ
    - **Time Quanta in Bit Segment 2** - 相位缓冲段2段占几个TQ
    - Time for one Bit
    - Baud Rate - 波特率
    - **ReSynchronization Jump Width** - 再同步补偿宽度
- **Basic Parameters** - 基本参数
    - Time Triggered Communication Mode - 时间触发模式
    - Automatic Bus-off Management - 自动离线管理
    - Automatic Wake-Up Mode - 自动唤醒
    - Automatic Retransmission - 自动重传
    - Receive Fifo Locked Mode - 锁定模式
    - Transmit Fifo Priority - 报文发送优先级
- **Advanced Parameters** - 高级参数
    - **Operating Mode** -*运行模式：`正常模式` `静默模式` `回环模式` `回环静默模式`

而 **NVIC Interrupt Table** 中有

- CAN1 TX interrupts
- CAN1 RX0 interrupts
- CAN1 RX1 interrupt
- CAN1 SCE interrupt

这是我们初期需要关注的配置列表

**1. 设置波特率**

以我的需求为例，查阅大疆官方资料可以得知

> 将 CAN 信号线连接到控制板接收 CAN 控制指令，CAN 总线比特率为 1Mbps。

所以我们需要将CAN通讯的比特率 `baud rate` 设置为 `1000000 bit/s`

根据波特率计算公式 baud rate = TQ * ( TBS1 + TBS2 + SJY) , 我们得到如下设置

<center>
<img src=https://img-blog.csdnimg.cn/direct/bac1aba73d1040cfa061ecc028c35bfa.png
    width=80% 
    />
</center>
<center>
TQ * ( 11 + 2 + 1) = 1000ns
</center>

根据实际情况计算一下即可，也可以多选几个选项，把正确的波特率尝试出来，**灰色的选项**就是CubeMX帮我们计算好的数值

**2. 打开中断**

处理电调发送的电机信息，需要中断来调用回调函数，于是打开**接收中断**

这里我使用的单片机中，CAN外设具有两个用于接收信息的**邮箱**，我们命其为 `FIFO0`和`FIFO0`，每个邮箱都有**一个过滤器**，用于筛选报文，可以存放**三条报文**，在**中断设置**中对应 `CAN1 RX0 interrupt`和`CAN1 RX1 interrupt`，我们打开需要使用的那一个就可以

<center>
<img src=https://img-blog.csdnimg.cn/direct/f3a40ac4efe94be79b876c875cedbbf1.png
    width=80% 
    />
</center>

既然存在接收邮箱，相应的，就有**发送邮箱**，我们现在只要知道发送邮箱存在**发送优先级**且每个邮箱只能存放**一条报文**

现在，我们已经在CubeMX中配置好了CAN，下一步就是要配置**CAN过滤器**

### 配置CAN过滤器

前面我们说到，STM32上有两个**邮箱**用于接收报文，为了接收我们想要的报文，我们需要配置一下过滤器，把不想接受的报文过滤掉，只放行想要的报文

配置过滤器需要我们自己手写，并未提前生成，但HAL库提供了过滤器配置参数的结构体类型，我们只需要**给这个结构体赋值**，然后**调用HAL提供的初始化函数**即可完成配置

```cpp
// Drivers\STM32F4xx_HAL_Driver\Inc\stm32f4xx_hal_can.h

// 过滤器结构体
typedef struct
{
  uint32_t FilterIdHigh;
  uint32_t FilterIdLow;
  uint32_t FilterMaskIdHigh;
  uint32_t FilterMaskIdLow; 
  uint32_t FilterFIFOAssignment; 
  uint32_t FilterBank;        
  uint32_t FilterMode;
  uint32_t FilterScale;
  uint32_t FilterActivation; 
  uint32_t SlaveStartFilterBank; 
} CAN_FilterTypeDef;

// 配置函数
HAL_StatusTypeDef HAL_CAN_ConfigFilter(
    CAN_HandleTypeDef *hcan, 
    CAN_FilterTypeDef *sFilterConfig
    );
```

具体的使用和结构体的定义随后再讲，我们只需要对这个结构体和函数有一个**大概的印象**即可

### 发送接收报文

首先是**发送**

我预期使用一块主控与四个电机通信，那么在发送报文时，就需要指定**发送给哪一个电机**，以及**其他一些信息**，比如发送`信息的长度`，`信息的类型`，`信息ID类型`等等，HAL把这些发送需要的信息定义成了一个结构体 `CAN_TxHeaderTypeDef`,我们只需要为每一个电机声明一个 CAN_TxHeaderTypeDef 结构体，再确定好发送的数据内容，就可以将数据发送到指定的电机中

我们回想一下，在设置接收中断时，是不是提到了**邮箱**的概念？**STM32F407IGHx**为我们提供了三个**发送邮箱**，在发送时，需要指定使用哪一个邮箱

HAL库理所应当地帮我们写好了发送的函数，只要传入`can的句柄`，`报文头结构体`，`数据信息`和`邮箱编号`即可

```cpp
// Drivers\STM32F4xx_HAL_Driver\Inc\stm32f4xx_hal_can.h

// 发送函数的声明
HAL_StatusTypeDef HAL_CAN_AddTxMessage(
    CAN_HandleTypeDef *hcan, 
    CAN_TxHeaderTypeDef *pHeader, 
    uint8_t aData[], 
    uint32_t *pTxMailbox
    )；

// 邮箱编号的定义
#define CAN_TX_MAILBOX0             (0x00000001U)  /*!< Tx Mailbox 0  */
#define CAN_TX_MAILBOX1             (0x00000002U)  /*!< Tx Mailbox 1  */
#define CAN_TX_MAILBOX2             (0x00000004U)  /*!< Tx Mailbox 2  */
```
在实际使用中，我们可以对邮箱进行轮询，使用**空闲的那一个邮箱**

然后是**接收**

总线上的报文在经过了我们设置的**过滤器**后，正确的报文会**触发**我们设置的**中断**，我们便可以在中断的**回调函数**中对收到的数据进行处理了

我们只需要找到HAL库为我们提供的中断函数，对其进行覆写即可

```cpp
// 这是一种使用情况

// 回调函数
void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan)
{
	if(hcan->Instance ==CAN1)
	{
	  HAL_CAN_GetRxMessage(&hcan1, CAN_RX_FIFO0, &RxHeader, date_CAN1); 
	  return ;
	}
}

// 这个函数可以从报文中分离出我们想要的信息
HAL_StatusTypeDef HAL_CAN_GetRxMessage(
    CAN_HandleTypeDef *hcan,            // can句柄
    uint32_t RxFifo,                    // 接收邮箱编号
    CAN_RxHeaderTypeDef *pHeader,       // 接收报文头
    uint8_t aData[]                     // 数据
    )；

// 接收邮箱编号的定义
#define CAN_RX_FIFO0                (0x00000000U)  /*!< CAN receive FIFO 0 */
#define CAN_RX_FIFO1                (0x00000001U)  /*!< CAN receive FIFO 1 */
```

现在我们配置过滤器和发送接收这两个流程应该是有了一个**大概的认知**，来做一个简单的测试吧

将运行模式设置为**回环发送**，我们就可以收到自己发送的报文，前提是能通过邮箱过滤，其他配置依照上文即可

<center>
<img src=https://img-blog.csdnimg.cn/direct/9662f70acc644e3897a03f64c5d34d2b.png
    width=80% 
    />
</center>

记得重新生成代码

然后我们写一个过滤器的配置

```cpp
void can_filter_init()
{
    CAN_FilterTypeDef filter;

    // 报文头结构体的赋值
    // 此处配置为接收全部报文，以便于测试
    filter.FilterActivation     = ENABLE;                   // 启用过滤器
    filter.FilterBank           = 0;                        // 过滤器编码
    filter.FilterMode           = CAN_FILTERMODE_IDMASK;    // 掩码模式
    filter.FilterScale          = CAN_FILTERSCALE_32BIT;    // 32位宽
    filter.FilterFIFOAssignment = CAN_FILTER_FIFO0;         // 配置邮箱0
    filter.FilterIdHigh         = 0x0000;                   // 高位0
    filter.FilterIdLow          = 0x0000;                   // 低位0
    filter.FilterMaskIdHigh     = 0x0000;                   // 掩码高位不检测
    filter.FilterMaskIdLow      = 0x0000;                   // 掩码低位不检测

    // 将配置加载进CAN 1中
    HAL_CAN_ConfigFilter(&hcan1, &filter);
}
```

初始化CAN

```cpp
void can_init()
{
    can_filter_init();                                                  // 过滤器
    HAL_CAN_Start(&hcan1);                                              // 开启CAN通讯
    HAL_CAN_ActivateNotification(&hcan1, CAN_IT_RX_FIFO0_MSG_PENDING);  // 开启接收中断
}
```

声明一些必要的变量

```cpp
uint8_t can_1_rx[8];    // 接收数据
uint8_t can_1_tx[8];    // 发送数据

CAN_RxHeaderTypeDef can_1_rx_header;    // 接收报文头
CAN_TxHeaderTypeDef can_1_tx_header;    // 发送报文头

uint32_t mail_tx = CAN_TX_MAILBOX0;     // 发送邮箱编号
```

初始化一些参数

```cpp
// 随便创建一种发送报文头结构体
can_1_tx_header.StdId              = 0x00000000;
can_1_tx_header.ExtId              = 0x12345000;
can_1_tx_header.IDE                = CAN_ID_EXT;
can_1_tx_header.RTR                = CAN_RTR_DATA;
can_1_tx_header.DLC                = 8;
can_1_tx_header.TransmitGlobalTime = DISABLE;

// 初始化一些发送的数据
can_1_tx[0] = 1;

// 要使用的灯记得开启，根据自己的板子写即可
HAL_TIM_PWM_Start(&htim5, TIM_CHANNEL_1);
// 刚才写的初始化函数用上
can_init();
```

回调函数的覆写

```cpp
void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan)
{
    if (hcan->Instance == CAN1) {
        HAL_CAN_GetRxMessage(&hcan1, CAN_RX_FIFO0, &can_1_rx_header, can_1_rx);

        // 简单根据接收数据内容做一个反馈，点亮或熄灭板载灯
        // 根据自己的板子替换一下点灯的函数
        if(can_1_rx[0] == 0)
        {
            __HAL_TIM_SetCompare(&htim5, TIM_CHANNEL_1, 20000);
        }
        else if(can_1_rx[0] == 1)
        {
            __HAL_TIM_SetCompare(&htim5, TIM_CHANNEL_1, 0);
        }

        return;
    }
}
```

在主循环中不断发送报文

```cpp
HAL_CAN_AddTxMessage(&hcan1, &can_1_tx_header, can_1_tx, &mail_tx);
```

这是 main.c ，注意根据自己使用的板子情况**进行修改**

```cpp
/* USER CODE BEGIN Header */
/**
 ******************************************************************************
 * @file           : main.c
 * @brief          : Main program body
 ******************************************************************************
 * @attention
 *
 * Copyright (c) 2024 STMicroelectronics.
 * All rights reserved.
 *
 * This software is licensed under terms that can be found in the LICENSE file
 * in the root directory of this software component.
 * If no LICENSE file comes with this software, it is provided AS-IS.
 *
 ******************************************************************************
 */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "can.h"
#include "tim.h"
#include "gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Private typedef -----------------------------------------------------------*/
/* USER CODE BEGIN PTD */

/* USER CODE END PTD */

/* Private define ------------------------------------------------------------*/
/* USER CODE BEGIN PD */

/* USER CODE END PD */

/* Private macro -------------------------------------------------------------*/
/* USER CODE BEGIN PM */

/* USER CODE END PM */

/* Private variables ---------------------------------------------------------*/

/* USER CODE BEGIN PV */

uint8_t can_1_rx[8]; // 接收数据
uint8_t can_1_tx[8]; // 发送数据

CAN_RxHeaderTypeDef can_1_rx_header; // 接收保报文头
CAN_TxHeaderTypeDef can_1_tx_header; // 发送报文头

uint32_t mail_tx = CAN_TX_MAILBOX0; // 发送邮箱编号

/* USER CODE END PV */

/* Private function prototypes -----------------------------------------------*/
void SystemClock_Config(void);
/* USER CODE BEGIN PFP */

void can_filter_init();
void can_init();

/* USER CODE END PFP */

/* Private user code ---------------------------------------------------------*/
/* USER CODE BEGIN 0 */

void can_filter_init()
{
    CAN_FilterTypeDef filter;

    // 报文头结构体的赋值
    // 此处配置为接收全部报文，以便于测试
    filter.FilterActivation     = ENABLE;                // 启用过滤器
    filter.FilterBank           = 0;                     // 过滤器编码
    filter.FilterMode           = CAN_FILTERMODE_IDMASK; // 掩码模式
    filter.FilterScale          = CAN_FILTERSCALE_32BIT; // 32位宽
    filter.FilterFIFOAssignment = CAN_FILTER_FIFO0;      // 配置邮箱0
    filter.FilterIdHigh         = 0x0000;                // 高位0
    filter.FilterIdLow          = 0x0000;                // 低位0
    filter.FilterMaskIdHigh     = 0x0000;                // 掩码高位不检测
    filter.FilterMaskIdLow      = 0x0000;                // 掩码低位不检测

    // 将配置加载进CAN 1中
    HAL_CAN_ConfigFilter(&hcan1, &filter);
}

void can_init()
{
    can_filter_init();                                                 // 过滤器
    HAL_CAN_Start(&hcan1);                                             // 开启CAN通讯
    HAL_CAN_ActivateNotification(&hcan1, CAN_IT_RX_FIFO0_MSG_PENDING); // 开启接收中断
}

void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan)
{
    if (hcan->Instance == CAN1) {
        HAL_CAN_GetRxMessage(&hcan1, CAN_RX_FIFO0, &can_1_rx_header, can_1_rx);

        // 简单根据接收数据内容做一个反馈，点亮或熄灭板载灯
        // 根据自己的板子替换一下点灯的函数
        if (can_1_rx[0] == 0) {
            __HAL_TIM_SetCompare(&htim5, TIM_CHANNEL_1, 20000);
        } else if (can_1_rx[0] == 1) {
            __HAL_TIM_SetCompare(&htim5, TIM_CHANNEL_1, 0);
        }

        return;
    }
}

/* USER CODE END 0 */

/**
 * @brief  The application entry point.
 * @retval int
 */
int main(void)
{
    /* USER CODE BEGIN 1 */

    /* USER CODE END 1 */

    /* MCU Configuration--------------------------------------------------------*/

    /* Reset of all peripherals, Initializes the Flash interface and the Systick. */
    HAL_Init();

    /* USER CODE BEGIN Init */

    /* USER CODE END Init */

    /* Configure the system clock */
    SystemClock_Config();

    /* USER CODE BEGIN SysInit */

    /* USER CODE END SysInit */

    /* Initialize all configured peripherals */
    MX_GPIO_Init();
    MX_TIM4_Init();
    MX_TIM5_Init();
    MX_CAN1_Init();
    /* USER CODE BEGIN 2 */

    // 随便创建一种发送报文头结构体
    can_1_tx_header.StdId              = 0x00000000;
    can_1_tx_header.ExtId              = 0x12345000;
    can_1_tx_header.IDE                = CAN_ID_EXT;
    can_1_tx_header.RTR                = CAN_RTR_DATA;
    can_1_tx_header.DLC                = 8;
    can_1_tx_header.TransmitGlobalTime = DISABLE;

    can_1_tx[0] = 1;

    HAL_TIM_PWM_Start(&htim5, TIM_CHANNEL_1);
    can_init();

    /* USER CODE END 2 */

    /* Infinite loop */
    /* USER CODE BEGIN WHILE */
    while (1) {

        HAL_CAN_AddTxMessage(&hcan1, &can_1_tx_header, can_1_tx, &mail_tx);

        /* USER CODE END WHILE */

        /* USER CODE BEGIN 3 */
    }
    /* USER CODE END 3 */
}

/**
 * @brief System Clock Configuration
 * @retval None
 */
void SystemClock_Config(void)
{
    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

    /** Configure the main internal regulator output voltage
     */
    __HAL_RCC_PWR_CLK_ENABLE();
    __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

    /** Initializes the RCC Oscillators according to the specified parameters
     * in the RCC_OscInitTypeDef structure.
     */
    RCC_OscInitStruct.OscillatorType      = RCC_OSCILLATORTYPE_HSI;
    RCC_OscInitStruct.HSIState            = RCC_HSI_ON;
    RCC_OscInitStruct.HSICalibrationValue = RCC_HSICALIBRATION_DEFAULT;
    RCC_OscInitStruct.PLL.PLLState        = RCC_PLL_ON;
    RCC_OscInitStruct.PLL.PLLSource       = RCC_PLLSOURCE_HSI;
    RCC_OscInitStruct.PLL.PLLM            = 8;
    RCC_OscInitStruct.PLL.PLLN            = 168;
    RCC_OscInitStruct.PLL.PLLP            = RCC_PLLP_DIV2;
    RCC_OscInitStruct.PLL.PLLQ            = 4;
    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK) {
        Error_Handler();
    }

    /** Initializes the CPU, AHB and APB buses clocks
     */
    RCC_ClkInitStruct.ClockType      = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource   = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider  = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;

    if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5) != HAL_OK) {
        Error_Handler();
    }
}

/* USER CODE BEGIN 4 */

/* USER CODE END 4 */

/**
 * @brief  This function is executed in case of error occurrence.
 * @retval None
 */
void Error_Handler(void)
{
    /* USER CODE BEGIN Error_Handler_Debug */
    /* User can add his own implementation to report the HAL error return state */
    __disable_irq();
    while (1) {
    }
    /* USER CODE END Error_Handler_Debug */
}

#ifdef USE_FULL_ASSERT
/**
 * @brief  Reports the name of the source file and the source line number
 *         where the assert_param error has occurred.
 * @param  file: pointer to the source file name
 * @param  line: assert_param error line source number
 * @retval None
 */
void assert_failed(uint8_t *file, uint32_t line)
{
    /* USER CODE BEGIN 6 */
    /* User can add his own implementation to report the file name and line number,
       ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */
    /* USER CODE END 6 */
}
#endif /* USE_FULL_ASSERT */

```

在ozone中查看参数，并实时修改发送数据的数值，发现接收数据也会实时修改，板载灯反馈正常

若不能使用ozone，也可以在代码中修改发送的数值，重新烧录，查看板载灯的情况

<center>
<img src=https://img-blog.csdnimg.cn/direct/b9f8c4761d6f417087f7213b0a7d41ca.png
    width=60% 
    />
</center>

回环测试正常，我们可以进行下一步的了解

## CAN的熟练掌握

在囫囵吞枣地走通过一遍流程后，我们遇到很很多**复杂的模式和结构体**，这些需要根据实际情况来酌情配置