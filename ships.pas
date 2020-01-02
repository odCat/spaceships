{
 Space Ships - Video game in which two spaceships battle

 Copyright (C) 2019, 2020 Mihai Gătejescu (gus666xe@gmail.com)

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
}

program ships;
uses crt, graph;
type
    tripoints = array [0.. 2] of pointtype;
const
    step = 10;
    ship_width = 110;
    shuttle_height = 120;
    ufo_height = 63;
var
    grdriver, grmode: integer;
    temp: tripoints;
    shuttle_x, shuttle_y, ufo_x, ufo_y: integer;
    dimension: word;
    shuttle, ufo: pointer;
    key_code: char;

procedure draw_shuttle(x, y: integer);
begin
    { tip }
    temp[0].x:= x + 40;
    temp[0].y:= y + 30;
    temp[1].x:= x + 55;
    temp[1].y:= y;
    temp[2].x:= x + 70;
    temp[2].y:= y + 30;
    drawpoly(3, temp);

    temp[1].y:= y + 10;
    drawpoly(3, temp);
    temp[1].y:= y + 17;
    drawpoly(3, temp);

    { left wing }
    temp[0].x:= x;
    temp[0].y:= y + 110;
    temp[1].x:= x + 40;
    temp[1].y:= y + 75;
    temp[2].x:= x + 40; { why donesn't print this vertex }
    temp[2].y:= y + 110;
    drawpoly(3, temp);

    rectangle(x, y + 110, x + 40, y + 120);

    { right wing }
    temp[0].x:= x + 70;
    temp[0].y:= y + 75;
    temp[1].x:= x + 110;
    temp[1].y:= y + 110;
    temp[2].x:= x + 70;
    temp[2].y:= y + 110;
    drawpoly(3, temp);

    rectangle(x + 70, y + 110, x + 110, y + 120);

    { body }
    rectangle(x + 40, y + 30, x + 70, y + 120);

    temp[0].x:= x + 40;
    temp[0].y:= y + 30;
    temp[1].x:= x + 35;
    temp[1].y:= y + 120;
    temp[2].x:= x + 40;
    temp[2].y:= y + 120;
    drawpoly(3, temp);
    
    temp[0].x:= x + 70;
    temp[0].y:= y + 30;
    temp[1].x:= x + 75;
    temp[1].y:= y + 120;
    temp[2].x:= x + 70;
    temp[2].y:= y + 120;
    drawpoly(3, temp);

    { tail }
    line(x + 55, y + 75, x + 55, y + 120);
end;

procedure draw_ufo1(x,y: integer);
begin
    ellipse(x + 55, y + 90, 0, 180, 55, 20);
    ellipse(x + 55, y + 90, 0, 180, 53, 18);
    ellipse(x + 55, y + 80, 0, 180, 32, 32);
    ellipse(x + 55, y + 80, 180, 185, 32, 32);
    ellipse(x + 55, y + 80, 355, 360, 32, 32);
    setcolor(black); setfillstyle(1, black);
    fillellipse(x + 55, y + 80, 31, 31);
    setcolor(white);
    ellipse(x + 55, y + 90, 180, 360, 55, 20);
    ellipse(x + 55, y + 90, 180, 360, 53, 18);
    ellipse(x + 57, y + 88, 0, 360, 6, 6);
    ellipse(x + 73, y + 86, 0, 360, 5, 5);
    ellipse(x + 38, y + 85, 0, 360, 5, 5);
    ellipse(x + 55, y + 30, 251, 289, 55, 24);
end;

procedure draw_ufo2(x, y: integer);
begin
    ellipse(x + 55, y + 27, 0, 180, 27, 27);
    rectangle(x + 28, y + 27, x + 83, y + 32);
    line(x, y + 47, x + 28, y + 32);
    line(x, y + 47, x + 110, y + 47);
    line(x + 83, y + 32, x + 110, y + 47);
    line(x, y + 47, x + 28, y + 62);
    line(x + 28, y + 62, x + 83, y + 62);
    line(x + 83, y + 62, x + 110, y + 47);
end;

procedure move_shuttle(var x: integer; y, step: integer;
                       shuttle:pointer);
begin
    if ((step > 0) and (x + step + ship_width <= getmaxx)) or
       ((step < 0) and (x + step >= 0)) then
    begin
        putimage(x, y, shuttle^, xorput);
        x:= x + step;
        putimage(x, y, shuttle^, xorput);
    end;
end;

{ which_ship: 0 - shuttle, 1 - ufo }
procedure explode(x, y, which_ship: integer);
var
    height: integer;
begin
    if which_ship = 0 then
    begin
        height:= shuttle_height;
    end
    else begin
        height:= ufo_height;
    end;

    bar(x, y, x + ship_width, y + height);
    delay(100);
    setfillstyle(1, black);
    bar(x, y, x + ship_width, y + height);
    setfillstyle(1, white);
end;

procedure shuttle_fire(shuttle_x, shuttle_y, ufo_x, ufo_y: integer);
var
    dimension: word;
    projectile: pointer;
begin
    setcolor(lightred);
    line(shuttle_x + 55, shuttle_y - 1, shuttle_x + 55, shuttle_y - 11);
    dimension:= imagesize(shuttle_x + 55, shuttle_y - 1,
                          shuttle_x + 55, shuttle_y - 11);
    getmem(projectile, dimension);
    getimage(shuttle_x + 55, shuttle_y - 1, shuttle_x + 55, shuttle_y - 11,
             projectile^);

    while shuttle_y > 0 do
    begin
        putimage(shuttle_x + 55, shuttle_y - 11, projectile^, xorput);
        shuttle_y:= shuttle_y - 10;
        putimage(shuttle_x + 55, shuttle_y - 11, projectile^, xorput);
        delay(100);
        
        { hit }
        if (shuttle_y < ufo_height) and
           (shuttle_x > ufo_x - 55) and
           (shuttle_x < ufo_x - 55 + ship_width) then
        begin
            explode(ufo_x, ufo_y, 1);
            break;
        end;
    end;
    setcolor(white);
end;

procedure ufo_fire(ufo_x, ufo_y, shuttle_x, shuttle_y: integer);
var
    dimension: word;
    projectile: pointer;
begin
    setcolor(yellow);
    line(ufo_x + 55, ufo_y + 63, ufo_x + 55, ufo_y + 73);
    dimension:= imagesize(ufo_x + 55, ufo_y + 63, ufo_x + 55, ufo_y + 73);
    getmem(projectile, dimension);
    getimage(ufo_x + 55, ufo_y + 63, ufo_x + 55, ufo_y + 73, projectile^);

    while ufo_y < getmaxy - 10 do
    begin
        putimage(ufo_x + 55, ufo_y + 63, projectile^, xorput);
        ufo_y:= ufo_y + 10;
        putimage(ufo_x + 55, ufo_y + 63, projectile^, xorput);
        delay(100);

        { hit }
        if (ufo_y > getmaxy - shuttle_height) and
           (ufo_x > shuttle_x - 55) and
           (ufo_x < shuttle_x - 55 + ship_width) then
        begin
            explode(shuttle_x, shuttle_y, 0);
            break;
        end;
    end;
    setcolor(white);
end;

procedure reset_ships(var shuttle_x, ufo_x: integer;
        shuttle_y, ufo_y: integer; shuttle, ufo: pointer);
begin
    setfillstyle(1, black);
    bar(shuttle_x, shuttle_y, shuttle_x + ship_width,
        shuttle_y + shuttle_height);
    shuttle_x:= 1;
    shuttle_y:= getmaxy - shuttle_height;
    putimage(shuttle_x, shuttle_y, shuttle^, xorput);

    bar(ufo_x, ufo_y, ufo_x + ship_width, ufo_y + ufo_height);
    ufo_x:= getmaxx - ship_width;
    ufo_y:= 1;
    putimage(ufo_x, ufo_y, ufo^, xorput);
    setfillstyle(1, white);
end;

begin
    grdriver:= detect;
    initgraph(grdriver, grmode, 'C:\BP\BGI');

    shuttle_x:= 1;
    shuttle_y:= getmaxy - shuttle_height;
    draw_shuttle(shuttle_x, shuttle_y);
    dimension:= imagesize(shuttle_x, shuttle_y,
                          shuttle_x + ship_width, shuttle_y + shuttle_height);
    getmem(shuttle, dimension);
    getimage(shuttle_x, shuttle_y, shuttle_x + ship_width,
             shuttle_y + shuttle_height, shuttle^);

    ufo_x:= getmaxx - ship_width;
    ufo_y:= 1;
    draw_ufo2(ufo_x, ufo_y);
    getmem(ufo, dimension);
    getimage(ufo_x, ufo_y, ufo_x + ship_width,
             ufo_y + ufo_height, ufo^);

    repeat
        key_code:= readkey;
        case key_code of
            #0: begin
                key_code:= readkey;
                case key_code of
                    #72: begin { UP ARROW }
                        shuttle_fire(shuttle_x, shuttle_y, ufo_x, ufo_y);
                    end;
                    #75: begin { LEFT ARROW }
                        move_shuttle(shuttle_x, shuttle_y, -step, shuttle);
                    end;
                    #77: begin { RIGHT ARROW }
                        move_shuttle(shuttle_x, shuttle_y, step, shuttle);
                    end;
                end;
            end;
            #32: begin { SPACE }
                reset_ships(shuttle_x, ufo_x, shuttle_y, ufo_y,
                            shuttle, ufo);
            end;
            #49: begin { 1 }
                explode(shuttle_x, shuttle_y, 0);
                explode(ufo_x, ufo_y, 1);
            end;
            #97: begin { A }
                move_shuttle(ufo_x, ufo_y, -step, ufo);
            end;
            #100: begin { D }
                move_shuttle(ufo_x, ufo_y, step, ufo);
            end;
            #115, #119: begin
                ufo_fire(ufo_x, ufo_y, shuttle_x, shuttle_y);
            end;
        end;
    until key_code = #27; { ESCAPE }

    closegraph;
end.
