**禁用 Python 输出缓冲：**

你可以通过设置 `PYTHONUNBUFFERED` 环境变量来禁用缓冲：

```
nohup python3 -u hello.py &
```

`-u` 选项会使得标准输出和标准错误立即刷新到文件中。

**修改 Python 代码：**

你也可以在代码中使用 `sys.stdout.flush()` 来强制刷新输出缓冲区：

```

import time
import sys

while True:
    time.sleep(0.3)
    print("hello world")
    sys.stdout.flush()
```

