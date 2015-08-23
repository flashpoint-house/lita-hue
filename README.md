# lita-hue

Lita plugin for controlling Phillips Hue lights.

While some proxy trickery might be possible, this is  designed for when
lita is running on a computer that can talk directly to the Hue Bridge

Currently it can control individual lights one at a time and report global status

## Installation

Add lita-hue to your Lita instance's Gemfile:

``` ruby
gem "lita-hue"
```

If you want to use the name that color functionality, also be sure to have
nodejs installed and the closest-color-keyword module installed

```bash
brew install nodejs #or apt-get or yum
sudo npm install -g closest-color-keyword
```

## Configuration

The `register` command should good for getting set up, but if you can talk
to the bridge but not discover it (e.g. if lita is in a VM where uPNP traffic
is filtered), you can also run `ruby -rhue -e "puts Hue.register_default"` on a
different computer on the network with the `hue-lib` gem installed and copy
the contents of `~/.hue-lib` to the appropriate place

Due to the dependence on node, the name that color feature is disabled by default.
If you want it on, add the first of the following lines to your `lita_config.rb`
and a modification on second as applicable (the shown value is the default)

```ruby
config.handlers.hue.nodejs_color_lookup = true
#assume we want to use Global node_modules only and that node is called `node`
#and in the path of the lita process
config.handlers.hue.nodejs_invocation = "NODE_PATH=$(npm -g root) node"
```

## Usage
e.g.

* `hue register` - register lita with your hue bridge
* `hue status` - list known bulbs and their states
* `hue 1 off` - turn off bulb with id 1 (ids are same as other apps, but can be seen in `status`)
* `hue 2 red`, `hue 3 aquamarine`, `hue 4 #ffa` - set bulbs to various CSS colors. Its not exact but its close
* `hue 3 blink`, `hue 1 on`, `hue 4 rainbow` - etc.
