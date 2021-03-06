# Type hinting

Что делает любая программа? Оперирует данными, то есть какие-то данные принимает на вход, какие-то данные отдаёт на выход, а внутри данные как-то трансформирует, обрабатывает и передаёт в разные функции, классы, модули и так далее. И весь вопрос в том, в каком виде и формате программа внутри себя эти данные передаёт! То есть — какие типы данных для этого используются. Часто одни и те же данные можно передавать внутри приложения строкой, списком, кортежем, словарём и массой других способов.

Как все мы знаем, Python это язык с динамической типизацией. Что означает динамическая типизация? Что тип переменной определяется не в момент создания переменной, а в момент присваивания значения этой переменной. Мы можем сохранить в переменную строку, потом число, потом список, и это будет работать. Фактически интерпретатор Python сам выводит типы данных и мы их нигде не указываем, вообще не думаем об этом — просто используем то, что нам нужно в текущий момент.

```python
user = "Пётр"
user = 120560
user = {
    "name": "Пётр",
    "username": "petr@email.com",
    "id": 120560
}
user = ("Пётр", "petr@email.com", 120560)
```

Так зачем же вводить type hinting в язык с динамической типизацией? А я напомню, что в Python сейчас есть type hinting, то есть подсказки типов, они же есть в PHP, а в JS даже разработали TypeScipt, отдельный язык программирования, который является надстройкой над JS и вводит типизацию. Зачем это всё делается, для чего? Вроде скриптовые языки, не надо писать типы, думать о них, и всё прекрасно, а тут раз — и вводят какие-то типы данных.

Зачем в динамически типизированном языке вводить явное указание типов?
