/**
 *
 *  Copyright (C) 2013 GSyC/LibreSoft, Universidad Rey Juan Carlos.
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
 * Workspaces streaming Module
 */
var WStreaming = (function () {

  var module = {};
  var editor;

  var workspace_id;

  var connection = null;
  var connected = false;

  /* Empty declaration of management interface*/
  module.ConnectionHandlerIface = {
    /**
    * Workspace to init.
    */
    connectWorkspace: function (workspace) {},

    /**
    * Node to start are set in nodes array.
    */
    start: function (nodes) {},

    /**
    * Node to stop are set in nodes array.
    */
    stop: function (nodes) {}
  };

  //////////////////////////////////////////////////////////////////////////////
  // Management Interface
  //////////////////////////////////////////////////////////////////////////////
  ManagementIface = function() {
    var that = {};

    function addNewTab(name) {
      $("div#shells ul").append("<li><a data-toggle='tab' href='#tabs-" + name + "'><h4>" + name + "</h4></a></li>");
      $("div#shells div#tab-content").append("<div id='tabs-"+ name +"' class='tab-pane'></div>");
    }

    function addShellinaBox(name, port) {
      $("<iframe id='iframe" + name + "' class='frame'>").appendTo("#tabs-" + name);
      $("#iframe" + name).attr("src", "http://localhost:" + JSON.stringify(port));
      $("div#shells a:last").tab("show");
    }

    function removeTab(name) {
      $("div#shells a[href='#tabs-" + name + "']").remove();
      $("div#shells div#tab-content div#tabs-" + name).remove();
      $("div#shells a:last").tab("show");
    }

    function addListeners() {
      /* Joined is emitted when we are registered for workspace events */
      connection.on("joined", function(err, data){
        if (err)
          console.log("Error: " + err);
        else
          console.log("Registered in workspace " + data["workspace"]);
      });

      /* We want to know when the streaming connection is closed */
      connection.on("disconnected", function(){
        console.log("Server disconnected");
        connected = false;
      });

      /* We want to know when the streaming connection is reconnected */
      connection.on("connected", function(){
        console.log("Server reconnected");
        connected = true;
        connection.joinWorkspace(workspace_id);
      });

      /* We want to get state updates */
      connection.on("updated", function(data){
        console.log("Updated: " + JSON.stringify(data));
        for(var index = 0; index < data.nodes.length; index++) {
          var machine = data.nodes[index].name;
          var state = data.nodes[index].state;
          if (state == "halted")
            editor.setState(machine, "halted");
          else
            editor.setState(machine, "started");
        }
      });

      /* We want to get shellinabox notifications */
      connection.on("shell", function(data){
        console.log("Shell: " + JSON.stringify(data));
        var name = data.node;
        var state = data.state;
        editor.setShellState(name, state);

        if(data.state == "connected"){
          addNewTab(name);
          addShellinaBox(name, data.port);
        } else if(data.state == "disconnected"){
          removeTab(name);
        }
      });
    }

    that.connectWorkspace = function(workspace) {
      if (connection != null) {
        alert("Connection is already opened");
        return;
      }

      Workspace.connect(function(error, conn) {
        if (error)
          alert("Error: " + error);
        else {
          workspace_id = workspace;
          connection = conn;
          connected = true;
          console.log("Connected");
          addListeners()
          console.log("Registering...");
          connection.joinWorkspace(workspace_id);
        }
      });
    }

    return that;
  }

  //////////////////////////////////////////////////////////////////////////////
  // Object that implements Management Handler interface
  //////////////////////////////////////////////////////////////////////////////
  ConnectionHandler = function() {
    var that = {};

    that.start = function(node) {
      if (!connected)
        alert("Server disconnected");
      else
        connection.start([node]);
    };

    that.stop = function(node) {
      if (!connected)
        alert("Server disconnected");
      else
        connection.stop([node]);
     };

    that.connectShell = function(node) {
      if (!connected)
        alert("Server disconnected");
      else
        connection.connectShell([node]);
    };

    that.disconnectShell = function(node) {
      if (!connected)
        alert("Server disconnected");
      else
        connection.disconnectShell([node]);
    };

    return that;
  };

  module.initManagementIface = function(workspace) {
    iface = ManagementIface();
    iface.connectWorkspace(workspace);

    return iface;
  };

  module.getHandler = function() {
    handler =  ConnectionHandler();

    return handler;
  };

  // Initialization function
  module.useWidget = function(widget){
    editor = widget;
  };

  return module;

}());