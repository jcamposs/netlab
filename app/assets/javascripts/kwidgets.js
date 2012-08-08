/**
 *
 *  Copyright (C) 2012 GSyC/LibreSoft, Universidad Rey Juan Carlos.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 */

/**
 * Kinetic widgets module
 */
var KWidgets = (function () {

  var module = {};

  function merge(conf1, conf2) {
    var attrs = conf1 || {};

    for(var key in conf2) {
      attrs[key] = conf2[key];
    }

    return attrs;
  };

  //////////////////////////////////////////////////////////////////////////////
  // Widget Object
  //////////////////////////////////////////////////////////////////////////////
  Widget = function(config) {
    var that = {};
    that.attrs = merge({
      x: 0,
      y: 0
    }, config);

    var group = new Kinetic.Group();

    that.getNode = function() {
      return group;
    }

    return that;
  };

  //////////////////////////////////////////////////////////////////////////////
  // Canvas Browser
  //////////////////////////////////////////////////////////////////////////////
  module.Browser = function(config) {
    var that = Widget(merge({
      width: 14,
      height: 100,
      sections: 8,
      arrow_width: 2,
      slide_hight: 10
    }, config));

    var group = that.getNode();
    group.setX(that.attrs.x);
    group.setY(that.attrs.y);

    var background = new Kinetic.Ellipse({
      radius: that.attrs.radius + 5,
      alpha: 0.6,
      fill: "white",
      shadow: {
        color: 'grey',
        blur: 15
      }
    });

    var circle = new Kinetic.Ellipse({
      radius: that.attrs.radius,
      alpha: 0.8,
      fill: "white",
      stroke: "black",
      strokeWidth: 1
    });

    var len = that.attrs.radius / 3;

    var middleButton = new Kinetic.Rect({
      x: -len,
      y: -len,
      width: 2 * len,
      height: 2 * len,
      cornerRadius: that.attrs.width / 4,
      stroke: "black",
      strokeWidth: that.attrs.arrow_width
    });

    // add cursor styling
    middleButton.on("mouseover", function() {
      that.attrs.cursor = document.body.style.cursor;
      document.body.style.cursor = "pointer";
    });

    middleButton.on("mouseout", function() {
      document.body.style.cursor = that.attrs.cursor;
    });

    var arrows = new Kinetic.Group();

    var points = [{
      x: 0,
      y: 0
    }, {
      x: len,
      y: 0
    }, {
      x: len,
      y: len
    }];

    var cat_pow = Math.pow(len, 2);
    var dist = Math.sqrt(2 * cat_pow) / 2;
    var separation = 1.5 * that.attrs.radius / 3;
    var up_line = new Kinetic.Polygon({
      x: -dist,
      y: -separation,
      points: points,
      fill: "white",
      stroke: "black",
      strokeWidth: that.attrs.arrow_width,
      lineCap: 'round',
      lineJoin: 'round',
      rotation: -Math.PI / 4
    });

    // add cursor styling
    up_line.on("mouseover", function() {
      that.attrs.cursor = document.body.style.cursor;
      document.body.style.cursor = "pointer";
    });

    up_line.on("mouseout", function() {
      document.body.style.cursor = that.attrs.cursor;
    });

    var down_line = new Kinetic.Polygon({
      x: dist,
      y: separation,
      points: points,
      fill: "white",
      stroke: "black",
      strokeWidth: that.attrs.arrow_width,
      lineCap: 'round',
      lineJoin: 'round',
      rotation: 3 * Math.PI / 4,
    });

    // add cursor styling
    down_line.on("mouseover", function() {
      that.attrs.cursor = document.body.style.cursor;
      document.body.style.cursor = "pointer";
    });

    down_line.on("mouseout", function() {
      document.body.style.cursor = that.attrs.cursor;
    });

    var right_line = new Kinetic.Polygon({
      x: separation,
      y: -dist,
      points: points,
      fill: "white",
      stroke: "black",
      strokeWidth: that.attrs.arrow_width,
      lineCap: 'round',
      lineJoin: 'round',
      rotation: Math.PI / 4,
    });

    // add cursor styling
    right_line.on("mouseover", function() {
      that.attrs.cursor = document.body.style.cursor;
      document.body.style.cursor = "pointer";
    });

    right_line.on("mouseout", function() {
      document.body.style.cursor = that.attrs.cursor;
    });

    var left_line = new Kinetic.Polygon({
      x: -separation,
      y: dist,
      points: points,
      fill: "white",
      stroke: "black",
      strokeWidth: that.attrs.arrow_width,
      lineCap: 'round',
      lineJoin: 'round',
      rotation: -3 * Math.PI / 4,
    });

    // add cursor styling
    left_line.on("mouseover", function() {
      that.attrs.cursor = document.body.style.cursor;
      document.body.style.cursor = "pointer";
    });

    left_line.on("mouseout", function() {
      document.body.style.cursor = that.attrs.cursor;
    });

    arrows.add(up_line);
    arrows.add(down_line);
    arrows.add(right_line);
    arrows.add(left_line);

    that.getNode().add(background);
    that.getNode().add(circle);
    that.getNode().add(middleButton);
    that.getNode().add(arrows);

    // Events
    middleButton.on("click", function() {
      if (that.attrs.callback && that.attrs.callback.func)
        that.attrs.callback.func("Center", that.attrs.callback.data);
    });

    up_line.on("click", function() {
      if (that.attrs.callback && that.attrs.callback.func)
        that.attrs.callback.func("Up", that.attrs.callback.data);
    });

    down_line.on("click", function() {
      if (that.attrs.callback && that.attrs.callback.func)
        that.attrs.callback.func("Down", that.attrs.callback.data);
    });

    right_line.on("click", function() {
      if (that.attrs.callback && that.attrs.callback.func)
        that.attrs.callback.func("Right", that.attrs.callback.data);
    });

    left_line.on("click", function() {
      if (that.attrs.callback && that.attrs.callback.func)
        that.attrs.callback.func("Left", that.attrs.callback.data);
    });

    return that;
  }

  //////////////////////////////////////////////////////////////////////////////
  // Slider
  //////////////////////////////////////////////////////////////////////////////
  module.Slider = function(config) {
    var that = Widget(merge({
      width: 14,
      height: 100,
      sections: 8,
      slide_hight: 10
    }, config));

    var group = that.getNode();
    group.setX(that.attrs.x);
    group.setY(that.attrs.y);

    var line = new Kinetic.Line({
      points: [{
        x: 0,
        y: that.attrs.width,
      }, {
        x: 0,
        y: that.attrs.width + that.attrs.height + that.attrs.slide_hight
      }],
      troke: "black",
      strokeWidth: 2,
    });

    var background = new Kinetic.Rect({
      x: -that.attrs.width / 2,
      y: that.attrs.width - that.attrs.width / 4,
      width: that.attrs.width,
      height: that.attrs.width + that.attrs.height + 2 * that.attrs.width / 4
              + that.attrs.slide_hight - that.attrs.width,
      alpha: 0.6,
      fill: "white",
      shadow: {
        color: 'grey',
        blur: 15
       }
    });

    var zoom_button = new Kinetic.Group({
      x: -that.attrs.width / 2,
      y: that.attrs.width,
      draggable: true,
      dragConstraint: "vertical",
      dragBounds: {
        top: that.attrs.y + that.attrs.width,
        bottom: that.attrs.y + that.attrs.width + that.attrs.height
      }
    });

    var button = new Kinetic.Rect({
      width: that.attrs.width,
      height: that.attrs.slide_hight,
      fill: "white",
      stroke: "black",
      strokeWidth: 1,
      cornerRadius: that.attrs.width / 4,
      shadow: {
        color: 'grey',
        blur: 10
      }
    });

    // add cursor styling
    button.on("mouseover", function() {
      that.attrs.cursor = document.body.style.cursor;
      document.body.style.cursor = "move";
    });

    button.on("mouseout", function() {
      document.body.style.cursor = that.attrs.cursor;
    });

    var bline = new Kinetic.Line({
      points: [{
        x: that.attrs.width / 4,
        y: that.attrs.slide_hight / 2
      }, {
        x: that.attrs.width - (that.attrs.width / 4),
        y: that.attrs.slide_hight / 2
      }],
      stroke: "black",
      strokeWidth: 2
    });

    zoom_button.add(button);
    zoom_button.add(bline);

    var sum_button = new Kinetic.Group({
      x: -that.attrs.width / 2
    });

    var plus_rect = new Kinetic.Rect({
      width: that.attrs.width,
      height: that.attrs.width,
      fill: "white",
      stroke: "black",
      strokeWidth: 1,
      cornerRadius: that.attrs.width / 4,
      shadow: {
        color: 'grey',
        blur: 10
      }
    });

    // add cursor styling
    plus_rect.on("mouseover", function() {
      that.attrs.cursor = document.body.style.cursor;
      document.body.style.cursor = "pointer";
    });

    plus_rect.on("mouseout", function() {
      document.body.style.cursor = that.attrs.cursor;
    });

    var plus_h = new Kinetic.Line({
      points: [{
        x: that.attrs.width / 4,
        y: that.attrs.width / 2
      }, {
        x: that.attrs.width - (that.attrs.width / 4),
        y: that.attrs.width / 2
      }],
      stroke: "black",
      strokeWidth: 2
    });

    var plus_v = new Kinetic.Line({
      points: [{
        x: that.attrs.width / 2,
        y: that.attrs.width / 4
      }, {
        x: that.attrs.width / 2,
        y: that.attrs.width - (that.attrs.width / 4)
      }],
      stroke: "black",
      strokeWidth: 2
    });

    sum_button.add(plus_rect);
    sum_button.add(plus_h);
    sum_button.add(plus_v);

    var rest_button = new Kinetic.Group({
      x: -that.attrs.width / 2,
      y: that.attrs.width + that.attrs.height + that.attrs.slide_hight
    });

    var sub_rect = new Kinetic.Rect({
      width: that.attrs.width,
      height: that.attrs.width,
      fill: "white",
      stroke: "black",
      strokeWidth: 1,
      cornerRadius: that.attrs.width / 4,
      shadow: {
        color: 'grey',
        blur: 10
      }
    });

    // add cursor styling
    sub_rect.on("mouseover", function() {
      that.attrs.cursor = document.body.style.cursor;
      document.body.style.cursor = "pointer";
    });

    sub_rect.on("mouseout", function() {
      document.body.style.cursor = that.attrs.cursor;
    });

    var sub_h = new Kinetic.Line({
      points: [{
        x: that.attrs.width / 4,
        y: that.attrs.width / 2
      }, {
        x: that.attrs.width - (that.attrs.width / 4),
        y: that.attrs.width / 2
      }],
      stroke: "black",
      strokeWidth: 2
    });

    rest_button.add(sub_rect);
    rest_button.add(sub_h);

    that.getNode().add(background);
    that.getNode().add(line);
    that.getNode().add(zoom_button);
    that.getNode().add(sum_button);
    that.getNode().add(rest_button);

    // Events
    zoom_button.on("dragmove", function() {
      var pos = this.getAbsolutePosition();
      var init = that.attrs.y + that.attrs.width;
      var percent = (pos.y - init) / that.attrs.height;

      if (that.attrs.callback && that.attrs.callback.func)
        that.attrs.callback.func(percent, true, that.attrs.callback.data);
    });

    sum_button.on("click", function() {
      var pos = zoom_button.getAbsolutePosition();
      var attrs = zoom_button.getAttrs();
      var limit = attrs["dragBounds"]["top"];
      var y = pos.y - that.attrs.height / that.attrs.sections;

      if (y <= limit) {
        y = limit;
      }

      var init = that.attrs.y + that.attrs.width;
      var percent = (y - init) / that.attrs.height;

      // Set global to local position
      y = Math.abs(y - that.attrs.y);

      zoom_button.transitionTo({
        y: y,
        duration: 0.2,
        easing: 'ease-in-out'
      });

      if (that.attrs.callback && that.attrs.callback.func)
        that.attrs.callback.func(percent, false, that.attrs.callback.data);
    });

    rest_button.on("click", function() {
      var pos = zoom_button.getAbsolutePosition();
      var attrs = zoom_button.getAttrs();
      var limit = attrs["dragBounds"]["bottom"];
      var y = pos.y + that.attrs.height / that.attrs.sections;

      if (y >= limit)
        y = limit;

      var init = that.attrs.y + that.attrs.width;
      var percent = (y - init) / that.attrs.height;

      // Set global to local position
      y = Math.abs(y - that.attrs.y);

      zoom_button.transitionTo({
        y: y,
        duration: 0.2,
        easing: 'ease-in-out'
      });
      
      if (that.attrs.callback && that.attrs.callback.func)
        that.attrs.callback.func(percent, false, that.attrs.callback.data);
    });

    return that;
  };

  //////////////////////////////////////////////////////////////////////////////
  // Item
  //////////////////////////////////////////////////////////////////////////////
  Item = function(config) {
    var that = Widget(merge({
      height: 0,
      width: 0
    }, config));

    that.getWidth = function() {
      return that.attrs.width;
    };

    that.getHeight = function() {
      return that.attrs.heigth;
    };

    return that;
  };

  //////////////////////////////////////////////////////////////////////////////
  // SeparatorItem
  //////////////////////////////////////////////////////////////////////////////
  module.SeparatorItem = function(config) {
    var that = Item(config);

    var points = [{
      x: that.attrs.x,
      y: that.attrs.y
    }, {
      x: that.attrs.x,
      y: that.attrs.y + that.attrs.height
    }];

    var line = new Kinetic.Line({
      points: points,
      stroke: "black",
      strokeWidth: that.attrs.width,
      lineCap: "round",
      lineJoin: "round"
    });

    that.getNode().add(line);

    return that;
  };

  //////////////////////////////////////////////////////////////////////////////
  // ToolMenuItem
  //////////////////////////////////////////////////////////////////////////////
  module.ToolMenuItem = function(config) {
    var that = Item(merge({
      separation: 0
    }, config));

    var events = {};

    if (that.attrs.label) {
      var label = new Kinetic.Text({
        name: "label",
        text: that.attrs.label,
        align: "center",
        fontSize: 20,
        fill: "white",
        padding: 8,
        alpha: 0.6,
        stroke: 'grey',
        strokeWidth: 1,
        shadow: {
          color: 'grey',
          blur: 15
        },
        cornerRadius: 10
      });

      that.getNode().add(label);
    }

    if (that.attrs.image) {
      var kimage = new Kinetic.Image({
        name: "icon",
        image: that.attrs.image
      });
      that.getNode().add(kimage);
    }

    that.getWidth = function() {
      var kimage = that.getNode().get(".icon")[0];

      if (kimage)
        return kimage.getWidth();
      else
        return 0;
    };

    that.getHeight = function() {
      var kimage = that.getNode().get(".icon")[0];

      if (kimage)
        return kimage.getHeight();
      else
        return 0;
    };

    that.on = function(evt, handler) {
      events[evt] = handler;
    };

    that.trigger = function(evt, data) {
      if (events[evt])
        events[evt](data);
    };

    return that;
  };

  //////////////////////////////////////////////////////////////////////////////
  // ToolMenu
  //////////////////////////////////////////////////////////////////////////////
  module.ToolMenu = function(config) {
    var that = Widget(merge({
      min_size: 14,
      max_size: 48,
      separation: 24,
      fontSize: 15,
      fontFamily: "Calibri",
      textFill: "black",
      easing: "ease-out",
      duration: 0.1
    }, config));

    var items = [];

    function nextItemPosition() {
      var posx = 0;

      for (var i = 0; i < items.length; i++) {
        posx += items[i].getWidth();
        posx += that.attrs.separation;
      }

      return posx;
    };

    function updatePadding(padding) {
      if (!padding)
        return;

      var h = v = 0;

      if (that.attrs.padding.horizontal)
        h = that.attrs.padding.horizontal;

      if (that.attrs.padding.vertical)
        v = that.attrs.padding.vertical;

      var width = 0;
      for (var i = 0; i < items.length; i++)
        width += items[i].getWidth() + that.attrs.separation;
      width -= that.attrs.separation;

      padding.setX(-h);
      padding.setY(-v);
      padding.setHeight(that.attrs.min_size + 2 * v);
      padding.setWidth(width + 2 * h);

      if (that.attrs.padding.radius)
        padding.setCornerRadius(that.attrs.padding.radius);
    };

    function confIcon(item) {
      var image = item.toolAttrs.img;

      if (!image)
        return;

      image.setAttrs({
        x: item.toolAttrs.minx + that.attrs.min_size / 2,
        y: item.toolAttrs.miny + that.attrs.min_size / 2,
        width: that.attrs.min_size,
        height: that.attrs.min_size,
        offset: {
          x: item.toolAttrs.minx + that.attrs.min_size / 2,
          y: item.toolAttrs.miny + that.attrs.min_size / 2
        },
        shadow: {
          color: 'grey',
          blur: 6,
          offset: [2, 2],
          alpha: 0.6
        }
      });
    };

    function confLabel(item) {
      var label = item.toolAttrs.label;

      if (!label)
        return;

      label.setFontSize(that.attrs.fontSize);
      label.setFontFamily(that.attrs.fontFamily);
      label.setTextFill(that.attrs.textFill);

      label.setX(item.toolAttrs.maxx - label.getBoxWidth() / 2
                                                    + that.attrs.max_size / 2);
      label.setY(item.toolAttrs.maxy - label.getBoxHeight()
                                                    + item.toolAttrs.maxy / 2);
      label.hide();
    };

    function configureItem(item) {
      item.toolAttrs = {
        minx: 0,
        miny: 0
      };
      item.toolAttrs.maxx = item.toolAttrs.minx
                          - that.attrs.max_size / 2 + that.attrs.min_size / 2;
      item.toolAttrs.maxy = item.toolAttrs.miny
                          - that.attrs.max_size / 2 + that.attrs.min_size / 2;

      item.toolAttrs.img = item.getNode().get(".icon")[0];
      item.toolAttrs.label = item.getNode().get(".label")[0];

      confIcon(item);
      confLabel(item);
    }

    function confItemNode(item) {
      var node = item.getNode();

      configureItem(item);

      node.on("mouseover touchstart", function() {
        var image = item.toolAttrs.img;
        var label = item.toolAttrs.label;

        that.attrs.cursor = document.body.style.cursor;
        if (item.attrs.draggable)
          document.body.style.cursor = "move";
        else
          document.body.style.cursor = "pointer";

        node.moveToTop();
        if (image) {
          if (image.trans) {
            image.trans.stop();
            image.trans = undefined;
          }

          image.trans = image.transitionTo({
            x: item.toolAttrs.maxx + that.attrs.min_size / 2,
            y: item.toolAttrs.maxy + that.attrs.min_size / 2,
            width: that.attrs.max_size,
            height: that.attrs.max_size,
            shadow: {
              offset: {
                x: 10,
                y: 10
              }
            },
            duration: that.attrs.duration,
            easing: that.attrs.easing
          });
        }

        if (label)
          label.show();
      });

      node.on("mouseout touchend", function() {
        var image = item.toolAttrs.img;
        var label = item.toolAttrs.label;

        document.body.style.cursor = that.attrs.cursor;

        if (image) {
          if (image.trans) {
            image.trans.stop();
            image.trans = undefined;
          }

          image.trans = image.transitionTo({
            x: item.toolAttrs.minx + that.attrs.min_size / 2,
            y: item.toolAttrs.miny + that.attrs.min_size / 2,
            width: that.attrs.min_size,
            height: that.attrs.min_size,
            shadow: {
              offset: {
                x: 2,
                y: 2
              }
            },
            duration: that.attrs.duration,
            easing: that.attrs.easing
          });
        }

        if (label)
          label.hide();
      });

      node.on("click", function() {
        item.trigger("click", null);
      });
    };

    function confDrag(image, size) {
      if (image.trans) {
        image.trans.stop();
        image.trans = undefined;
      }

      image.setAttrs({
        width: size,
        height: size
      });
    };

    function _setDraggable(item) {
      var image = item.toolAttrs.img;

      image.setDraggable(true);
      image.on("dragstart", function() {
        var label = item.toolAttrs.label;

        confDrag(image, that.attrs.max_size);

        if (label)
          label.hide();

        item.toolAttrs.regenerated = false;
      });

      image.on("dragmove", function() {
        var pos = image.getPosition();

        confDrag(image, that.attrs.max_size);

        if (item.toolAttrs.regenerated)
          return;

        var dst = Math.sqrt(Math.pow(pos.x - item.toolAttrs.minx, 2)
                  + Math.pow(pos.y - item.toolAttrs.miny, 2));

        if (dst < that.attrs.max_size / 2)
          return;

        var nImage = new Kinetic.Image({
          name: "icon",
          x: item.toolAttrs.minx + that.attrs.min_size,
          y: item.toolAttrs.miny + that.attrs.min_size,
          draggable: true,
          image: image.getImage(),
          width: 1,
          height: 1,
          offset: {
            x: item.toolAttrs.minx + that.attrs.min_size / 2,
            y: item.toolAttrs.miny + that.attrs.min_size / 2
          },
          shadow: {
            color: 'grey',
            blur: 6,
            offset: [2, 2],
            alpha: 0.6
          }
        });

        item.toolAttrs.regenerated = true;
        item.toolAttrs.img = nImage;

        item.getNode().add(nImage);
        image.moveToTop();

        nImage.trans = nImage.transitionTo({
          x: item.toolAttrs.minx + that.attrs.min_size / 2,
          y: item.toolAttrs.miny + that.attrs.min_size / 2,
          width: that.attrs.min_size,
          height: that.attrs.min_size,
          duration: 1,
          easing: 'elastic-ease-out'
        });

        _setDraggable(item);
      });

      image.on("dragend", function() {
        if (!item.toolAttrs.regenerated)
          return;

        item.toolAttrs.regenerated = false;
        var pos = image.getAbsolutePosition();
        item.trigger("dragend", pos);

        item.getNode().remove(image);
        that.getNode().getLayer().draw();
      });
    };

    function setPadding() {
      var padding = new Kinetic.Rect({
        name: "padding",
        fill: "white",
        alpha: 0.6,
        shadow: {
          color: 'grey',
          blur: 15
        }
      });

      updatePadding(padding);
      that.getNode().add(padding);
    };

    var group = that.getNode();
    group.setX(that.attrs.x);
    group.setY(that.attrs.y);

    if (that.attrs.padding)
      setPadding();

    that.addMenuItem = function(item) {
      if (!item instanceof module.ToolMenuItem)
        return;

      item.getNode().setX(nextItemPosition());
      item.getNode().setY(0);

      items.push(item);
      that.getNode().add(item.getNode());

      confItemNode(item);
      if (item.attrs.draggable)
        _setDraggable(item);

      updatePadding(that.getNode().get(".padding")[0]);

      that.getNode().getLayer().draw();
    };

    that.addSeparator = function() {
      var separator = module.SeparatorItem({
        x: nextItemPosition(),
        y: 0,
        height: that.attrs.min_size,
        width: 1
      });

      items.push(separator);
      that.getNode().add(separator.getNode());
      updatePadding(that.getNode().get(".padding")[0]);
      that.getNode().getLayer().draw();
    };

    return that;
  };

  return module;

}());
