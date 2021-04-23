# 领域驱动设计

## 定义

领域驱动设计（Domain-driven-design）


## 战略设计

### 统一语言

用一致的方法去表达设计，确保业务、产品、设计、开发、测试等人员理解一致。

### 领域拆分

领域的拆分：

- **核心域**：其所体现的是核心服务，是代表着产品的核心竞争力。
- **支撑域**：其所体现的是支撑服务，没它不行，但又达不到核心的价值，围绕着产品内部所需要，但又不能单独变更为第三方服务，即它不是一个通用的服务。
- **通用域**：其所体现的中间件服务或第三方服务。本身可以通过现有的解决方案集成来完成的服务。

### 界限上下文

### 分层架构

- **User Interface** 为用户界面层，向用户展示信息和传入用户命令。这里指的用户不单单只使用用户界面的人，也可能是外部系统，诸如用例中的参与者。
- **Application** 为应用层，用来协调应用的活动，不包含业务逻辑，通过编排领域模型，包括领域对象及领域服务，使它们互相协作。不保留业务对象的状态，但它保有应用任务的进度状态。
- **Domain** 为领域层，负责表达业务概念，业务状态信息以及业务规则。尽管保存业务状态的技术细节是由基础设施层实现的，但是反映业务情况的状态是由本层控制并且使用的。领域层是业务软件的核心，领域模型位于这一层。
- **Infrastructure** 为基础实施层，提供公共的基础设施组件，如持久化机制、消息管道的读取写入、文件服务的读取写入、调用邮件服务、对外部系统的调用等等。

## 战术设计

## 参考链接

[https://www.cnblogs.com/CKExp/p/14289377.html](https://www.cnblogs.com/CKExp/p/14289377.html)