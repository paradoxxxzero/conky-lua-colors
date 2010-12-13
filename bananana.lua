--[[
   
    conky-lua-colors:  An eye candy conky lua script

    Copyright (C) 2010 Mounier Florian aka paradoxxxzero

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/.
]]--

require 'cairo'

cs, cr = nil -- initialize our cairo surface and context to nil

local banananas = {
   {
      color = "ec1a23",
      measure = "${memperc}",
      max = 100
   },
   {
      color = "f88e20",
      measure = "${cpu}",
      max = 100
   },
   {
      color = "ffe200",
      measure = "${cpu cpu0}",
      max = 100
   },
   {
      color = "b6d037",
      measure = "${cpu cpu1}",
      max = 100
   },
   {
      color = "10b147",
      measure = "${swapperc}",
      max = 100
   },
   {
      color = "01a77b",
      measure = "${fs_used_perc /}",
      max = 100
   },
   {
      color = "00a9c2",
      measure = "${fs_used_perc /home}",
      max = 100
   },
   {
      color = "0096d9",
      measure = "${time %S}",
      max = 60
   },
   { 
      color = "025dae",
      measure = "${time %M}",
      max = 60
   },
   {
      color = "482e8b",
      measure = "${time %H}",
      max = 24
   },
   {
      color = "96248c",
      measure = "${time %d}",
      max = 31
   },
   {
      color = "f2008d",
      measure = "${time %m}",
      max = 12
   }
}

function unpack_rgb(colorStr, a)
   local color = tonumber("0x"..colorStr)
   return ((color / 0x10000) % 0x100) / 255, 
          ((color / 0x100) % 0x100) / 255,
	  (color % 0x100) / 255,
	  a
end

function bananana(cr, scale, rotation, color, perc, max)
   local w = 12
   local a0, a1, af = - math.pi / 2, math.pi, math.pi * (perc / max)
   local r = 250

   cairo_save(cr)

   cairo_scale(cr, scale, scale)
   cairo_rotate(cr, rotation)

   cairo_save(cr)
   local pattern_back = cairo_pattern_create_radial (0, 0, r - w, 0, 0, r)
   cairo_pattern_add_color_stop_rgba (pattern_back, 0, unpack_rgb(color, .6))
   cairo_pattern_add_color_stop_rgba (pattern_back, 1, unpack_rgb(color, .4))
   cairo_set_source(cr, pattern_back)
   cairo_arc(cr, 0, 0, r, a0, a1)
   cairo_arc_negative(cr, - w, -w, r - w, a1, a0)
   cairo_fill(cr)
   cairo_restore(cr)
   cairo_save(cr)

   local pattern = cairo_pattern_create_radial (0, 0, r - w, 0, 0, r)
   cairo_pattern_add_color_stop_rgba (pattern, 0, unpack_rgb(color, .9))
   cairo_pattern_add_color_stop_rgba (pattern, 1, unpack_rgb(color, .4))
   cairo_set_source(cr, pattern)
   cairo_arc(cr, 0, 0, r, a0, af)
   cairo_arc_negative(cr, - w, -w, r - w, af, a0)
   cairo_fill(cr)
   cairo_restore(cr)

   cairo_restore(cr)
end

local angle0 = 0
function conky_bananana()
   if conky_window == nil then return end
   if cs == nil or cairo_xlib_surface_get_width(cs) ~= conky_window.width or cairo_xlib_surface_get_height(cs) ~= conky_window.height then
      if cs then cairo_surface_destroy(cs) end
      cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
   end
   if cr then cairo_destroy(cr) end
   cr = cairo_create(cs)
   local w, h = conky_window.width, conky_window.height
   local pi = math.pi
   cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE)
   cairo_translate(cr, w/2, h/2) -- centering
--   angle0 = angle0 + 0.02
   local angle = angle0
   local scale = 1.2
   for i,banana in pairs(banananas) do
      bananana(cr, scale, angle, banana.color, conky_parse(banana.measure), banana.max)
      angle = angle + pi/6
      scale = scale + (1 -  scale) * 0.09 - 0.095
   end

  -- cairo_move_to(cr, 310, 285)
  -- cairo_select_font_face(cr, "monofur", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
  -- cairo_set_font_size(cr, 48)
  -- cairo_show_text(cr, "CPU: "..cpu)
  
   cairo_destroy(cr)
   cr = nil
end