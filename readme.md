# Создание загрузочного образа с интегрированным файлом kickstart для автоматической установки:
### 1 - Скачиваем iso образ
[OracleLinux](https://yum.oracle.com/oracle-linux-isos.html)

### 2 - Редактируем файлы grub.cfg, isolinux.cfg и ks.cfg:
По умолчанию в `RHEL`-подобных дистрибутивах/деривативах:  
- За загрузку в режиме `UEFI` отвечает файл `iso:/EFI/BOOT/grub.cfg`  
  
- За загрузку в режиме `BIOS` отвечает файл `iso:/isolinux/isolinux.cfg`
  
По умолчанию выставлены следующие настройки:  
- Загрузочный пункт по умолчанию выполняет проверку контрольной суммы диска  
- Имеет таймаут перед запуском 60 секунд  
- Не задан метод поиска файла `ks.cfg`  

##### 2.1 Изменение загрузочного пункта по умолчанию:
- `grub.cfg` - задаем номер пункта загрузки с помощью `set default="0"`  
где `0` - номер пункта загрузки  
  
- `isolinux.cfg` - в нужном пункте меню загрузки должен присутствовать пункт `menu default`

##### 2.2 Изменение времени таймаута перед запуском пункта загрузки:
- `grub.cfg` - Устанавливаем параметр `set timeout=` в необходимое значение  
например `5` - что равно 5 секундам  
  
- `isolinux.cfg` - Устанавливаем параметр `timeout` в необходимое значение  
например `50` - что равно 5 секундам  

##### 2.3 Создаем файл ks.cfg:
[Kickstart - документация](https://pykickstart.readthedocs.io/en/latest/kickstart-docs.html)

Рекомендуется:
- Установить операционную систему с необходимыми настройками в ручном режиме   
- Взять за основу файл `/root/anaconda-ks.cfg` из установленной системы.

##### 2.4 Настраиваем пункт загрузки на использование файла ks.cfg:
Предлагается использовать два способа передачи файла ks.cfg:
- Интеграция файла `ks.cfg` внутрь iso образа  
добавляем в пункт загрузки следующий kernel параметр:
```
inst.ks=cdrom:/ks.cfg
```
- Поиск файла `ks.cfg` на http сервере  
добавляем в пункт загрузки следующий kernel параметр:
```
inst.ks=http://ip:port/ks.cfg
```
Примечания:

- Данный способ очень удобно использовать для разработки.  
- В данном случае нам всё еще нужен файл `ks.cfg` для сборки iso образа, но не важно его содержимое.  
- Простейший способ организации веб сервера - запуск python3 http.server модуля в каталоге с файлом `ks.cfg`  

```
python3 -m http.server
```

### 3 - Узнаем label скачанного образа:
- Выполняем команду
```
file OracleLinux-R9-U4-x86_64-dvd.iso
```
- Пример вывода
```
OracleLinux-R9-U4-x86_64-dvd.iso: ISO 9660 CD-ROM filesystem data (DOS/MBR boot sector) 'OL-9-4-0-BaseOS-x86_64' (bootable)
```
Где `'OL-9-4-0-BaseOS-x86_64'` является `label` iso образа.
### 4 - Задаем переменные окружения:
```
DOCKER_IMAGE='create_bootable_iso_with_kickstart'
DOCKER_TAG='1.0.0'
ISO_LABEL='OL-9-4-0-BaseOS-x86_64'
INPUT_ISO_FILENAME='OracleLinux-R9-U4-x86_64-dvd.iso'
OUTPUT_ISO_FILENAME='OracleLinux-R9-U4-x86_64-dvd_kickstart.iso'
```
### 5 - Собираем докер образ:
Данную команду необходимо выполнить в каталоге проекта.  
```
docker build \
--tag "${DOCKER_IMAGE}:${DOCKER_TAG}" \
.
```
### 6 - Выполняем запуск докер контейнера:

В текущем каталоге должны присутствовать файлы:
- `grub.cfg`
- `isolinux.cfg`
- `ks.cfg`
- А также ISO образ с именем заданным в переменной окружения - `${INPUT_ISO_FILENAME}`

```
docker run \
--interactive \
--tty \
--rm \
--volume "${PWD}:/workdir" \
--env "ISO_LABEL=${ISO_LABEL}" \
--env "INPUT_ISO_FILENAME=${INPUT_ISO_FILENAME}" \
--env "OUTPUT_ISO_FILENAME=${OUTPUT_ISO_FILENAME}" \
"${DOCKER_IMAGE}:${DOCKER_TAG}"
```
  
Результатом выполнения будет файл `${OUTPUT_ISO_FILENAME}`.