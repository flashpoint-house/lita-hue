require 'hue'
require 'css_color'
module Lita
  module Handlers
    class Hue < Handler
      HueLib = ::Hue

      config :nodejs_invocation, type: String, default: "NODE_PATH=$(npm -g root)  node" #assume its in path using gloabl modules
      config :nodejs_color_lookup, types: [TrueClass,FalseClass], default: false

      route(/^hue register$/, :register)

      route(/^hue (status|lights)$/, :list_lights)
      route(/^hue \d{1,2} [^%]+$/, :light_command)

      def light_command(res)
        light_id = res.args[0]
        command = res.args[1].to_sym
        command = :color_loop if command == :rainbow

        bulb = HueLib::Bulb.new(bridge(res), light_id)

        if bulb.respond_to?(command) && bulb.method(command).arity == 0
          bulb.send command
        else #assume its a color and try to set it
          _set_light_color(res, bulb, res.args[1])
        end
      rescue HueLib::API::Error => e
        if e.instance_variable_get(:@type) == 3
          res.reply "Error: Unkown bulb, ##{id}"
        else
          raise
        end
      end

      def _set_light_color(res, bulb, color_str)
        hex = CSSColor.parse(color_str).html

        bulb.on if bulb.off?
        bulb.color = hex_to_hsb(hex)
      rescue CSSColor::UnknownColorError
        res.reply "Error: Unkown color '#{color_str}' setting light ##{id}"
      end

      def list_lights(res)
        lights = bridge(res).lights
        lights.each do |id, light|
          reply_str = "#{id}"
          reply_str += (light["name"].empty? || light["name"] =~ /^light #{id}/i) ? ": " : " (#{light["name"]}): "
          if !light["state"]["on"]
            reply_str += "Off"
          else
            reply_str += "On: "
            bulb = HueLib::Bulb.new(@bridge, id)
            reply_str += color_to_str(bulb.color)
            reply_str += ", #{bulb.brightness_percent}%"
          end
          res.reply reply_str
        end
      end

      def register(res)
        @bridge = HueLib.application
        res.reply "Already registered (Bridge: #{@bridge.bridge_uri} AppId: #{@bridge.application_id})\nif you want to reregister remove ~/.hue-lib on the lita host"
      rescue HueLib::Error
        res.reply "Attempting registration..."
        begin
          r = HueLib.register_default
          @bridge = r #don't overwrite last on exception case.
          res.reply "registered! (Bridge: #{a.bridge_uri} AppId: #{r.application_id})"
        rescue HueLib::API::Error => e
          if e.instance_variable_get(:@type) == 101
            res.reply "Go push the button on the bridge and then run register again (within 30s)"
          else
            raise
          end
        end
      end

      Lita.register_handler(self)

      private
      def str_to_hex(str)
        CSSColor.parse(str).html
      end

      def color_to_str(color_obj)
        c = color_obj.to_rgb
        hex = ::Color::RGB.new(c.red, c.green, c.blue).html

        if config.nodejs_color_lookup
          @gem_root ||= File.expand_path "../../../..", __FILE__
          name = %x{#{config.nodejs_invocation} #{@gem_root}/color_lookup.js "#{hex}"}.chomp

          #reverse lookup for pedantry
          if str_to_hex(name) != hex
            name[/^/] = "~"
            name += " (#{hex})"
          end

          name
        else
          hex
        end
      end

      def bridge(res)
        @bridge ||= HueLib.application
      rescue HueLib::Error
        res.reply "No hue configuration! run `hue register`"
        raise
      end

      # cribbed from
      # https://github.com/Veraticus/huey/blob/78e69d0e81fcc4436aa2e84e42eb6bfcc7c82855/lib/huey/bulb.rb#L80-L119
      def hex_to_hsb(hex)
        color = Color::RGB.from_html(hex)

        # Manual calcuation is necessary here because of an error in the Color library
        r = color.r
        g = color.g
        b = color.b
        max = [r, g, b].max
        min = [r, g, b].min
        delta = max - min
        v = max * 100

        if (max != 0.0)
          s = delta / max * 100
        else
          s = 0.0
        end

        if (s == 0.0)
          h = 0.0
        else
          if (r == max)
            h = (g - b) / delta
          elsif (g == max)
            h = 2 + (b - r) / delta
          elsif (b == max)
            h = 4 + (r - g) / delta
          end

          h *= 60.0

          if (h < 0)
            h += 360.0
          end
        end

        hash = {}
        hash[:hue] = (h * 182.04).round
        hash[:sat] = (s / 100.0 * 255.0).round
        hash[:bri] = (v / 100.0 * 255.0).round
        hash
      end
    end
  end
end
