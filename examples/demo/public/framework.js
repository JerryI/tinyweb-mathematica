var WSPHost;

let socket = new WebSocket("ws://"+window.location.hostname+':'+window.location.port);

socket.onopen = function(e) {
  console.log("[open] Соединение установлено");
}; 

socket.onmessage = function(event) {
  let data = JSON.parse(event.data);
  console.log(data);
  interpretate(data);
};

socket.onclose = function(event) {
  console.log('Connection lost. Please, update the page to see new changes.');
};


function WSPHttpQueryQuite(command, promise, type = "String") {

  var http = new XMLHttpRequest();
  var url = 'http://'+WSPHost+'/utils/query.wsp';
  var params = 'command='+encodeURI(command)+'&type='+type;
  http.open('GET', url+"?"+params, true);

  //Send the proper header information along with the request
  http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
  if (type == "ExpressionJSON" || type == "JSON") {
    http.onreadystatechange = function() {//Call a function when the state changes.
      if(http.readyState == 4 && http.status == 200) {
       
        // http.responseText will be anything that the server return
        promise(JSON.parse(http.responseText));
        
      }
    };
  } else {
    http.onreadystatechange = function() {//Call a function when the state changes.
      if(http.readyState == 4 && http.status == 200) {
  
        // http.responseText will be anything that the server return
        promise(http.responseText);
        
      }
    };
  }

 
  http.send(null);
}

function WSPHttpQuery(command, promise, type = "String") {
  var http = new XMLHttpRequest();
  var url = 'http://'+WSPHost+'/utils/query.wsp';
  var params = 'command='+encodeURI(command)+'&type='+type;

  console.log(params);
  http.open('GET', url+"?"+params, true);

  //Send the proper header information along with the request
  http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
  if (type == "ExpressionJSON" || type == "JSON") {
    http.onreadystatechange = function() {//Call a function when the state changes.
      if(http.readyState == 4 && http.status == 200) {
        
        // http.responseText will be anything that the server return
        promise(JSON.parse(http.responseText));
        document.getElementById('logoFlames').style = "display: none";
      }
    };
  } else {
    http.onreadystatechange = function() {//Call a function when the state changes.
      if(http.readyState == 4 && http.status == 200) {
  
        // http.responseText will be anything that the server return
        promise(http.responseText);
        document.getElementById('logoFlames').style = "display: none";
      }
    };
  }

  document.getElementById('logoFlames').style = "display: block";
  http.send(null);
}

function WSPSetHost(host) {
  WSPHost = host;
}

function WSPSetStorageHost(host) {
  WSPStorageHost = host;
}


function WSPGet(path, params, promise) {

  var http = new XMLHttpRequest();
  var url = 'http://'+WSPHost+'/'+path;

  http.open('GET', url+"?"+encodeURI(params), true);

  //Send the proper header information along with the request
  http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

  http.onreadystatechange = function() {//Call a function when the state changes.
    if(http.readyState == 4 && http.status == 200) {
  
      // http.responseText will be anything that the server return
      promise(http.responseText);
      document.getElementById('logoFlames').style = "display: none";
    }
  };

  document.getElementById('logoFlames').style = "display: block";
  http.send(null);
}

function WSPPost(path, command, promise) {

  var http = new XMLHttpRequest();
  var url = 'http://'+WSPHost+'/'+path;

  http.open('POST', url, true);

  //Send the proper header information along with the request
  http.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

  http.onreadystatechange = function() {//Call a function when the state changes.
    if(http.readyState == 4 && http.status == 200) {
  
      // http.responseText will be anything that the server return
      promise(http.responseText);
      document.getElementById('logoFlames').style = "display: none";
    }
  };

  document.getElementById('logoFlames').style = "display: block";
  var data = new FormData();
  data.append('command', data);

  http.send(data);
}



var core, interpretate;

core = {};

core.List = function(args, env) {
  var copy, e, i, len, list;
  copy = Object.assign({}, env);
  list = [];
  for (i = 0, len = args.length; i < len; i++) {
    e = args[i];
    list.push(interpretate(e, copy));
  }
  return list;
};

core.Association = function(args, env) {
  var copy, e, i, len, list;
  copy = Object.assign({}, env);
  copy.association = {};
  
  for (i = 0, len = args.length; i < len; i++) {
    interpretate(args[i], copy);
  }
  
  return copy.association;
};

core.Rule = function(args, env) {
  env.association[args[0]] = args[1];
};

core.SetStatus = function(args, env) {
  console.log("set status!");
  console.log(args);
};



interpretate = function(d, env = {}) {
  if (typeof d === 'undefined') {
    throw 'undefined type (not an object or string!): duaring the parsing';
  }
  if (typeof d === 'string') {
    return d.slice(1, -1);
  }
  if (typeof d === 'number') {
    return d;
  }
  
  this.name = d[0];
  this.args = d.slice(1, d.length);
  return core[this.name](this.args, env);
};

function uuidv4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
  });
}

var modalsLoaded = [];
    
function modalLoad (id, params = "{}") {
  if(!modalsLoaded.includes(id)) {
    console.log("loading modal...");
    WSPHttpQuery('LoadPage["assets/modal/'+id+'.wsp", '+params+']', function(r) {

      var container = document.createElement("div");
      var uid = uuidv4()
      container.id = uid;
      document.getElementById('modals').appendChild(container);

      setInnerHTML(document.getElementById(uid), r);


      $('#'+id).modal('show');
    });

    modalsLoaded.push(id);
  } else {
    $('#'+id).modal('show');
  }

  

};

function killProcess (id) {
  WSPHttpQuery('ProcessKill["'+id+'"]; "killed"', console.log);
}

function restartProcess (id) {
  WSPHttpQuery('ProcessStart["'+id+'"]; "started"', console.log);
}

var setInnerHTML = function(elm, html) {
  elm.innerHTML = html;
  Array.from(elm.querySelectorAll("script")).forEach( oldScript => {
    const newScript = document.createElement("script");
    Array.from(oldScript.attributes)
      .forEach( attr => newScript.setAttribute(attr.name, attr.value) );
    newScript.appendChild(document.createTextNode(oldScript.innerHTML));
    oldScript.parentNode.replaceChild(newScript, oldScript);
  });
};
