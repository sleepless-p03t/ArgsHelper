# ArgsHelper

## Overview

ArgsHelper is command line argument processing tool for the Ruby programming language.
It allows the user to easily handle command line arguments by testing if input adheres
to the specifications defined by the user.

## Installation

In a terminal:
```bash
sudo gem install argshelper --document=yri,yard
```

## Usage

```ruby
require 'argshelper'

# Define options

short_keys = [ '-a', '-b', '-c' ]
long_keys = [ '--apple', '', '--cat' ]
key_vals = [ '', 'text', 'chase' ]

# create a new helper
helper = ArgsHelper.new(ARGV)

# set valid flags, values, and/or descriptions to helper
helper.add_keys(short_keys, long_keys, key_vals)

# define specific argument value(s) for a specific flag
helper.add_static_flag_opts('-c', '--cat', [ 'chase' ])

# set a flag to not require a value
helper.set_no_value('-a', '--apple')

# parse input and handle errors
helper.parse_args

# To check if a flag is used:
puts helper.has_arg?('-c')

# get value for flag
puts helper.get_value('-c')

# Display options in a table:
# Default:
help.show_default_table

# Custom:
help.show_table("Title", 3, short_keys, long_keys, key_vals)
```

## Viewing Documentation

Documentation is written using Yard syntax

To view documentation:

```
yri ArgsHelper
yri ArgsHelper#method_name
```

