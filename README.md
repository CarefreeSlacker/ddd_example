# CtiKaltura

Реализует редирект клиента на ближайший Edge сервер в CDN сети.

# Amnesia
В качестве базы данных в CtiKaltura используется Amnesia враппер на Elixir вокруг Mnesia.
Позволяет пользоваться Mnesia гораздо удобнее. Например при запросе возвращает структуру с именованными полями
а не кортеж, где надо разбираться какое значение является каким полем. 
Таблицы описаны в файле `/lib/cti_kaltura/caching/domain_model.ex`
Перед использованием необходимо инициировать базу данных.

```elixir
mix amnesia.create -d DomainModel --memory
```

Схема будет создана, параметр `--memory` указывает на то, что данные будут храниться в памяти.

## Возможные проблемы

### Изменение атрибутов одной из таблиц

Если изменились поля одной из таблиц DomainModel, то операции чтения и записи будут возвращать :badarg.

Причина:     
Схема сохранена на диск и она содержит старую структуру таблиц.      

Решение:      
Локально или после деплоя - дропнуть и создать заново схему базу данных.     

```elixir
mix amnesia.drop -d DomainModel
mix amnesia.create -d DomainModel --memory
mix amnesia.create_indexes
```

### Что делать в продакшн режиме или на стейдже при изменении атрибутов одной из таблиц

1. Зайти по SSH на один из узлом
2. Необходимо чтобы одновременно оба узла были запущены.
3. Зайти в удалённую консоль на один из узлов `./cti_kaltura remote_console`
4. Выполнить следующий код:

```
alias CtiKaltura.ReleaseTasks
ReleaseTasks.make_mnesia_cluster_again()
```

5. Дождаться завершения работы скрипта.  

# Нагрузочное тестирование

Как фреймворк для нагрузочного тестирования используется "k6" https://github.com/loadimpact/k6

Документация доступна по ссылке https://docs.k6.io/docs

Скачайте и установите фреймворк по указаниям на Github.
Сделайте файл k6 исполняемым, чтобы можно было запускать тесты с помошью `k6 --option1 --option2 load_testing/test.js` 

Файлы нагрузочного тестирования находятся в `load_testing/*`

Для проведения проверки live запросов, необходимо запустить:
`k6 run --vus 300 --rps 200 --duration 300s load_testing/test_live.js`, где:

* `--vus` - количесво виртуальных пользователей;
* `--rps` - количесво запросов в секунду;
* `--duration` - продолжительность тестирования. Доступные форматы: 40s, 20m40s.

Для тестирования всех запросов:      
`k6 run --vus 300 --rps 200 --duration 300s load_testing/test_requests.js`     

Также доступна возможность строить более сложные сценарии скриптов - разное количество людей, разное количество 
запросов, разная продолжительность тестирования. Для этого используйте опции https://docs.k6.io/docs/options 
Необходимо пометить соответствующие настройки в переменную `options` и запустить тест без параметров. 

# Деплой

Деплой осуществляется при помощи скрипта `deploy.sh`, располагающегося в корне проекта.
Прежде чем задеплоить на стейдж убедитесь что у вас добавлен пароль для удалённого доступа по ssh на:
1. `admintv@10.15.2.20` - для production core1;
2. `admintv@172.16.2.143` - для stage core1.
2. `admintv@172.16.2.6` - для stage core2.

Команды деплоя:
1. Чтобы задеплоить на production core1 - `./deploy.sh prod1`;
2. Чтобы задеплоить на production core2 - `./deploy.sh prod2` (Пока второго сервера нет);
3. Чтобы задеплоить на stage core1 - `./deploy.sh stage1`;
4. Чтобы задеплоить на stage core2 - `./deploy.sh stage2`.

## Изменения в assets

Если были внесены изменения в ассеты (Добавлены, изменены css или js файлы), необходимо сгенерировать новый дайджест: `mix phx.digest`.
После этого будут внесены изменения в priv/static - необходимо закоммитить изменния и запушить.
После деплоя - изменения будут доступны на сервере.

## Миграции

После деплоя автоматически прогоняются миграции с помощью команды `migrate`
Если необходимо выполнить их в ручную - запустите `~/cti_kaltura/bin/cti_kaltura migrate`

## Подготовка к деплою

Прежде чем задеплоить проект, необходимо выполнить подготовительные работы на сервере. Необходимо:

1. Создать на стейдж сервере пользователя `admintv` для production или `app` для stage.      
Далее действия будут описываться за пользователя `admintv`;    
2. Установить git;
3. Для пользователя `admintv` установить на стейдж сервер соответствующие версии Elixir и Elrang. 
Указанные в файле `.tool-versions`. На момент написания документации: Elixir - 1.6.3, Erlang - 20.2.2.

