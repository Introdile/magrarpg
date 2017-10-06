tool
extends Control

const MODE_STRETCH = 0
const MODE_TILE = 1

export(Texture) var texture = null setget set_texture
export var draw_center = true setget set_draw_center
export(int, "Stretch", "Tile") var slice_mode = MODE_STRETCH setget set_slice_mode
export var left_slice = 0 setget set_left_slice
export var right_slice = 0 setget set_right_slice
export var top_slice = 0 setget set_top_slice
export var bottom_slice = 0 setget set_bottom_slice


func _ready():
    pass


func set_texture(tex):
    texture = tex
    update()


func set_slice_mode(m):
    slice_mode = m
    update()


func set_draw_center(dc):
    draw_center = dc
    update()


func set_left_slice(m):
    if m < 0:
        m = 0
    left_slice = m
    update()

func set_right_slice(m):
    if m < 0:
        m = 0
    right_slice = m
    update()

func set_top_slice(m):
    if m < 0:
        m = 0
    top_slice = m
    update()

func set_bottom_slice(m):
    if m < 0:
        m = 0
    bottom_slice = m
    update()


func _draw():
    if texture == null:
        return

    var r = get_rect()
    var ts = texture.get_size()
    var rs = r.size
    var ks = rs / ts

    var dst_left = left_slice# * ks.x
    var dst_right = right_slice# * ks.x
    var dst_top = top_slice# * ks.y
    var dst_bottom = bottom_slice# * ks.y

    if top_slice > 0:
        if left_slice > 0:
            # Top-left corner
            draw_texture_rect_region(texture, \
                Rect2(0, 0, dst_left, dst_top), \
                Rect2(0, 0, left_slice, top_slice))
        if right_slice > 0:
            # Top-right corner
            draw_texture_rect_region(texture, \
                Rect2(rs.x - dst_right, 0, dst_right, dst_top), \
                Rect2(ts.x - right_slice, 0, right_slice, top_slice))
        # Top side
        draw_texture_rect_region_mode(texture, \
            Rect2(dst_left,    0,  rs.x - dst_left - dst_right,    dst_top), \
            Rect2(left_slice,  0,  ts.x - left_slice - right_slice,  top_slice))

    if bottom_slice > 0:
        if left_slice > 0:
            # Bottom-left corner
            draw_texture_rect_region(texture, \
                Rect2(0,  rs.y - dst_bottom,    dst_left, dst_bottom), \
                Rect2(0,  ts.y - bottom_slice,  left_slice, bottom_slice))
        if right_slice > 0:
            # Bottom-right corner
            draw_texture_rect_region(texture, \
                Rect2(rs.x - dst_right,    rs.y - dst_bottom,    dst_right, dst_bottom), \
                Rect2(ts.x - right_slice,  ts.y - bottom_slice,  right_slice, bottom_slice))
        # Bottom side
        draw_texture_rect_region_mode(texture, \
            Rect2(dst_left,    rs.y - dst_bottom,    rs.x - dst_left - dst_right,      dst_bottom), \
            Rect2(left_slice,  ts.y - bottom_slice,  ts.x - left_slice - right_slice,  bottom_slice))

    if left_slice > 0:
        # Left side
        draw_texture_rect_region_mode(texture, \
            Rect2(0,  dst_top,    dst_left,    rs.y - dst_top - dst_bottom), \
            Rect2(0,  top_slice,  left_slice,  ts.y - top_slice - bottom_slice))
    if right_slice > 0:
        # Right side
        draw_texture_rect_region_mode(texture, \
            Rect2(rs.x - dst_right,    dst_top,    dst_right,    rs.y - dst_top - dst_bottom), \
            Rect2(ts.x - right_slice,  top_slice,  right_slice,  ts.y - top_slice - bottom_slice))


    if draw_center:
        # Center
        draw_texture_rect_region_mode(texture, \
            Rect2(dst_left,    dst_top,    rs.x - dst_right - dst_left,      rs.y - dst_top - dst_bottom), \
            Rect2(left_slice,  top_slice,  ts.x - right_slice - left_slice,  ts.y - top_slice - bottom_slice))


func draw_texture_rect_region_mode(tex, dst_rect, src_rect):
    if slice_mode == MODE_STRETCH:
        draw_texture_rect_region(tex, dst_rect, src_rect)
    else:
        draw_texture_rect_region_tiled(tex, dst_rect, src_rect)


func draw_texture_rect_region_tiled(tex, dst_rect, src_rect):
    var pos = Vector2(0,0)
    var dst_pos = dst_rect.pos
    var src_size = src_rect.size

    while pos.y + src_size.y < dst_rect.size.y:
        while pos.x + src_size.x < dst_rect.size.x:
            draw_texture_rect_region(tex, Rect2(dst_pos + pos, src_size), src_rect)
            pos.x += src_size.x
        pos.x = 0
        pos.y += src_size.y

    var cropped_src_rect = Rect2( \
        src_rect.pos.x, \
        src_rect.pos.y, \
        src_rect.size.x, \
        dst_rect.size.y - pos.y)

    while pos.x + src_size.x < dst_rect.size.x:
        draw_texture_rect_region(tex, Rect2(dst_pos + pos, cropped_src_rect.size), cropped_src_rect)
        pos.x += src_size.x

    pos.y = 0

    var cropped_src_rect = Rect2(
        src_rect.pos.x, \
        src_rect.pos.y, \
        dst_rect.size.x - pos.x, \
        src_rect.size.y)

    while pos.y + src_size.y < dst_rect.size.y:
        draw_texture_rect_region(tex, Rect2(dst_pos + pos, cropped_src_rect.size), cropped_src_rect)
        pos.y += src_size.y

    var cropped_src_rect = Rect2(
        src_rect.pos.x, \
        src_rect.pos.y, \
        dst_rect.size.x - pos.x, \
        dst_rect.size.y - pos.y)

    draw_texture_rect_region(tex, Rect2(dst_pos + pos, cropped_src_rect.size), cropped_src_rect)