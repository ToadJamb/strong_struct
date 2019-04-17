[![Build Status](https://travis-ci.org/ToadJamb/strong_struct.svg?branch=master)](https://travis-ci.org/ToadJamb/strong_struct)

StrongStruct
============

Strong attributes for dynamic structures.

Strong attributes exists because OpenStruct does not enforce attributes
and Struct does not allow you to pass in a hash.

There are some fairly impressive gains to be made by doing this,
particularly when testing ActiveRecord models.
Keep reading...


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
my_struct = StrongStruct.new(:id, 'name', :ssn)
object = my_struct.new('id' => 3, :name => 'John Doe')

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

You can also get back the current attributes in a hash.

Please note that all keys are converted to strings.

This can be useful to pass to a real ActiveRecord object
to ensure the attributes match up
(this should only be done once in your test suite - more later).

```
my_struct = StrongStruct.new(:id, :name, :ssn)
object = my_struct.new(:id => 3, :name => 'John Doe')
object.attributes #=> {'id' => 3, 'name' => 'John Doe', 'ssn' => nil }
```

Naming
------

There are two ways to get `to_s`, `inspect` and friends
to give you meaningful information
(instead of `#<#Class0x00000>:0x00000>` or the like).

The first is by simply setting the result of `StrongStruct.new` to a constant:
`Foo = StrongStruct.new(:name)`

The second is dynamically by specifying a string
that starts with a capital letter as the first parameter:
`StrongStruct.new('Foo', :fizz, :buzz)`

*Please note*: This will create a new `Foo` constant!

`StrongStruct` raises an error (`StrongStruct::Errors::ClassInUseError`)
if you attempt to call `new` twice with the same constant string.

If you REALLY need to do this, it is recommended that you create these
constants yourself and use `StrongStruct` classes without
specifying a constant name.
You can also call `const_set` yourself:
`const_set 'MyConstant', StrongStruct.new(:name)`


Testing ActiveRecord Models
---------------------------

You can use StrongStruct to test ActiveRecord models
in a way that keeps you 100% away from the database
(in a way FactoryGirl and RSpec mocks cannot)
while still calling through to real methods
that execute that logic you need to test.


### Getting Started

We will place all of our logic in PersonInstanceMethods
and/or PersonClassMethods.

```
# models/person.rb
class Person < ActiveRecord::Base
  # with db fields including :first_name, :last_name, :phone
  include PersonInstanceMethods
  extend PersonClassMethods
end

module PersonInstanceMethods
  def full_name
    "#{first_name} #{last_name}"
  end
end

module PersonClassMethods
end
```

```
require 'spec_helper' # This should NOT do any db setup/teardown.

RSpec.describe PersonInstanceMethods do
  subject { klass.new :first_name => 'Luke', :last_name => 'Skywalker' }

  let(:klass) do
    base = StrongStruct.new(:first_name, :last_name)
    Class.new(base) do
      include PersonInstanceMethods
      extend PersonClassMethods
    end
  end

  describe '.full_name' do
    it 'concatenates first and last name' do
      expect(subject.full_name).to eq 'Luke Skywalker'
    end
  end
end
```

This model allows us to skip the database
while ensuring all of our logic plays nicely together.

We are intentionally including all methods in the 'mocked' object
so that we make sure nothing behaves strangely by doing so.


### Even Better

What we did above is fine for one-off cases
where we want to make sure that we don't use attributes unintentionally.
For instance, if `full_name` had called `phone`, we would see an error.

Most of the time, you will probably want something closer to this:

```
# spec/support/helpers/person_helper.rb
module MyProjectSpecHelpers
  module PersonHelper
    def person_class
      base = StrongStruct.new(
        :first_name,
        :last_name,
        :phone
      )
      Class.new(base) do
        include PersonInstanceMethods
        extend PersonClassMethods
      end
    end
  end
end

RSpec.include do |config|
  config.include MyProjectSpecHelpers::PersonHelper
end

```

We can then make sure that our interface matches the real model
in ONE very easy, lightweight test:

```
# spec/models/person_spec.rb
require 'rails_helper' # or whatever loads your db for specs

RSpec.describe Person do
  context 'attributes' do
    it 'match mocked attributes' do
      mock = person_class.new

      # This line will raise an error if :phone has changed to :phone_number
      person = Person.new(mock.attributes)

      # Unlikely that this will fail if the previous line is successful,
      # but the expectation is here for completeness.
      mock.attributes.each do |attr|
        expect(person).to respond_to attr
      end
    end
  end
end
```


### Additional Thoughts on Complex Domains

This works great for simple domains
and model relationships that are only a step or two away.
It can definitely get hairy if you attempt to use this to
model complex relationships.
It is probably better to look for ways to reduce the code surrounding
those points, so that the logic behind (i.e. beneath) them
may be tested using methods like the ones outlined here.


### FactoryGirl

If you want to use FactoryGirl to create some of these for you,
simply use `attributes_for`:

```
person_struct = person_class.new(FactoryGirl.attributes_for(:person))
```

`FactoryGirl.attributes_for` does not touch the database.
You can drop your database, turn off the database server,
or whatever else you want to do and it will stil work.

Associations will be left out of the attribute list.


Gemfile.lock
------------

Common advice is to not check in the Gemfile.lock for libraries.

This is a terrible practice.

If you attempt to use a gem that has no Gemfile.lock
committed, then you have no idea what combination
of dependencies has a reasonable expectation of working.
If you are a maintainer of said gem,
you will have a local Gemfile.lock that likely works.
And you are probably not deleting it EVERY time you
work on the gem.
We all know that we SHOULD delete the Gemfile.lock on occasion
and some of us maybe even do it.
But more of us run an occasional `bundle update`
and keep on trucking.

The point is that on an actively-maintained gem,
not checking the Gemfile.lock in only makes it harder
to get started helping, not easier.
I will gladly remove my Gemfile.lock once I have a passing suite
with known 'supported' dependencies.
At that point, I may get errors from udpated dependencies
that would be a good starting point for contributions.
Or I may just continue pursuing the pull request to fix/update/add a feature
that caused me to care about a Gemfile.lock for the project in the first place.
Either way, the project is better for it.

There are far more out-of-date/unmaintained gems than there are
up-to-date/active gems.
Many of the out-of-date gems are actually useful.
And many of them have dependencies that don't work when updated.
It is much harder to get something working if you have no idea
what a good starting point is
or even whether it was expected to work at some point
(maybe the test suite was failing when it was abandoned).
The point is that it very difficult to know the difference
without a Gemfile.lock.

This is one of the dumbest things we do.
The practice of not checking in a Gemfile.lock for libraries is ridiculous
and we should start checking them in.
