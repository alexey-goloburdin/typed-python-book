# Опциональные данные

Для указания опциональных данных можно пользоваться вертикальной чертой:

```python
def print_hello(name: str | None=None) -> None:
    print(f"hello, {name}" if name is not None else "hello anon!")
```

Здесь параметр `name` функции `print_hello` является опциональным, что отражено а) в type hinting (напомню, вертикальная черта в подсказках типов означает ИЛИ) б) задано значение по умолчанию None.