*(!)* На серверах стоит старая версия CentOS. Её не удаётся установить с помощью ASDF. 
Необходимо установить уже готовую версию. Для этого:
* Установите необходимые библиотеки

```
sudo yum install g++ openssl-devel unixodbc-devel autoconf ncurses-devel
```

* Скачайте и установите подходящую для вашей операционной системы версию https://www.erlang-solutions.com/resources/download.html 

```
$ wget https://packages.erlang-solutions.com/erlang/rpm/centos/6/x86_64/esl-erlang_20.2.2-1~centos~6_amd64.rpm

$ sudo rpm -Uvh esl-erlang_20.2.2-1~centos~6_amd64.rpm
```

* Ответ взят с https://stackoverflow.com/questions/38554378/centos-how-do-i-install-a-specific-version-of-erlang

4. Установить или использовать имеющуюся Postgres. Добавить необходимую базу данных, которая будет 
использоваться в проекте. Необходимо добавить разрешение на авторизацию в pg_hba.conf:   

```
local   all         postgres                          ident
```

Ссылка на объяснение проблемы:    
`https://stackoverflow.com/questions/7695962/postgresql-password-authentication-failed-for-user-postgres`    

5. За пользователя `admintv` создать папку `/home/admintv/cti_kaltura_build/`.
Создать папку `/home/admintv/cti_kaltura_build/build` внутри.

6. Прописать настройки БД и IP в конфигурации для соответствующего окружения для CtiKaltura.Repo, CtiKaltura.Endpoint.
В файл `/home/admintv/cti_kaltura_build/prod.secret.exs` при компиляции он автоматически подхватывается и испоьзуются при
компиляции настроек проекта.

7. Загрузить и настроить NGINX. Ниже описанны настройки и причина почему они должны быть добавлелны:

7.1 Основная причина - только системные утилиты могут быть запущены на порте меньшем 1000.
Следовательно проект должен быть запущен под root пользователем, что плохо.
Вместо этого мы запускаем за пользователя admintv на 4000 и 4001 портах.
* Запросы к 4000 порту не проксируем, если будет необходимо - пользователи зайдут сами по 4000 порту.

Добавить в конфигурацию NGINX секцию:

```
server {
  listen 80;
  server_name _;
}
```

7.2 При проксирвоании через NGINX IP адрес запроса - становится IP адресом NGINX.
Следовательно мы не можем определить IP адрес с которого пришёл запрос.
IP клиента было решено передавать в качетсве `http` заголовка.
Добавить в секцию `server`:

```   
proxy_set_header  Host            $host;
proxy_set_header  X-Real-IP       $remote_addr;
proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
```

Соответственно проект будет читать IP адрес из `X-Real-IP` заголовка, если его нет - из `remote_ip` из %Plug.Conn{}.
При извлечении даных для запроса в `DataReader`.

7.3. Проксирование запросов с 80 порта на 4001 (запросы клиентов). Добавить в секцию `server`:

```
location /btv/live/ {
		proxy_pass http://<project_ip>:4001;
		add_header Access-Control-Allow-Origin *;
		break;
}
    
location /btv/catchup/ {
		proxy_pass http://<project_ip>:4001;
		break;
}
    
location /vod/ {
		proxy_pass http://<project_ip>:4001;
		break;
}
```

7.4. Обрезка расширений при запросах от приставок на `catchup` и `live`.
Приставки отправляют расширение для контента при `catchup` и `live` запросах.
Вида `http://cdn.beetv.kz/btv/live/hls/epg_0.m3p4`, чтобы обрезать расширение.  Добавить в секцию `server`:

```
rewrite ^/btv/live/(.*)/(.*)\.(.*)$ /btv/live/$1/$2 last;
rewrite ^/btv/catchup/(.*)/(.*)\.(.*)$ /btv/catchup/$1/$2 last;
```

7.5. Поддержка https - было решено не реализовывать в проекте https, а перенаправлять его запросы через NGINX.
Добавить отдельную секцию `server` со всеми предыдущими настройками и:

```
listen 443 ssl;
server_name server.domain.name;

ssl_certificate     /path/to/certificate/file.crt;
ssl_certificate_key /path/to/certificate/file.key;
```

