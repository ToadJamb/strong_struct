StrongStruct
============

Strong attributes for dynamic structures.

Strong attributes exists because OpenStruct does not enforce attributes
and Struct does not allow you to pass in a hash.


Installation
------------

    $ gem install strong_struct


Gemfile
-------

    $ gem 'strong_struct'


Require
-------

    $ require 'strong_struct'


Usage
-----

```
my_struct = StrongStruct.new(:id, :name, :ssn)
object = my_struct.new(:id => 3, :name => 'John Doe')

object.id   #=> 3
object.name #=> 'John Doe'
object.ssn  #=> nil

object.ssn = '111-22-3333'
object.ssn #=> '111-22-3333'
```

The following examples are ways that `StrongStruct`
lets you know you did something unexpected.

It is worth noting that OpenStruct
does not raise an error in similar cases.

```
# Sending a hash with keys that were not defined.
my_struct = StrongStruct.new(:id, :name, :ssn)
object = my_struct.new(:id => 3, :phone => '111-222-3333') #=> Error
```

```
# Setting an attribute that was not defined.
my_struct = StrongStruct.new(:id, :name, :ssn)
object.phone = '111-222-3333' #=> Error
```
