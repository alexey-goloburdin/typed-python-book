# Интерпретатор не проверяет подсказки типов

Важно! Здесь стоит отметить, что подсказки типов именно что подсказки. Они не проверяются интерпретатором Python. Они читаются людьми, это подсказка для людей, они читаются IDE, это подсказка для IDE, они могут читаться специальными средствами статического анализа кода вроде `mypy`, это подсказка для них. Но сам интерпретатор не проверяет типы. Если вы укажете type hinting для атрибута функции как `int`, а сами передадите строку — интерпретатор не свалит здесь ошибку, для него в этом не будет проблемы. Имейте это в виду.

```python
def plus_two(num: int):
    print("мы в функции plus_two")
    return num + 2

print(plus_two(5))
# мы в функции plus_two
# 7
```

Мы имеем функцию `plus_two`, которая к переданному аргументу `num` типа `int` прибавляет число `2` и возвращает результат. В этом примере приведено правильное использование этой функции, она вызывается с целочисленным аргументом `5`. Программа работает корректно. 

Теперь вызовем функцию с неправильным типом аргумента:

```python
print(plus_two("5"))
# мы в функции plus_two
# TypeError: can only concatenate str (not "int") to str
```

С точки зрения проверки типов эта программа некорректна и на строке, где мы неправильным образом вызываем функцию `plus_two`, у нас покажется ошибка в нашем редакторе кода, также эту ошибку типов покажет и статический анализатор кода вроде `mypy`.

Но интерпретатор именно эту ошибку не заметит. Он не проверяет типы, указанные в type hinting. Обратите внимание — несмотря на то, что функция вызывается явно с неправильным типом данных аргумента `num`, она всё равно запускается, так как `print("мы в функции plus_two")` срабатывает. Функция запускается и «падает» уже тогда, когда мы пытаемся сложить строку `"5"` и число `2`. 

Python — это по-прежнему язык с динамической типизацией, а подсказки типов являются именно что подсказками для разработчика, IDE и анализатора кода, эти подсказки призваны упростить жизнь разработчику и снизить количество ошибок в рантайме. Интерпретатор на подсказки типов внимания не обращает.

**Итак, подводя промежуточный итог**: подсказки типов это очень важно и вам точно следует их изучить и ими пользоваться. А как подсказками типов пользоваться и какие есть варианты — поговорим подробнее дальше.

