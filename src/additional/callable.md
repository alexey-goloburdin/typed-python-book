# Вызываемые объекты

Как известно функции в Python это обычные объекты, которые можно передавать в другие функции, возвращать из других функций и т. п., поэтому для них тоже есть свой тип `Callable`:

```python
from typing import Callable

def mysum(a: int, b: int) -> int:
    return a + b


def process_operation(operation: Callable[[int, int], int],
                      a: int, b: int) -> int:
    return operation(a, b)

print(process_operation(mysum, 1, 5))  # 6
```

Здесь для аргумента `operation` функции `process_operation` проставлен тип `Callable[[int, int], int]`. Здесь `[int, int]` — это типы аргументов функции `operation`, получается, что у этой функции должно быть два аргумента и они оба должны иметь тип `int`. Последний `int` в определении типа `Callable[[int, int], int]` обозначает тип возвращаемого функцией значения.
