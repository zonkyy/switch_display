#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'shell'

class SwitchDisplay
  def initialize
    Shell.def_system_command("xprop")
    Shell.def_system_command("xwininfo")
    Shell.def_system_command("wmctrl")
    @sh = Shell.new
    @root_window_width = window_width("-root")
    @root_window_height = window_height("-root")
  end

  def active_window_origin(origin, *xwininfo_arg)
    @sh.xwininfo(*xwininfo_arg).grep(/Absolute upper-left #{origin.upcase}:/)[0].strip.split[3].to_i
  end

  def window_x(*xwininfo_arg)
    active_window_origin("x", *xwininfo_arg)
  end

  def window_y(*xwininfo_arg)
    active_window_origin("y", *xwininfo_arg)
  end

  def window_width(*xwininfo_arg)
    @sh.xwininfo(*xwininfo_arg).grep(/Width:/)[0].strip.split[1].to_i
  end

  def window_height(*xwininfo_arg)
    @sh.xwininfo(*xwininfo_arg).grep(/Height:/)[0].strip.split[1].to_i
  end

  def move_window(id, *to)
    @sh.wmctrl("-i", "-r", id, "-e", to.join(','))
  end

  def switch_left_to_right(id, window_x)
    to = [0, window_x + @root_window_width/2, -1, -1, -1]
    p to
    move_window(id, *to)
  end

  def switch_right_to_left(id, window_x)
    to = [0, window_x - @root_window_width/2, -1, -1, -1]
    p to
    move_window(id, *to)
  end

  def active_window_id
    @sh.xprop("-root").grep(/^_NET_ACTIVE_WINDOW/)[0].strip.split[4]
  end

  def switch(id)
    active_window_width = window_width("-id", id)
    active_window_height = window_height("-id", id)
    active_window_x = window_x("-id", id)
    active_window_y = window_y("-id", id)

    if active_window_x + active_window_width < @root_window_width/2
      switch_left_to_right(id, active_window_x)
    elsif active_window_x > @root_window_width/2
      switch_right_to_left(id, active_window_x)
    end
  end
end


if __FILE__ == $0
  switch_disp = SwitchDisplay.new
  id = switch_disp.active_window_id
  switch_disp.switch(id)
end