8. После этого - можно деплоить. Файл будет задеплоен а папку `/home/admintv/cti_kaltura`. 
* Запуск `/home/admintv/cti_kaltura/bin/cti_kaltura start`;
* Остановка `/home/admintv/cti_kaltura/bin/cti_kaltura stop`;
* Подключиться к работающему проекту `/home/admintv/cti_kaltura/bin/cti_kaltura remote_console`;
* Запустить проект и подключиться к консоли(при выходе проект завершится) `/home/admintv/cti_kaltura/bin/cti_kaltura console`.


# Кластеризация

Чтобы запустить кластер локально, необходимо в двух разных терминалах выполнить следующие команды:

1. PORT=4000 API_PORT=4001 iex --name first@127.0.0.1 -S mix phx.server
2. PORT=4002 API_PORT=4003 iex --name second@127.0.0.1 -S mix phx.server

После этого в системе появятся два `beam` процесса, с именами `first@127.0.0.1` и `second@127.0.0.1`.
А в каждой запущенных консолей можно запустить `:observer.start()`, чтобы наблюдать за состоянием ядра.

*Важно сделать Mnesia кластерной.* В разделе "Кластеризация mnesia" описанны причины и решение проблемы.

## Реализация кластеризации

Кластеризация реализована с помошью библиотеки `libcluster`. Выполнены следующие шаги:

1. Добавлена зависимость в `mix.exs`$
2. Добавлена настройка проекта для стейдж серверов, продакшна и дев окружения. всех остальных режимов в раздел `:libcluster`;
3. Добавлен `{Cluster.Supervisor, [get_topologies(), [name: CtiKaltura.ClusterSupervisor]]}` в дерево процессов
4. Решена проблема кластеризации Mnesia.
 
## Кластеризация Mnesia  

Проблема в том, что мы используем Mnesia со схемой. После запуска проекта в кластере, необходимо удалить старую схему и создать новую.
Затем заново создать все таблицы и заполнить их данными.

Алгоритм следующий:    
1. Оба узла должны быть одновременно запущены;
2. Необходимо остановить Mnesia на обоих узлах;
3. На одном из них создать схему, в которой указать названия обоих действующих узлов;
4. Затем запустить Mnesia на обоих узлах;
5. Заново создать все таблицы DomainModel и добавить индексы;
6. Затем необходимо запустить `CtiKaltura.Services.DomainModelCache.get_all_records()`.

Аналогичный алгоритм работы для единственного кластера за исключением того, что запуск и остановка происходят на одном ядре.

Для решения этих проблем были написанны два скрипта:

1. CtiKaltura.Workers.ReleaseTasksWorker.make_mnesia_cluster_again() - для кластера (оба ядра должны быть запущены);
2. CtiKaltura.Workers.ReleaseTasksWorker.reset_single_mnesia() - для не кластерной реализации (локально мы работаем в кластере).

Они отрабатывают или выводят сообщение в консоль об ошибке. Их надо запускать из консоли запущенного проекта.

## Планирование программы передач по XML файлам скачанным с FTP

Проект осуществляет планирование программы передач с помощью данных указанных в EPG XML файлах.   
Для этого в системе есть ParseFileWorker, CreateProgramsWorker - GenServer осуществляющие парсинг файлов и
формирование программы передач на ближайшие дни с помощью данных, извлеченных из XML файлов.    
В конфигурациях необходимо указать пути до папок где лежат EPG XML файлы и куда складывать отработанные файлы.
С помощью конфигураций `cti_kaltura->epg_file_parser->files_directory` и `cti_kaltura->epg_file_parser->processed_files_directory` соответственно.     
**!** Обе папки должны существовать.

### Работа в TEST окружении

В тестовом окружении нет необходимости осуществлять парсинг EPG XML файлов поэтому эта функция отключена. 
Для отключения есть опция `cti_kaltura->epg_file_parser->enabled` если она выставлена `false`, то планирование по EPG файлам не работает.

### Работа в DEV окружении

Необходимо создать папку `/ftp_files` в корне проекта и внутри неё `/processed`     
Скачать примеры EPG файлов можно с помощью `wget -m --user=beelinetvkz --password=lQklCn8T ftp://ftp.epgservice.ru/4cti/`

### Скачивание файлов с FTP

Всё, что касается скачивания файлов с FTP и удаления отработанных необходимо реализовать с помошью средств операционной системы.
Тут необходимо реализовать 3 момента:

1. Скачивание с FTP новых файлов в папку, указанную в настройках проекта, предназначенную для обработки данных.
Скачивание можно осуществить с помощью `wget -m --user=beelinetvkz --password=lQklCn8T ftp://ftp.epgservice.ru/4cti/`

