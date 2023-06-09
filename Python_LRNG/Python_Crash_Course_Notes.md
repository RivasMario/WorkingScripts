# Pre steps

```bash

Python should come pre-installed

add default dev packages

>sudo apt install python3-dev python3-pip python3-venv

Installing a package called deadsnakes, easy to install multiple versions of python

>sudo add-apt-repository ppa:deadsnakes/ppa
>sudo apt update
>sudo apt install python3.11

Enter the following command to start a terminal session that runs
Python 3.11:

$ python3.11
>>>
 PYTHON 3.11 is default throughout book

>sudo apt install python3.11-dev python3.11-venv

Be mindful of version throughout

python --version
python -V

||PYTHON keywords and Built in Function

Keywords
-----------
False   await else import pass
None    break except in raise
True    class finally is return
and     continue for lambda try
as      def from nonlocal while
assert  del global not with
async   elif if or yield

Built-In Functions
----------

abs() hash() slice()
aiter() help() sorted()
all() hex() staticmethod()
any() id() str()
anext() input() sum()
ascii() int() super()
bin() isinstance() tuple()
bool() issubclass() type()
breakpoint() iter() vars()
bytearray() len() zip()
bytes() list() __import__()
callable() locals()
chr() map()
classmethod() max()
compile() memoryview()
complex() min()
delattr() next()
dict() object()
dir() oct()
divmod() open()
enumerate() ord()
eval() pow()
exec() print()
filter() property()
float() range()
format() repr()
frozenset() reversed()
getattr() round()
globals() set()
hasattr() setattr()

\\GIT

File extensions .pyc are auto-gened from .py files. typically stored in directory called __pycache__/ make gitignore file with file ext in it


.gitignore

__pycache__/

#! /bin/python3.11

git init: a new directory for py training
git status: check 
git add .
git commit -m "Started project"
git log
git log --pretty=oneline: provides ref id and commit message

git restore .: get last working version
git restore filename: abandon all changes since last commit to specific file
git checkout cea13d
git swtich -c <new branch line>
git reset --hard cea13d

\\Linux deployment

curl -fsS https://platform.sh/cli/installer | php

sudo apt install curl php-cli
```  

## Chapter 1 Getting Started

```bash

python3 hello_world.py

python3
>>>

CTRL-D or exit() to close interpreter


```

## Chapter 2 Variables and Simple Data Types

```bash




```