2. Папки необходимо класть в кластерную файловую систему. Например https://ru.wikipedia.org/wiki/GlusterFS
Очевидно что папки должны находиться на двух серверах в одинаковых местах.

3. Необходимо реализовать очистку или архивацию отработанных файлов.  
Запуск скрипта по крону.

## Отправка SOAP запросов

Отправка SOAP осуществляется с помошью библиотеки SOAP.     
Отправка запросов осуществуляется по схеме описанной в `WSDL` файле, который находится в папке `/cti_kaltura/priv/wsdl.xml`.     
После старта приложения запускается `DvrSoapRequestsWorker`, который загружает в память схему, описанную в файле `wsdl.xml`.    
Настройки для него оисанны в конфигурации, в разделе `:dvr_soap_requests`.     
API для отправки запросов реализовано в модуле `SoapRequests` функциями `get_*`.
Все запросы, для управления записью, требуют Basic авторизации.
Для этого необходимо добавить заголовок `Authorization`, со значением, описанным в `SoapRequests.authorization_header/2`.
Каждый запрос отправляется на DVR сервер, которому принадлежит ProgramRecord или LinearChannel. Если их несколько, то выбирается случайный.

### Обновление WSDL файла
Если в будущем `WSDL` изменится, его можно загрузить с помощью `SoapRequests.get_wsdl_file/3`.
После скачивания, запишите в XML файл.
Библиотека не читает корректно из файла, необходимо произвести некоторые манипуляции:
1. Заменить в `definitions` `xmlns:xsd="http://www.w3.org/2001/XMLSchema` на `xmlns:xs="http://www.w3.org/2001/XMLSchema`
2. Внутри каждого `complexType`, заменить `xs` на `xsd`. Например:

```
<xs:complexType name="cancelRecording">
  <xs:sequence>
    <xs:element minOccurs="0" name="arg0" type="xs:string"/>
  </xs:sequence>
</xs:complexType>
```

на

```
<xs:complexType name="cancelRecording">
  <xsd:sequence>
    <xsd:element minOccurs="0" name="arg0" type="xs:string"/>
  </xsd:sequence>
</xs:complexType>
```

## Планирование ProgramRecord

### Осуществление планирования

Планирование осуществляет `ProgramRecordsSchedulerWorker`. Конфигурации описанны в `:program_records_scheduler`.
С интервалом заданным в конфигурации с разеле `:run_interval` (по умолчанию 5 секунд) воркер делает запрос 
на Program.start_datetime, которые начинаются через `:seconds_after` у которых LinearChannel.dvr_enabled == true, нет записей программ
и есть хотя бы один TvStream.status == "ACTIVE и для каждого TvStream осуществляет планирование ProgramRecord.
Результат логируется.

*(!)* В БД в Program.start_datetime, Program.end_datetime содержится UTC+0 время, запрос на поиск соовтетственно делается так же в нулевой таймзоне. 

### Отслеживание статуса ProgramRecord

Отслеживание статуса осуществляется с помошью `ProgramRecordsStatusWorker` который периодически отправляет запрос на DVR сервер 
для всех программ, которые сейчас идут или уже закончились, но не находятся в состоянии `["COMPLETED", "ERROR"]`.
Конфигурации расположены в разделе `:program_records_status`.

*(!)* В БД в Program.start_datetime, Program.end_datetime содержится UTC+0 время, запрос на поиск соовтетственно делается так же в нулевой таймзоне. 

## Удаление устаревших Program и ProgramRecord

Удаление осуществляют `ProgramsCleanerWorker` и `ProgramRecordsCleanerWorker`.
Конфигурации расположены соответственно в `:program_records_cleaner` и `:programs_cleaner`.
Удаляются Program и ProgramRecord, время начала которых больше чем `:storing_hours` часов назад.

## Логирование

Есть необходимость разделять сообщения логов. Для разделения логов использован `:logger_file_backend`.     
Всего логи разделены на 6 доменов:   
1. `request` - обработка API запросов `catchup`, `live`, `vod`. Логируются неудачные попытки;
2. `program_scheduling` - всё что связанно с планированием программ. Созадние программ по EPG файлам, запуск записи, 
проверка статуса записи, удаление устаревших записей;
3. `release_tasks` - все действия, выполняемые в `CtiKaltura.ReleaseTasks` прогон миграций, запуск кеширования и т.д.;
4. `caching_system` - всё, что связанно с кешированием. Сообщения, которые получают `CtiKaltura.DomainModelHandlers`;
5. `sessions` - входы, выходы пользователей;
6. `database` - все действия над базой данных Create, Update, Delete для всех таблиц. Для модели User фильтруются поля password, password_hash.
